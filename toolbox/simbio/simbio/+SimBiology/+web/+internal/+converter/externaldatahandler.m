function out=externaldatahandler(action,varargin)


    switch(action)
    case 'loadExternalData'
        out=loadExternalData(varargin{:});
    end


    function out=loadExternalData(projectConverter,fileNames,projectNode)

        out=struct('matfile','','data',[]);


        location=cellfun(@(x)~isempty(x),strfind(fileNames,'externaldata'));


        if~any(location)
            return;
        end


        externalDataFileName=fileNames{location};


        out.matfile=[SimBiology.web.internal.desktopTempname(),'.mat'];


        loadedData=struct;
        externalDataNodes=getField(projectNode,'ExternalData');
        if~isempty(externalDataNodes)
            externalDataNodes=getField(externalDataNodes,'IndData');
        end

        externalDataLookup=struct;
        externalDataLookup.dataInfo=struct;
        externalDataLookup.matfileDerivedVariableName='';
        externalDataLookup.matfileName='';
        externalDataLookup.matfileVariableName='';
        externalDataLookup.name='';
        externalDataLookup.source='';
        externalDataLookup.type='';

        externalDataLookup=repmat(externalDataLookup,1,numel(externalDataNodes));

        for i=1:numel(externalDataNodes)
            try
                name=getAttribute(externalDataNodes(i),'Name');


                externalDataLookup(i).name=name;
                externalDataLookup(i).source=getAttribute(externalDataNodes(i),'OriginalSource');
                externalDataLookup(i).matfileName=out.matfile;
                externalDataLookup(i).matfileVariableName=sprintf('data%d',i);
                externalDataLookup(i).type='externaldata';
                externalDataLookup(i).matfileDerivedVariableName=sprintf('deriveddata%d',i);


                data=load(externalDataFileName,name);
                data=data.(name);
                data=dataset2table(data);


                [data,derivedDataInfo,derivedDataTable,derivedDataColumnNames]=loadDerivedData(externalDataNodes(i),data);


                inputs=struct('next',data,'name',name);
                inputs.nonmem=struct('nonmemInterpretation',false,'pkdata',[]);


                dataInfo=SimBiology.web.datahandler('getExternalDataInfo',inputs);


                dataInfo.exclusionStore=loadExclusionStore(externalDataNodes(i),data);


                for j=1:numel(dataInfo.columnInfo)
                    dataInfo.columnInfo(j).units=getAttribute(externalDataNodes(i),sprintf('Units%d',j-1));
                end



                for j=1:numel(derivedDataInfo)
                    if~derivedDataInfo(j).Undefined
                        index=find(ismember({dataInfo.columnInfo.name},derivedDataInfo(j).Name),1);
                        dataInfo.columnInfo(index).expression=derivedDataInfo(j).Expression;
                        errorMsg=derivedDataInfo(j).ErrorMessage;
                        if 0~=strlength(errorMsg)
                            msgStruct=struct('type','expression','severity','error','message',errorMsg);
                            dataInfo.columnInfo(index).errorMsgs=msgStruct;
                        else
                            dataInfo.columnInfo(index).errorMsgs=[];
                        end
                        dataInfo.columnInfo(index).units=derivedDataInfo(j).Units;
                    end
                end



                if~isempty(derivedDataColumnNames)
                    origColumnNames=setdiff(data.Properties.VariableNames,derivedDataColumnNames,'stable');
                    origData=data(:,origColumnNames);
                else
                    origData=data;
                end


                loadedData.(externalDataLookup(i).matfileVariableName)=origData;
                loadedData.(externalDataLookup(i).matfileDerivedVariableName)=derivedDataTable;


                columnNames={dataInfo.columnInfo.name};
                columnClassification=loadColumnClassification(externalDataNodes(i),columnNames);


                for j=1:numel(dataInfo.columnInfo)
                    dataInfo.columnInfo(j).classification=columnClassification{j};
                end

                externalDataLookup(i).dataInfo=dataInfo;
            catch e
                externalDataLookup(i).dataInfo=dataInfo;
                projectConverter.addError('Unable to load external data',e);
            end
        end

        save(out.matfile,'-struct','loadedData');
        out.data=externalDataLookup;


        function[data,derivedDataInfo,derivedDataTable,derivedDataColumnNames]=loadDerivedData(node,data)


            derivedDataInfo=[];
            derivedDataNode=getField(node,'DerivedData');
            if~isempty(derivedDataNode)
                derivedDataColumns=derivedDataNode.IndDerivedData;
                derivedDataInfo=buildAttributeStruct(derivedDataColumns,{'Add','ErrorMessage','Expression','Name','Undefined','Units'});
            end


            derivedDataTable=table;
            derivedDataColumnNames=[];
            for i=1:numel(derivedDataInfo)
                if~derivedDataInfo(i).Undefined
                    columnName=derivedDataInfo(i).Name;
                    derivedDataColumnNames{end+1}=char(columnName);%#ok<AGROW>
                    expressionErrorMessage=derivedDataInfo(i).ErrorMessage;



                    if derivedDataInfo(i).Add&&any(strcmp(data.Properties.VariableNames,columnName))
                        derivedDataTable.(columnName)=data.(columnName);
                    elseif isempty(expressionErrorMessage)

                        info=evaluateDerivedDataColumn(data,data.Properties.VariableNames,derivedDataInfo(i).Expression);
                        derivedDataTable.(columnName)=info.results;
                        data.(columnName)=info.results;
                        derivedDataInfo(i).ErrorMessage=info.errMsg;%#ok<AGROW>
                    else
                        derivedDataTable.(columnName)=nan(height(data),1);
                        data.(columnName)=nan(height(data),1);
                        derivedDataInfo(i).ErrorMessage=expressionErrorMessage;%#ok<AGROW>
                    end
                end
            end


            function exclusionStore=loadExclusionStore(node,data)


                excludedRowNumbers=getVectorAttributes(node,'ExcludedRows');


                manualExclusions=[];
                expressionExclusions=[];
                constraintNodes=node.Constraints.IndConstraint;
                constraints=buildAttributeStruct(constraintNodes,{'ExcludeSelected','Expression','ErrorMessage','Description','Undefined','Count'});


                for i=1:numel(constraints)
                    if strcmp(constraints(i).Undefined,'false')
                        expression=constraints(i).Expression;
                        if~isempty(regexp(expression,'ROW == \d','once'))


                            vecValues=getVectorAttributes(constraintNodes(i),'Failures');
                            vecValues=vecValues(:);
                            manualExclusions=manualExclusions(:);
                            manualExclusions=vertcat(manualExclusions,vecValues);%#ok<AGROW>
                        else

                            expressionExclusion=struct;
                            expressionExclusion.ID=i;
                            expressionExclusion.exclude=constraints(i).ExcludeSelected;
                            expressionExclusion.expression=constraints(i).Expression;
                            expressionExclusion.message=constraints(i).ErrorMessage;
                            expressionExclusion.description=constraints(i).Description;
                            expressionExclusion.numMatches=constraints(i).Count;



                            excludedRows=getVectorAttributes(constraintNodes(i),'Failures');




                            if max(excludedRows)>height(data)
                                excludedRows=[];
                                expressionExclusion.numMatches=0;
                                expressionExclusion.message="Expression result must return a 1-by-n vector where n is the number of rows in the data.";
                            end


                            if~isempty(expressionExclusion.message)
                                excludedRows=[];
                                expressionExclusion.numMatches=0;
                            end



                            if strcmp(expressionExclusion.exclude,'true')
                                expressionExclusion.manuallyIncluded=setdiff(excludedRows,excludedRowNumbers);
                            else
                                expressionExclusion.manuallyIncluded=[];
                            end

                            ranges=SimBiology.web.datahandler('getRangesFromArray',excludedRows);
                            ranges{end+1}="DUMMY";%#ok<AGROW> % Add a dummy value that the load logic will remove.
                            expressionExclusion.excludedRowNumbers=ranges;


                            if isempty(expressionExclusions)
                                expressionExclusions=expressionExclusion;
                            else
                                expressionExclusions(end+1)=expressionExclusion;%#ok<AGROW>
                            end
                        end
                    end
                end


                exclusionStore=struct;
                exclusionStore.manualExclusions=manualExclusions;
                exclusionStore.expressionExclusions=expressionExclusions;


                function columnClassification=loadColumnClassification(node,columnNames)


                    columnClassification=cell(numel(columnNames),1);
                    columnClassification(:)={''};


                    groupColumn=getAttribute(node,'Group');
                    if~isempty(groupColumn)
                        columnClassification{strcmp(groupColumn,columnNames)}='group';
                    end

                    independentColumn=getAttribute(node,'Independent');
                    if~isempty(independentColumn)
                        columnClassification{strcmp(independentColumn,columnNames)}='independent';
                    end


                    dependentVarCount=getAttribute(node,'DependentVariablesCount');
                    if~isempty(dependentVarCount)
                        for j=1:dependentVarCount
                            dependentVar=getAttribute(node,sprintf('DependentVariables%d',j-1));
                            if~isempty(dependentVar)
                                columnClassification{strcmp(dependentVar,columnNames)}='dependent';
                            end
                        end
                    end


                    doseVarsCount=getAttribute(node,'DoseLabelsCount');
                    if~isempty(doseVarsCount)
                        for j=1:doseVarsCount
                            doseVar=getAttribute(node,sprintf('DoseLabels%d',j-1));
                            if~isempty(doseVar)
                                columnClassification{strcmp(doseVar,columnNames)}=sprintf('dose%d',j);
                            end
                        end
                    end


                    rateVarsCount=getAttribute(node,'RateLabelsCount');
                    if~isempty(rateVarsCount)
                        for j=1:rateVarsCount
                            rateVar=getAttribute(node,sprintf('RateLabels%d',j-1));
                            if~isempty(rateVar)
                                columnClassification{strcmp(rateVar,columnNames)}=sprintf('rate%d',j);
                            end
                        end
                    end


                    covariatesCount=getAttribute(node,'CovariatesCount');
                    if~isempty(covariatesCount)
                        for j=1:covariatesCount
                            covariateVar=getAttribute(node,sprintf('Covariates%d',j-1));
                            if~isempty(covariateVar)
                                columnClassification{strcmp(covariateVar,columnNames)}='covariate';
                            end
                        end
                    end


                    function out=evaluateDerivedDataColumn(data,headings,expression)


                        dataLength=height(data);

                        workspace=matlab.internal.lang.Workspace();


                        for i=1:length(headings)
                            columnData=data.(headings{i});


                            if iscell(columnData)
                                columnData=convertToDouble(columnData);
                            end

                            assignVariable(workspace,headings{i},columnData);
                        end


                        out=struct;
                        results=[];
                        errorMsg='';

                        try
                            results=evaluateIn(workspace,expression);
                            if isa(results,'categorical')
                                results=cellstr(results);
                            end

                            if~all(size(results)==[dataLength,1])
                                errorMsg='Expression result must return a 1-by-n vector where n is the number of rows in the data.';
                            end
                        catch ex
                            errorMsg=SimBiology.web.internal.errortranslator(ex);
                        end


                        if~isempty(errorMsg)
                            results=nan(dataLength,1);
                        end

                        out.results=results;
                        out.errMsg=errorMsg;


                        function out=buildAttributeStruct(nodes,attributes,varargin)

                            out=SimBiology.web.internal.converter.utilhandler('buildAttributeStruct',nodes,attributes,varargin{:});


                            function out=getAttribute(node,attribute,varargin)

                                out=SimBiology.web.internal.converter.utilhandler('getAttribute',node,attribute,varargin{:});


                                function out=getField(node,field)

                                    out=SimBiology.web.internal.converter.utilhandler('getField',node,field);


                                    function out=getVectorAttributes(node,field)

                                        out=SimBiology.web.internal.converter.utilhandler('getVectorAttributes',node,field);


