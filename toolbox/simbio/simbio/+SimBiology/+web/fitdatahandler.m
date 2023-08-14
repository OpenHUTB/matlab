function out=fitdatahandler(action,varargin)











    switch(action)
    case 'getData'
        out=getData(varargin{:});
    end
end

function out=getData(inputs)
    data=inputs{1};
    derivedData=inputs{2};%#ok<NASGU>
    variables=inputs{3};


    results=data;

    switch class(results)
    case 'SimBiology.fit.NLMEResults'
        [tableMetaData,tables]=getDataForNLMEResults(results);
    case{'SimBiology.fit.OptimResults','SimBiology.fit.NLINResults'}
        [tableMetaData,tables]=getDataForOptimResults(results);
    case 'SimBiology.fit.ParameterConfidenceInterval'
        [tableMetaData,tables]=getDataForParameterConfidenceInterval(results);
    case 'SimBiology.fit.PredictionConfidenceInterval'
        [tableMetaData,tables]=getDataForPredictionConfidenceInterval(results);
    end



    for i=1:numel(tables)
        tables(i).tablePosition=struct('x','','y','');
        tables(i).tableSize=struct('width','','height','');
    end

    tableStruct=struct;
    tableStruct.tableMetaData=tableMetaData;
    tableStruct.tables=tables;

    variables(end).data=tableStruct;

    out=variables;

end

function[fitMetaData,tables]=getDataForOptimResults(results)


    warnState=warning('off','MATLAB:structOnObject');
    cleanup=onCleanup(@()warning(warnState));
    structResults=struct(results(1));


    groupVarName=structResults.Data.Properties.GroupVariableName;


    fitMetaData=struct;
    fitMetaData.algorithm=results(1).EstimationFunction;
    fitMetaData.estimates=results(1).EstimatedParameterNames;
    fitMetaData.responses={};
    fitMetaData.pooled=isempty(results(1).GroupName);
    fitMetaData.fixedEffect=true;
    fitMetaData.dataType='fitdata';
    fitMetaData.groupNames=structResults.DataInfo.groupNames;


    if isa(fitMetaData.groupNames,'categorical')
        fitMetaData.groupNames=cellstr(fitMetaData.groupNames);
    end


    varNames=results(1).ParameterEstimates.Properties.VariableNames;
    isCategoryVarsSpecified=numel(results)==1&&any(strcmp(varNames,'CategoryVariableName'))&&~all(strcmp(results.ParameterEstimates.CategoryVariableName,'<None>'));

    if fitMetaData.pooled

        if isCategoryVarsSpecified


            [~,index,~]=unique(results.ParameterEstimates(:,{'Name','CategoryVariableName','CategoryValue'}),'rows','stable');
            uniqueTable=results.ParameterEstimates(index,:);

            uniqueCategoryVariableNames=unique(results.ParameterEstimates.CategoryVariableName,'stable');

            idx=strcmpi(groupVarName,uniqueCategoryVariableNames);
            uniqueCategoryVariableNames(idx)={'<GroupVariableName>'};
            uniqueCategoryVariableNames=unique(uniqueCategoryVariableNames,'stable');

            estimateTable=getTableDefinition();
            estimateTable=repmat(estimateTable,numel(uniqueCategoryVariableNames),1);

            for i=1:numel(uniqueCategoryVariableNames)
                if strcmpi(uniqueCategoryVariableNames{i},'<GroupVariableName>')
                    singleCategoryVariableTable=uniqueTable(or(strcmp(uniqueTable.CategoryVariableName,'<GroupVariableName>'),...
                    strcmp(uniqueTable.CategoryVariableName,groupVarName)),:);
                else
                    singleCategoryVariableTable=uniqueTable(strcmp(uniqueTable.CategoryVariableName,uniqueCategoryVariableNames{i}),:);
                end


                tmpTable=getTableDefinition();

                switch(uniqueCategoryVariableNames{i})
                case '<None>'

                    tmpTable.name='Pooled Parameter Estimates';
                    tmpTable.datasheetDisplayIndex=1;


                    tmpTable.columnInfo=createColumnsForVarName(singleCategoryVariableTable,{'Name','Estimate','StandardError'},'','Name');

                otherwise

                    paramNames=unique(singleCategoryVariableTable.Name,'stable');

                    additionalColumnName={''};

                    if strcmp(uniqueCategoryVariableNames{i},'<GroupVariableName>')

                        tmpTable.name='Unpooled Parameter Estimates';
                        tmpTable.datasheetDisplayIndex=2;


                        groupVals=unique(singleCategoryVariableTable.Group,'stable');
                        if isa(groupVals,'categorical')
                            groupVals=cellstr(groupVals);
                        end

                        tmpTable.columnInfo=createColumn('Group',groupVals,'string','',true);
                    else

                        tmpTable.name=sprintf('%s Parameter Estimates',uniqueCategoryVariableNames{i});
                        tmpTable.datasheetDisplayIndex=3;



                        categoryVals=singleCategoryVariableTable(strcmp(singleCategoryVariableTable.Name,paramNames{1}),:).CategoryValue;
                        if isa(categoryVals,'categorical')
                            categoryVals=cellstr(categoryVals);
                        end

                        additionalColumnName='Category Variable';

                        tmpTable.columnInfo=createColumn(uniqueCategoryVariableNames{i},categoryVals,'string','',true);
                    end

                    for j=1:numel(paramNames)
                        paramTable=singleCategoryVariableTable(strcmp(singleCategoryVariableTable.Name,paramNames{j}),:);
                        tmpTable.columnInfo=vertcat(tmpTable.columnInfo,createColumnsForVarName(paramTable,{'Estimate','StandardError'},'',''));
                    end

                    tmpTable.additionalRows.columnNames=horzcat(additionalColumnName,repeatElements(paramNames,2));


                    spans=ones(1,numel(tmpTable.additionalRows.columnNames))*-1;
                    spans(2:2:end)=2;
                    spans(1)=1;
                    tmpTable.additionalRows.spans=spans;
                end

                estimateTable(i)=tmpTable;
            end
        else

            estimateTable=getTableDefinition();
            estimateTable.name='Pooled Parameter Estimates';
            estimateTable.datasheetDisplayIndex=1;



            paramEstimateTable=results.ParameterEstimates(1:numel(results.EstimatedParameterNames),:);
            estimateTable.columnInfo=createColumnsForVarName(paramEstimateTable,{'Name','Estimate','StandardError'},'',{'Name'});
        end
    else

        estimateTable=getTableDefinition();
        estimateTable.name='Unpooled Parameter Estimates';
        estimateTable.datasheetDisplayIndex=1;


        estimateTable.columnInfo=getDataFromTableForUnpooledFit(results,'ParameterEstimates');


        estimatedParamNames=results(1).EstimatedParameterNames;
        estimateTable.additionalRows.columnNames=horzcat({''},repeatElements(estimatedParamNames,2));


        spans=ones(1,numel(estimateTable.additionalRows.columnNames))*-1;
        spans(2:2:end)=2;
        estimateTable.additionalRows.spans=spans;
    end

    tables=estimateTable;


    statisticsTable=getTableDefinition();
    statisticsTable.name='Statistics';
    statisticsTable.datasheetDisplayIndex=4;

    statsNames={'AIC','BIC','LogLikelihood','DFE','MSE','SSE'};

    if fitMetaData.pooled
        statisticsTable.reshapeForComparison=true;
        statisticsTable.allowSorting=true;


        statisticsTable.columnInfo(1)=createColumn('Name',statsNames,'string','',true);


        values=repmat({''},1,numel(statsNames));
        for i=1:numel(statsNames)
            statValue=results.(statsNames{i});
            if isempty(statValue)
                statValue='Not available';
            end
            values{i}=statValue;
        end


        statisticsTable.columnInfo(2)=createColumn('Value',values,'double','',false);
    else


        statisticsTable.columnInfo(1)=createColumn('Group',cellstr([results.GroupName]),'string','',true);


        for i=1:numel(statsNames)
            statValues=vertcat(results.(statsNames{i}));
            if isempty(statValues)
                values=repmat({'Not available'},numel(results),1);
            else
                values=vertcat(results.(statsNames{i}));
            end

            statisticsTable.columnInfo(end+1)=createColumn(statsNames{i},values,'double','',false);
        end
    end


    tables=vertcat(tables,statisticsTable);

    if fitMetaData.pooled

        if isCategoryVarsSpecified


            [~,index,~]=unique(results.Beta(:,{'Name','CategoryVariableName','CategoryValue'}),'rows','stable');
            uniqueTable=results.Beta(index,:);

            uniqueCategoryVariableNames=unique(results.Beta.CategoryVariableName,'stable');

            idx=strcmpi(groupVarName,uniqueCategoryVariableNames);
            uniqueCategoryVariableNames(idx)={'<GroupVariableName>'};
            uniqueCategoryVariableNames=unique(uniqueCategoryVariableNames,'stable');

            betaTable=getTableDefinition();
            betaTable=repmat(betaTable,numel(uniqueCategoryVariableNames),1);

            for i=1:numel(uniqueCategoryVariableNames)
                if strcmpi(uniqueCategoryVariableNames{i},'<GroupVariableName>')
                    singleCategoryVariableTable=uniqueTable(or(strcmp(uniqueTable.CategoryVariableName,'<GroupVariableName>'),...
                    strcmp(uniqueTable.CategoryVariableName,groupVarName)),:);
                else
                    singleCategoryVariableTable=uniqueTable(strcmp(uniqueTable.CategoryVariableName,uniqueCategoryVariableNames{i}),:);
                end


                tmpTable=getTableDefinition();

                switch(uniqueCategoryVariableNames{i})
                case '<None>'

                    tmpTable.name='Pooled Beta';
                    tmpTable.datasheetDisplayIndex=5;


                    tmpTable.columnInfo=createColumnsForVarName(singleCategoryVariableTable,{'Name','Estimate','StandardError'},'','Name');

                otherwise
                    paramNames=unique(singleCategoryVariableTable.Name,'stable');

                    additionalColumnName={''};

                    if strcmp(uniqueCategoryVariableNames{i},'<GroupVariableName>')

                        tmpTable.name='Unpooled Beta';
                        tmpTable.datasheetDisplayIndex=6;


                        groupVals=unique(singleCategoryVariableTable.CategoryValue,'stable');
                        if isa(groupVals,'categorical')
                            groupVals=cellstr(groupVals);
                        end

                        tmpTable.columnInfo=createColumn('Group',groupVals,'string','',true);
                    else

                        tmpTable.name=sprintf('%s Beta',uniqueCategoryVariableNames{i});
                        tmpTable.datasheetDisplayIndex=7;



                        categoryVals=singleCategoryVariableTable(strcmp(singleCategoryVariableTable.Name,paramNames{1}),:).CategoryValue;
                        if isa(categoryVals,'categorical')
                            categoryVals=cellstr(categoryVals);
                        end

                        additionalColumnName='Category Variable';

                        tmpTable.columnInfo=createColumn(uniqueCategoryVariableNames{i},categoryVals,'string','',true);
                    end

                    for j=1:numel(paramNames)
                        paramTable=singleCategoryVariableTable(strcmp(singleCategoryVariableTable.Name,paramNames{j}),:);
                        tmpTable.columnInfo=vertcat(tmpTable.columnInfo,createColumnsForVarName(paramTable,{'Estimate','StandardError'},'',''));
                    end

                    tmpTable.additionalRows.columnNames=horzcat(additionalColumnName,repeatElements(paramNames,2));


                    spans=ones(1,numel(tmpTable.additionalRows.columnNames))*-1;
                    spans(2:2:end)=2;
                    spans(1)=1;
                    tmpTable.additionalRows.spans=spans;
                end

                betaTable(i)=tmpTable;
            end
        else

            betaTable=getTableDefinition();
            betaTable.name='Pooled Beta';
            betaTable.datasheetDisplayIndex=5;


            betaTable.columnInfo=createColumnsForVarName(results.Beta,{'Name','Estimate','StandardError'},'',{'Name'});
        end
    else

        betaTable=getTableDefinition();
        betaTable.name='Unpooled Beta';
        betaTable.datasheetDisplayIndex=5;


        betaTable.columnInfo=getDataFromTableForUnpooledFit(results,'Beta');


        estimatedParamNames=results(1).EstimatedParameterNames;
        betaTable.additionalRows.columnNames=horzcat({''},repelem(estimatedParamNames,2));


        spans=ones(1,numel(betaTable.additionalRows.columnNames))*-1;
        spans(2:2:end)=2;
        betaTable.additionalRows.spans=spans;
    end


    tables=vertcat(tables,betaTable);



    residualsTable=getTableDefinition();
    residualsTable.name='Residuals';
    residualsTable.mergeUsingGroups=false;
    residualsTable.datasheetDisplayIndex=8;



    residuals=getResidualTable(results);
    columnNames=residuals.Properties.VariableNames;
    residualsTable.columnInfo=createColumnsForVarName(residuals,columnNames,'',{columnNames{1}});



    tables=vertcat(tables,residualsTable);


    if~isempty(results(1).Weights)

        weightsTable=getTableDefinition();
        weightsTable.name='Weights';
        weightsTable.mergeUsingGroups=false;
        weightsTable.mergeWithRepetition=true;
        weightsTable.datasheetDisplayIndex=9;

        if fitMetaData.pooled
            weights=results.Weights;


            if isa(weights,'function_handle')
                weightsTable.columnInfo(1)=createColumn('Group',ones(1,numel(weights)),'string','',true);
                weightsTable.columnInfo(2)=createColumn('Weight',func2str(weights),'string','',false);
            else
                weightsTable.columnInfo(1)=createColumn('Group',ones(1,numel(weights)),'string','',true);
                weightsTable.columnInfo(2)=createColumn('Weight',weights,'double','',false);
            end
        else

            weights=results(1).Weights;

            if isa(weights,'function_handle')
                weightsTable.columnInfo(1)=createColumn('Group',cellstr([results.GroupName]),'string','',true);
                weightsTable.columnInfo(2)=createColumn('Weight',repelem({func2str(weights)},1,numel([results.GroupName])),'string','',false);
            else
                groupColumnData={};
                for i=1:numel(results)

                    groupColumnData=vertcat(groupColumnData,repelem(results(i).GroupName,size(results(i).Weights,1))');%#ok<AGROW>
                end

                weightsTable.columnInfo(1)=createColumn('Group',cellstr(groupColumnData),'string','',true);
                weightsTable.columnInfo(2)=createColumn('Weight',vertcat(results.Weights),'double','',false);
            end
        end


        tables=vertcat(tables,weightsTable);
    end



    covMatrixTable=getTableDefinition();
    covMatrixTable.name='Covariance Matrix';
    covMatrixTable.datasheetDisplayIndex=10;

    if fitMetaData.pooled
        betaTable=results.Beta;
        estimatedParameterNames=betaTable{:,'Name'};
        if any(strcmp(betaTable.Properties.VariableNames,'CategoryVariableName'))
            categoryVariableNames=results.Beta{:,'CategoryVariableName'};
            categoryValues=results.Beta{:,'CategoryValue'};
        else
            categoryVariableNames=repmat({'<None>'},1,numel(estimatedParameterNames));
            categoryValues=[];
        end

        estimatedParameters=repmat({''},1,numel(estimatedParameterNames));
        for i=1:numel(estimatedParameterNames)
            if strcmpi(categoryVariableNames{i},'<None>')
                estimatedParameters{i}=estimatedParameterNames{i};
            else
                if strcmpi(categoryVariableNames{i},'<GroupVariableName>')
                    categoryVariable=groupVarName;
                else
                    categoryVariable=categoryVariableNames{i};
                end
                estimatedParameters{i}=[estimatedParameterNames{i},' (',categoryVariable,'=',char(categoryValues(i)),')'];
            end
        end
        covMatrixTable.columnInfo(1)=createColumn('Name',estimatedParameters,'double','',true);

        for i=1:numel(estimatedParameters)
            covMatrixTable.columnInfo(i+1)=createColumn(estimatedParameters{i},results.CovarianceMatrix(:,i),'double','',false);
        end
    else

        groupNames=cellstr([results.GroupName]);


        estimatedParameters=results(1).Beta{:,'Name'}';


        groupNameData=repelem(groupNames,numel(estimatedParameters));
        covMatrixTable.columnInfo(1)=createColumn('Group',groupNameData,'string','',true);


        estimatedParameterData=repmat(estimatedParameters,1,numel(groupNames));
        covMatrixTable.columnInfo(2)=createColumn('Parameters',estimatedParameterData,'string','',true);

        covMatrix=vertcat(results.CovarianceMatrix);
        for i=1:numel(estimatedParameters)
            covMatrixTable.columnInfo(i+2)=createColumn(estimatedParameters{i},covMatrix(:,i),'double',estimatedParameters{i},false);
        end
    end


    tables=vertcat(tables,covMatrixTable);


    errorModelTable=getTableDefinition();
    errorModelTable.name='Error Model';
    errorModelTable.datasheetDisplayIndex=11;

    if fitMetaData.pooled

        varNames=results.ErrorModelInfo.Properties.VariableNames;


        responseNames=results.ErrorModelInfo.Row;
        if isempty(responseNames)
            responseNames={''};
        end

        errorModelTable.columnInfo=createColumn('Response',responseNames,'string','',true);


        errorModelTable.columnInfo=vertcat(errorModelTable.columnInfo,createColumnsForVarName(results.ErrorModelInfo,varNames,'','ErrorModel'));
    else

        responses=results(1).ErrorModelInfo.Row;
        if isempty(responses)
            responses={''};
        end


        groupNames=cellstr([results.GroupName]);
        errorModelTable.columnInfo(1)=createColumn('Group',repelem(groupNames,numel(responses)),'string','',true);


        responses=repmat(responses,numel(groupNames),1);
        errorModelTable.columnInfo(2)=createColumn('Response',responses,'string','',true);


        tableObjs={results.ErrorModelInfo};


        for i=1:numel(tableObjs)
            tableObjs{i}.Properties.RowNames={};
        end


        singleErrorModelTable=vertcat(tableObjs{:});

        errorModelTable.columnInfo=vertcat(errorModelTable.columnInfo',createColumnsForVarName(singleErrorModelTable,singleErrorModelTable.Properties.VariableNames,'',''));
    end


    tables=vertcat(tables,errorModelTable);

end

function[fitMetaData,tables]=getDataForNLMEResults(results)


    fitMetaData=struct;
    fitMetaData.algorithm=results.EstimationFunction;
    fitMetaData.estimates=results.EstimatedParameterNames;
    fitMetaData.responses={};
    fitMetaData.groupNames=unique(results.PopulationParameterEstimates.Group,'stable');
    fitMetaData.pooled=false;
    fitMetaData.fixedEffect=false;
    fitMetaData.dataType='fitdata';


    if isa(fitMetaData.groupNames,'categorical')
        fitMetaData.groupNames=cellstr(fitMetaData.groupNames);
    end


    populationEstimatesTable=getTableDefinition();
    populationEstimatesTable.name='Population Estimates';
    populationEstimatesTable.datasheetDisplayIndex=1;

    populationEstimatesTable.columnInfo=getPopulationFitColumnsFromTable(results,'PopulationParameterEstimates');


    individualEstimatesTable=getTableDefinition();
    individualEstimatesTable.name='Individual Estimates';
    individualEstimatesTable.datasheetDisplayIndex=2;

    individualEstimatesTable.columnInfo=getPopulationFitColumnsFromTable(results,'IndividualParameterEstimates');


    statisticsTable=getTableDefinition();
    statisticsTable.name='Statistics';
    statisticsTable.reshapeForComparison=true;
    statisticsTable.allowSorting=true;
    statisticsTable.datasheetDisplayIndex=3;

    statsVars={'AIC','BIC','LogLikelihood','DFE'};
    statisticsTable.columnInfo(1)=createColumn('Name',statsVars,'string','',true);

    statsValues=cell(numel(statsVars),1);
    [statsValues{:}]=deal('');

    for i=1:numel(statsVars)
        if~isempty(results.(statsVars{i}))
            statsValues{i}=results.(statsVars{i});
        end
    end

    statisticsTable.columnInfo(2)=createColumn('Value',statsValues,'string','',false);


    fixedEffectsTable=getTableDefinition();
    fixedEffectsTable.name='Fixed Effects';
    fixedEffectsTable.datasheetDisplayIndex=4;

    fixedEffects=results.FixedEffects;


    randomEffectsTable=getTableDefinition();
    randomEffectsTable.name='Random Effects';
    randomEffectsTable.datasheetDisplayIndex=5;

    randomEffectsTable.columnInfo=getPopulationFitColumnsFromTable(results,'RandomEffects');


    showStandardError=any(strcmp('StandardError',fixedEffects.Properties.VariableNames));
    if showStandardError
        fixedEffectsTable.columnInfo(1)=createColumn('Type',{'Estimate','StandardError'},'string','',true);
    else
        fixedEffectsTable.columnInfo(1)=createColumn('Type',{'Estimate'},'string','',true);
    end


    for i=1:height(fixedEffects)
        row=fixedEffects(i,:);
        if showStandardError
            data=[row.Estimate;row.StandardError];
        else
            data=[row.Estimate];
        end

        fixedEffectsTable.columnInfo(end+1)=createColumn(row.Name{1},data,'string','',false);
    end


    randomEffectCovMatrixTable=getTableDefinition();
    randomEffectCovMatrixTable.name='Random Effects Covariance Matrix';
    randomEffectCovMatrixTable.datasheetDisplayIndex=6;

    randomEffectCovMatrix=results.RandomEffectCovarianceMatrix;


    etaNames=randomEffectCovMatrix.Properties.VariableNames;
    randomEffectCovMatrixTable.columnInfo(1)=createColumn('Eta',etaNames,'string','',true);


    for i=1:numel(etaNames)
        randomEffectCovMatrixTable.columnInfo(i+1)=createColumn(etaNames{i},randomEffectCovMatrix.(etaNames{i}),'double','',false);
    end


    errorModelTable=getTableDefinition();
    errorModelTable.name='Error Model';
    errorModelTable.datasheetDisplayIndex=7;

    errorModelInfo=results.ErrorModelInfo;


    responseNames=errorModelInfo.Properties.RowNames;
    if isempty(responseNames)
        responseNames={''};
    end

    errorModelTable.columnInfo(1)=createColumn('Response',responseNames,'string','',true);


    errorModelType=cellstr(errorModelInfo.ErrorModel);
    errorModelTable.columnInfo(2)=createColumn('ErrorModel',errorModelType,'string','',true);

    errorModelVariables=errorModelInfo.Properties.VariableNames(2:end);


    for i=1:numel(errorModelVariables)
        errorModelTable.columnInfo(i+2)=createColumn(errorModelVariables{i},errorModelInfo.(errorModelVariables{i}),'double','',false);
    end


    tables=[populationEstimatesTable,individualEstimatesTable,randomEffectsTable,fixedEffectsTable,randomEffectCovMatrixTable,statisticsTable,errorModelTable];

end

function out=repeatElements(elements,num)
    out=repelem(elements,num);
    out=reshape(out,1,length(out));
end

function[fitMetaData,parameterCITable]=getDataForParameterConfidenceInterval(results)


    fitMetaData=struct;
    fitMetaData.dataType='parameterConfidenceInterval';


    paramCITable=ci2table(results);
    varNames=paramCITable.Properties.VariableNames;

    parameterCITable=getTableDefinition();
    parameterCITable.columnInfo=createColumnsForVarName(paramCITable,varNames,'','');

    parameterCITable.tableType='rawdata';
end

function[fitMetaData,predictionCITable]=getDataForPredictionConfidenceInterval(results)


    fitMetaData=struct;
    fitMetaData.dataType='predictionConfidenceInterval';


    predCITable=vertcat(results.Results);
    varNames=predCITable.Properties.VariableNames;

    predictionCITable=getTableDefinition();
    predictionCITable.columnInfo=createColumnsForVarName(predCITable,varNames,'','');

    predictionCITable.tableType='rawdata';
end

function out=getPopulationFitColumnsFromTable(results,prop)

    estimates=results.(prop);

    groups=unique(estimates.Group,'stable');
    groups=cellstr(groups);

    paramNames=results.EstimatedParameterNames;
    numParams=numel(paramNames);
    propTables=cell(1,numParams);

    out=getColumnStructDefinition();
    out=repmat(out,numParams+1,1);

    out(1)=createColumn('Group',groups,'string','',true);


    estimates=estimates(:,2:end);


    for i=1:numParams
        propTables{i}=estimates(i:numParams:end,:);
    end

    for i=1:numel(propTables)
        column=createColumnsForVarName(propTables{i},{'Estimate'},paramNames{i},'Group');
        column.name=paramNames{i};
        out(i+1)=column;
    end
end

function columnInfo=getDataFromTableForUnpooledFit(results,propName)


    tableObjs={results.(propName)};


    for i=1:numel(tableObjs)
        tableObjs{i}.Properties.RowNames={};
    end


    propValue=vertcat(tableObjs{:});


    paramNames=results(1).EstimatedParameterNames;
    numParams=numel(paramNames);



    propTables=cell(1,numParams);


    for i=1:numParams
        propTables{i}=propValue(i:numParams:end,:);
    end


    columnInfo(1)=createColumn('Group',cellstr([results.GroupName]),'string','',true);

    for i=1:numParams
        varNames={'Estimate','StandardError'};

        columns=createColumnsForVarName(propTables{i},varNames,paramNames{i},'Group');


        columnInfo=vertcat(columnInfo,columns);%#ok<AGROW>
    end
end

function out=createColumnsForVarName(tableObj,varNames,paramName,commonColumnNames)

    out=getColumnStructDefinition();
    out=repmat(out,numel(varNames),1);

    for i=1:numel(varNames)
        data=tableObj.(varNames{i});
        if isa(data,'categorical')
            data=cellstr(data);
        elseif size(data,2)>1
            data=num2cell(data,2);
        end
        out(i)=createColumn(varNames{i},data,'double',paramName,any(strcmp(varNames{i},commonColumnNames)));
    end
end

function out=createColumn(name,data,dataType,propName,isCommon)


    data=SimBiology.web.datahandler('scrubData',data);

    out=getColumnStructDefinition();
    out.classification='';
    out.data=data;
    out.expression='';
    out.name=name;
    out.numRows=numel(out.data);
    out.type=dataType;
    out.units='';
    out.propName=propName;
    out.isCommon=isCommon;
end

function out=getColumnStructDefinition()
    out=struct('classification','','data','','expression','','name','','numRows','','type','','units','','propName','','isCommon',false);
end

function out=getTableDefinition()
    out=struct('name','','reshapeForComparison',false,'allowSorting',false,'additionalRows',[],'mergeUsingGroups',true,'mergeWithRepetition',false,'tableType','fitdata','displayType','','columnInfo',getColumnStructDefinition(),'datasheetDisplayIndex',100);
end

