function[out,varargout]=datahandler(action,varargin)











    out={action};

    switch(action)
    case 'getdata'
        out=getresults(action,varargin{1});
    case 'getDataInfo'
        [out,varargout{1}]=getdataInfo(varargin{:});
    case 'getExternalDataInfo'
        out=getExternalDataInfo(varargin{1});
    case 'saveData'
        out=saveData(action,varargin{1});
    case 'deleteData'
        deleteData(varargin{:});
    case 'deleteModelCache'
        deleteModelCache(varargin{1});
    case 'deleteDataCache'
        deleteDataCache(varargin{1});
    case 'saveDataToMATFile'
        saveDataToMATFile(varargin{:});
    case 'saveDatasToMATFile'
        saveDatasToMATFile(varargin{:});
    case 'deleteProgram'
        deleteProgram(varargin{:})
    case 'exportDataToWorkspace'
        out=exportDataToWorkspace(action,varargin{:});
    case 'evaluateExpression'
        out=evaluateExpression(varargin{:});
    case 'deleteExpressionColumn'
        out=deleteExpressionColumn(varargin{:});
    case 'evaluateExclusion'
        out=evaluateExclusion(varargin{:});
    case 'renameExpressionColumn'
        out=renameExpressionColumn(varargin{:});
    case 'getMultiRunData'
        out=getMultiRunData(varargin{:});
    case 'getDataWithPostProcessing'
        out=getDataWithPostProcessing(action,varargin{1});
    case 'exportDatasheetToFile'
        out=exportDatasheetToFile(action,varargin{1});
    case 'loadDatasheet'
        out=loadDatasheet(action,varargin{1});
    case 'scrubData'
        out=scrubData(varargin{1});
    case 'getRangesFromArray'
        out=getRangesFromArray(varargin{1});
    case 'getArrayFromRanges'
        out=getArrayFromRanges(varargin{1});
    case 'getDataWithExclusions'
        out=getDataWithExclusions(varargin{:});
    case 'getIncludedGroups'
        out=getIncludedGroups(action,varargin{:});
    case 'duplicateData'
        out=duplicateData(action,varargin{:});
    case 'columnClassificationChanged'
        out=columnClassificationChanged(varargin{:});
    case 'verifyAndUpdateUnits'
        out=verifyAndUpdateUnits(varargin{:});
    case 'getSimdataScalarObservables'
        out=getSimdataScalarObservables(varargin{:});
    case 'getSimDataInfo'
        [out,varargout{1}]=getSimDataInfo(varargin{:});
    case 'getWarningForColumnName'
        out=getWarningForColumnName(varargin{:});
    case 'getColumnInfoFromDataInfo'
        out=getColumnInfoFromDataInfo(varargin{:});
    case 'getWorkspaceColumnInfo'
        out=getWorkspaceColumnInfo();
    end


end

function out=getresults(action,inputs)

    variables=inputs.variables;
    variablesOut=[];

    for i=1:length(variables)
        next=variables(i);
        next.data=[];


        data=loadVariable(next.MATFile,next.MATFileVariableName);
        derivedData=loadVariable(next.MATFile,next.MATFileDerivedVariableName);

        if isempty(variablesOut)
            variablesOut=next;
        else
            variablesOut(end+1)=next;
        end

        if strcmp(next.SourceType,'programdata')
            data=data.(next.StructFieldName);
        end

        switch(next.type)
        case 'SimDataWithSensitivity'
            variablesOut(end).data=data;
        case{'DerivedDataAll','deriveddata'}


            if isempty(derivedData)
                break;
            end

            if strcmp(next.SourceType,'programdata')
                derivedData=derivedData.(next.StructFieldName);
            end

            inputs.numRuns=numel(data);





            runColumnName='SimDataRun';

            if inputs.numRuns>1

                variablesOut(end).data=derivedData.(runColumnName);
                variablesOut(end).ColumnName=runColumnName;
                variablesOut(end+1)=next;
            end



            variablesOut(end).data=vertcat(data.Time);
            variablesOut(end).ColumnName='time';


            names=setdiff(derivedData.Properties.VariableNames,runColumnName);


            for j=1:length(names)
                variablesOut(end+1)=next;
                variablesOut(end).ColumnName=names{j};
                variablesOut(end).data=derivedData.(names{j});
            end

        case 'SimData'

            inputs.numRuns=numel(data);
            data=getMultiRunData(data);




            startIndex=1;
            if(inputs.numRuns==1)
                startIndex=2;
            end


            variablesOut(end).data=data(startIndex).value;
            variablesOut(end).ColumnName=data(startIndex).name;


            for j=startIndex+1:length(data)
                variablesOut(end+1)=next;
                variablesOut(end).ColumnName=data(j).name;
                variablesOut(end).data=data(j).value;
            end

        case 'simDataScalarObservablesFolder'



            scalarObservables=getSimdataScalarObservables(data);
            if next.vectorize
                data=getMultiRunData(data);
                data=data(ismember({data.name},scalarObservables.Properties.VariableNames));

                variablesOut(end).data=data(1).value;
                variablesOut(end).ColumnName=data(1).name;

                for j=2:numel(data)
                    variablesOut(end+1)=next;
                    variablesOut(end).data=data(j).value;
                    variablesOut(end).ColumnName=data(j).name;
                end
            else
                inputs.numRuns=numel(data);
                columnNames=scalarObservables.Properties.VariableNames;


                variablesOut(end).data=scalarObservables.(columnNames{1});
                variablesOut(end).ColumnName=columnNames{1};


                for j=2:length(columnNames)
                    variablesOut(end+1)=next;
                    variablesOut(end).ColumnName=columnNames{j};
                    variablesOut(end).data=scalarObservables.(columnNames{j});
                end
            end

        case 'simDataScalarObservableColumn'
            inputs.numRuns=numel(data);

            scalarObservables=getSimdataScalarObservables(data);
            columnNames=scalarObservables.Properties.VariableNames;



            if inputs.numRuns>1&&~any(strcmp('SimDataRun',{variablesOut.ColumnName}))

                variablesOut(end).data=scalarObservables.(columnNames{1});
                variablesOut(end).ColumnName=columnNames{1};
                variablesOut(end+1)=next;
            end

            if ismember(next.ColumnName,columnNames)

                variablesOut(end).data=scalarObservables.(next.ColumnName);
                variablesOut(end).ColumnName=next.ColumnName;
            end

        case 'SimDataColumn'


            inputs.numRuns=numel(data);

            simdatainfo=getMultiRunData(data);

            if inputs.numRuns>1
                if~any(strcmp('SimDataRun',{variablesOut.ColumnName}))
                    index=find(strcmp('SimDataRun',{simdatainfo.name}));
                    tmp=variablesOut(end);
                    variablesOut(end).data=simdatainfo(index).value;%#ok<FNDSB>
                    variablesOut(end).ColumnName='SimDataRun';
                    variablesOut(end+1)=tmp;
                end
            end

            if strcmp(next.ColumnName,'time')

                variablesOut(end).data=getsimdata(simdatainfo,'time');
            else

                variablesOut(end).data=getsimdata(simdatainfo,next.ColumnName);
            end

        case 'SimDataRun'
            simdataobj=data;
            inputs.numRuns=numel(simdataobj);
            simdatainfo=getMultiRunData(simdataobj);
            variablesOut(end).data=simdatainfo(1).value;

        case 'tableColumn'
            columnNames=data.Properties.VariableNames;

            if any(strcmp(next.ColumnName,columnNames))
                variablesOut(end).data=data.(next.ColumnName);

            elseif~isempty(derivedData)
                columnNames=derivedData.Properties.VariableNames;
                if any(strcmp(next.ColumnName,columnNames))
                    variablesOut(end).data=derivedData.(next.ColumnName);
                end
            end

        case 'table'
            columnNames=data.Properties.VariableNames;


            variablesOut(end).data=data.(columnNames{1});
            variablesOut(end).ColumnName=columnNames{1};


            for j=2:length(columnNames)
                variablesOut(end+1)=next;
                variablesOut(end).ColumnName=columnNames{j};
                variablesOut(end).data=data.(columnNames{j});
            end




            if~isempty(derivedData)&&istable(derivedData)
                columnNames=derivedData.Properties.VariableNames;

                for j=1:length(columnNames)
                    variablesOut(end+1)=next;
                    variablesOut(end).ColumnName=columnNames{j};
                    variablesOut(end).data=derivedData.(columnNames{j});
                end
            end

        case 'SimBiology.Scenarios'
            samples=data.generate;


            columnNames=samples.Properties.VariableDescriptions';


            propNames=samples.Properties.VariableNames;


            for j=1:length(columnNames)
                if j==1
                    variablesOut(end)=next;
                else
                    variablesOut(end+1)=next;
                end

                variablesOut(end).ColumnName=columnNames{j};


                data=samples.(propNames{j});



                if isa(data,'SimBiology.Variant')
                    variablesOut(end).ColumnName=sprintf('%s (%s)',columnNames{j},'variant');
                    variantNames=get(data,{'Name'});
                    variantNames=reshape(variantNames,size(data));
                    variablesOut(end).data=convertToOneDimensional(variantNames);
                elseif isa(data,'SimBiology.RepeatDose')||isa(data,'SimBiology.Dose')||isa(data,'SimBiology.ScheduleDose')
                    variablesOut(end).ColumnName=sprintf('%s (%s)',columnNames{j},'dose');
                    doseNames=get(data,{'Name'});
                    doseNames=reshape(doseNames,size(data));
                    variablesOut(end).data=convertToOneDimensional(doseNames);
                else
                    variablesOut(end).data=data;
                end
            end

        case 'double'
            variablesOut(end).data=data;

        case{'logical','char','cell','categorical'}
            variablesOut(end).data=data;

        case 'SimBiology.Variant'
            variants=data;



            variantTable=table;
            for j=1:numel(variants)
                if~isempty(variants(j).Content)
                    t=cell2table(vertcat(variants(j).Content{:}));
                    t(:,3)=[];


                    t.Properties.VariableNames={'Type','Name',variants(j).Name};

                    if~isempty(variantTable)



                        if isnumeric(t{:,3})
                            t.(variants(j).Name)=num2str(t{:,3});
                        end
                        variantTable=outerjoin(variantTable,t,'Keys',{'Type','Name'},'RightVariables',variants(j).Name);
                    else
                        variantTable=t;
                    end
                end
            end


            propNames=variantTable.Properties.VariableNames;
            for j=1:numel(propNames)
                if j>1
                    variablesOut(end+1)=next;%#ok<*AGROW>
                end


                variablesOut(end).data=variantTable.(propNames{j});
                variablesOut(end).ColumnName=propNames{j};
            end

        case{'SimBiology.fit.OptimResults','SimBiology.fit.NLINResults','SimBiology.fit.NLMEResults','SimBiology.fit.ParameterConfidenceInterval','SimBiology.fit.PredictionConfidenceInterval'}
            variablesOut=SimBiology.web.fitdatahandler('getData',{data,derivedData,variablesOut});

        case{'SimBiology.gsa.Sobol','SimBiology.gsa.MPGSA','SimBiology.gsa.ElementaryEffects'}
            variablesOut=SimBiology.web.gsahandler('getData',{data,derivedData,variablesOut});
        end
    end

    for i=1:length(variablesOut)
        if isfield('data',variablesOut(i))
            data=variablesOut(i).data;
            if isa(data,'categorical')
                variablesOut(i).data=cellstr(data);
            end
        end
    end

    inputs.variables=variablesOut;

    out={action,inputs};

end

function out=getsimdata(simdatainfo,columnName)

    out=[];

    for i=1:length(simdatainfo)
        if strcmp(simdatainfo(i).name,columnName)
            out=simdatainfo(i).value;
            return;
        end
    end

end

function out=getSimdataScalarObservables(simdata)

    variableNames={};

    obs={simdata.ScalarObservables};


    for i=1:length(obs)
        variableNames=horzcat(variableNames,obs{i}.Properties.VariableNames);
    end
    variableNames=unique(variableNames,'stable');


    filterIdx=true(size(variableNames));
    for i=1:length(variableNames)
        selectedSimData=simdata.selectbyname(variableNames{i});
        dataInfo=vertcat(selectedSimData.DataInfo);
        filterIdx(i)=any(cellfun(@(x)(~strcmpi(x.Type,'observable')||(strcmpi(x.Type,'observable')&&~x.Scalar)),dataInfo));
    end
    variableNames=variableNames(~filterIdx);


    out=nan(numel(simdata),numel(variableNames));


    map=containers.Map;

    for i=1:numel(simdata)
        scalarObs=simdata(i).ScalarObservables;
        props=scalarObs.Properties.VariableNames;
        for j=1:numel(variableNames)
            if ismember(variableNames{j},props)
                out(i,j)=scalarObs.(variableNames{j});
            end
        end

        dataInfo=simdata(i).DataInfo;
        for k=1:numel(dataInfo)
            if isfield(dataInfo{k},'Scalar')&&dataInfo{k}.Scalar
                map(dataInfo{k}.Name)=dataInfo{k}.Expression;
            end
        end
    end

    out=array2table(out);
    out.Properties.VariableNames=variableNames;
    out.Properties.UserData=values(map,variableNames);


    if numel(variableNames)>0&&numel(simdata)>1
        runCol=1:height(out);
        out.SimDataRun=runCol';
        out=movevars(out,'SimDataRun','Before',1);
        out.Properties.UserData=horzcat({''},out.Properties.UserData);
    end

end

function[out,varargout]=getdataInfo(input)

    if isfield(input,'additionalArgs')
        associatedDataObj=input.additionalArgs;
    else
        associatedDataObj=[];
    end

    dataInfo=[];
    next=input.next;
    outputName=input.name;


    info=[];
    info.name=outputName;
    info.rows=size(next,1);
    info.columns=size(next,2);
    info.size=sprintf('%dx',size(next));
    info.size=info.size(1:end-1);
    info.isMultiRun=false;
    info.dataLength='';




    info.unitsConverted='none';

    if isa(next,'SimData')
        [simdataInfo,names]=getSimDataInfo(next);
        dataInfo=SimBiology.web.simdatainfohandler('getDataInfoForSimData',next,associatedDataObj);

        info.name=outputName;
        info.type='SimData';
        info.dataLength=getSimDataLength(next);
        info.columnTypes=simdataInfo.types;
        info.columnUnits=simdataInfo.units;
        info.isObservable=simdataInfo.isObservable;
        info.isScalar=simdataInfo.isScalar;
        info.columnNames=names;
        info.value=[];
        dataCount=get(next(1),'DataCount');
        info.hasSensitivity=(dataCount.Sensitivity~=0);
        info.expressions=simdataInfo.expressions;
        info.errorMsgs=simdataInfo.errorMsgs;
        info.isMultiRun=numel(next)>1;
        info.unitsConverted=getUnitConversionState(next);


        info.categoryVariables=arrayfun(@(catVar)catVar.getStruct(true),[dataInfo.scalarParameters.categoryVariable]);
        info.associatedDataSources=arrayfun(@(ds)ds.getStruct(),dataInfo.associatedDataSources);

    elseif isa(next,'table')
        info.type='table';
        info.columnNames=next.Properties.VariableNames;
        info.columnTypes=getColumnTypes(next);
        info.dataLength=info.rows;
        info.value=[];
        info.expressions=next.Properties.UserData;


        groupInfo=getGroupingInfo(next);
        info.groupType=groupInfo.groupType;
        info.groupValue=groupInfo.groupValue;


        if isfield(input,'nonmem')
            nonmemInfo=input.nonmem;
        else
            nonmemInfo=struct('nonmemInterpretation',false);
        end


        info.columnClassification=getTableColumnClassifications(next,info.columnNames,nonmemInfo);


        if~nonmemInfo.nonmemInterpretation&&~isempty(next.Properties.VariableUnits)
            for i=numel(info.columnNames):-1:1
                info.columnUnits{i}=next.Properties.VariableUnits{strcmp(next.Properties.VariableNames,info.columnNames{i})};
            end
        else
            info.columnUnits=repmat({''},size(info.columnNames));
        end
    else
        info.type=class(next);
        info.value=[];
        info.dataLength='';
        if islogical(next)
            info.value=getValueForLogical(next);
        end
    end
    out=info;
    varargout{1}=dataInfo;

end

function columnInfo=getColumnInfoFromDataInfo(info,data)


    numColumns=numel(info.columnNames);
    columnInfo=getWorkspaceColumnInfo();
    isMultiRun=numel(data)>1;
    isSimData=isa(data,'SimData');

    if isSimData&&isMultiRun
        columnInfo=repmat(columnInfo,numColumns+1,1);
        index=1;

        columnInfo(1).name='SimDataRun';
        columnInfo(1).type='double';
        columnInfo(1).classification='run';
    else
        columnInfo=repmat(columnInfo,numColumns,1);
        index=0;
    end

    for i=1:numColumns
        columnInfo(i+index).name=info.columnNames{i};
        columnInfo(i+index).type=info.columnTypes{i};
        columnInfo(i+index).units=info.columnUnits{i};
        if~isempty(info.expressions)
            columnInfo(i+index).expression=info.expressions{i};
        else
            columnInfo(i+index).expression='';
        end
        if isSimData
            columnInfo(i+index).errorMsgs=info.errorMsgs{i};
            columnInfo(i+index).observable=info.isObservable(i);
            if iscell(info.isScalar)
                columnInfo(i+index).scalar=info.isScalar{i};
            else
                columnInfo(i+index).scalar=info.isScalar(i);
            end
            if i==1
                columnInfo(i+index).classification='independent';
            else
                columnInfo(i+index).classification='dependent';
            end
        else
            columnInfo(i+index).classification=info.columnClassification{i};
        end
    end

end

function columnClassification=getTableColumnClassifications(data,columnNames,nonmemInfo)

    GROUP='group';
    INDEPENDENT='independent';
    DEPENDENT='dependent';
    DOSE='dose';
    RATE='rate';
    COVARIATE='covariate';

    columnClassification=cell(1,numel(columnNames));

    if~nonmemInfo.nonmemInterpretation

        possibleClassifications=data.Properties.VariableDescriptions;
        if numel(possibleClassifications)==numel(data.Properties.VariableNames)&&...
            (all(cellfun(@(c)any(strcmp(c,{GROUP,INDEPENDENT,DEPENDENT,COVARIATE,''}))||...
            startsWith(c,{DOSE,RATE}),possibleClassifications)))
            columnClassification=possibleClassifications;
        else
            POSSIBLE_GROUP={'id','group','#id','i','run'};
            POSSIBLE_INDEPENDENT={'time','t','idv'};
            POSSIBLE_DEPENDENT={'response','conc','y'};
            POSSIBLE_DOSE={'dose','amt'};
            POSSIBLE_RATE={'rate'};




            gd=groupedData(data);


            [columnClassification{:}]=deal('');



            if any(ismember(columnNames,gd.Properties.GroupVariableName))
                columnClassification{ismember(columnNames,gd.Properties.GroupVariableName)}=GROUP;
            else

                idx=ismember(lower(columnNames),POSSIBLE_GROUP);
                idx=find(idx,1);

                if~isempty(idx)
                    columnClassification{idx}=GROUP;
                end
            end


            if any(ismember(columnNames,gd.Properties.IndependentVariableName))
                columnClassification{ismember(columnNames,gd.Properties.IndependentVariableName)}=INDEPENDENT;
            else

                idx=ismember(lower(columnNames),POSSIBLE_INDEPENDENT);
                idx=find(idx,1);

                if~isempty(idx)
                    columnClassification{idx}=INDEPENDENT;
                end
            end


            [columnClassification{ismember(lower(columnNames),POSSIBLE_DEPENDENT)}]=deal(DEPENDENT);

            doseColumns=columnNames(contains(lower(columnNames),POSSIBLE_DOSE));
            rateColumns=columnNames(contains(lower(columnNames),POSSIBLE_RATE));




            index=1;
            for i=1:numel(doseColumns)
                doseColumnName=lower(doseColumns{i});
                if startsWith(doseColumnName,'dose')
                    suffix=strsplit(doseColumnName,'dose');
                    suffix=suffix{2};
                elseif startsWith(doseColumnName,'amt')
                    suffix=strsplit(doseColumnName,'amt');
                    suffix=suffix{2};
                else
                    suffix='';
                end


                if~isempty(suffix)
                    rateColumnName=rateColumns(endsWith(rateColumns,suffix));
                else
                    rateColumnName=rateColumns(strcmpi(rateColumns,'rate'));
                end

                [columnClassification{strcmpi(columnNames,doseColumnName)}]=deal(sprintf('dose%d',index));
                if~isempty(rateColumnName)&&isempty(columnClassification{strcmpi(columnNames,rateColumnName)})
                    [columnClassification{strcmpi(columnNames,rateColumnName)}]=deal(sprintf('rate%d',index));
                end

                index=index+1;
            end
        end
    else
        props={'CovariateLabels','DependentVarLabel','DoseLabel','GroupLabel','IndependentVarLabel','RateLabel'};

        for i=1:numel(props)
            classifiedCols=nonmemInfo.pkdata.(props{i});
            idx=ismember(columnNames,classifiedCols);

            if any(idx)
                switch(props{i})
                case 'CovariateLabels'
                    [columnClassification{idx}]=deal(COVARIATE);
                case 'DependentVarLabel'
                    [columnClassification{idx}]=deal(DEPENDENT);
                case 'DoseLabel'
                    [columnClassification{idx}]=deal(DOSE);
                case 'GroupLabel'
                    [columnClassification{idx}]=deal(GROUP);
                case 'IndependentVarLabel'
                    [columnClassification{idx}]=deal(INDEPENDENT);
                case 'RateLabel'
                    [columnClassification{idx}]=deal(RATE);
                end
            end
        end
    end

end

function out=getWorkspaceColumnInfo()

    out=struct;
    out.classification='';
    out.expression='';
    out.name='';
    out.type='';
    out.units='';
    out.errorMsgs=[];
    out.observable=false;
    out.scalar=false;

end

function warnings=getObservableWarnings(simdata)

    if simdata.IsHomogeneous
        metadata=simdata(1).fStateMD;
    else
        metadata=unique(vertcat(simdata.fStateMD),'stable');
    end
    if~any(strcmp('observable',{metadata.Type}))

        warnings=cell(size(simdata));
        return
    end



    [~,warnings]=removeobservable(simdata,{});

    idIdx=2;
    messageIdx=3;
    for i=1:numel(warnings)
        if~isempty(warnings{i})
            warnings{i}{messageIdx}=SimBiology.web.internal.errortranslator(warnings{i}{idIdx},warnings{i}{messageIdx});
        end
    end

end

function out=getErrorMessages(simdata,columnNames,simDataInfoWarnings)

    out=cell(1,numel(columnNames));

    warnings=getObservableWarnings(simdata);


    for i=1:numel(columnNames)
        out{i}=getWarningsForSimDataColumn(columnNames{i},warnings,simDataInfoWarnings{i});
    end

end

function out=getUnitConversionState(next)
    out='none';

    unitConvert=false(1,numel(next));
    for i=1:numel(next)
        unitConvert(i)=~(isempty(next(i).RunInfo)||~next(i).RunInfo.ConfigSet.CompileOptions.UnitConversion);
    end

    if all(unitConvert)
        out='all';
    elseif any(unitConvert)
        out='mixed';
    end

end

function out=getValueForLogical(next)
    if numel(next)==1
        out=next;
    else
        if any(next)&&all(next)
            out=true;
        elseif~any(next)&&~all(next)
            out=false;
        else
            out='mixed';
        end
    end




end

function[names,metadataCell]=getSimDataNames(simdata)

    usePQNForSpecies=findUsePQNForSpecies(simdata);

    if isempty(usePQNForSpecies)







        if simdata.IsHomogeneous
            numSimDataToCheck=1;
        else
            numSimDataToCheck=numel(simdata);
        end
        names=cell(1,numSimDataToCheck);
        for i=1:numSimDataToCheck
            [~,~,names{i}]=getdata(simdata(i));
        end
        names=vertcat(names{:});
        metadata=vertcat(simdata(1:numSimDataToCheck).fStateMD);
        [metadata,iUnique]=unique(metadata,'stable');
        names=names(iUnique);
    else
        if simdata.IsHomogeneous

            metadata=simdata(1).fStateMD;
        else
            metadata=unique(vertcat(simdata.fStateMD),'stable');
        end
        numMetadata=numel(metadata);
        names=cell(numMetadata,1);
        for i=1:numMetadata
            names{i}=arrayfun(@(x)createPQN(x,usePQNForSpecies),metadata(i),'UniformOutput',false);
        end
        names=vertcat(names{:});
    end

    [names,~,loc]=unique(names,'stable');
    numNames=numel(names);
    metadataCell=cell(1,numNames);
    for i=1:numNames
        metadataCell{i}=metadata(loc==i);
    end

end

function usePQNForSpecies=findUsePQNForSpecies(simdata)

    usePQNForSpecies=[];
    userDataCell={simdata.UserData};
    for i=1:numel(userDataCell)
        userData=userDataCell{i};
        if isstruct(userData)&&isfield(userData,'isMultiCpt')
            if userData.isMultiCpt
                usePQNForSpecies=true;
                return
            else
                usePQNForSpecies=false;
            end
        end
    end

end

function pqn=createPQN(dataInfo,usePQNForSpecies)
    type=dataInfo.Type;
    switch type
    case 'compartment'
        pqn=bracketProtectIfNecessary(dataInfo.Name);
    case 'species'
        if usePQNForSpecies
            pqn=[bracketProtectIfNecessary(dataInfo.Compartment),'.',bracketProtectIfNecessary(dataInfo.Name)];
        else
            pqn=dataInfo.Name;
        end
    case 'parameter'
        if~isempty(dataInfo.Reaction)
            pqn=[bracketProtectIfNecessary(dataInfo.Reaction),'.',bracketProtectIfNecessary(dataInfo.Name)];
        else




            pqn=dataInfo.Name;
        end
    case 'sensitivity'
        inputName=createPQNForSensInputOutput(dataInfo.InputType,dataInfo.InputName,dataInfo.InputQualifier,usePQNForSpecies);
        outputName=createPQNForSensInputOutput(dataInfo.OutputType,dataInfo.OutputName,dataInfo.OutputQualifier,usePQNForSpecies);
        pqn=['d[',outputName,']/d[',inputName,']'];

        if strcmpi(dataInfo.InputType,'species')
            pqn=[pqn,'_0'];
        end
    otherwise
        pqn=dataInfo.Name;
    end

end

function pqn=createPQNForSensInputOutput(type,name,qualifier,usePQNForSpecies)
    if~isempty(qualifier)
        isSpecies=strcmpi(type,'species');
        if~isSpecies||(isSpecies&&usePQNForSpecies)
            pqn=[bracketProtectIfNecessary(qualifier),'.',bracketProtectIfNecessary(name)];
        else
            pqn=name;
        end
    else
        pqn=name;
    end

end

function name=bracketProtectIfNecessary(name)




    if~isvarname(name)
        name=sprintf('[%s]',name);
    end



end

function[simDataInfo,names]=getSimDataInfo(simdata)
    [names,metadataCell]=getSimDataNames(simdata);
    names=vertcat('time',names);

    blankCell=repmat({''},1,numel(names));
    expressions=blankCell;
    units=blankCell;
    isScalar=cell(1,numel(names));
    types=repmat({'double'},1,numel(names));
    isObservable=true(1,numel(names));
    warnings=cell(1,numel(names));


    expressionWarningStruct=struct('type','expression','severity','warning',...
    'message','Expressions for this observable column are different across SimData runs.');
    unitsWarningStruct=struct('type','units','severity','warning',...
    'message','Units for this column are different across SimData runs.');


    isObservable(1)=false;
    expressions{1}='';
    isScalar{1}=false;
    units{1}=simdata(1).TimeUnits;

    tfSameTimeUnits=strcmpi(units{1},{simdata(2:end).TimeUnits});
    if~all(tfSameTimeUnits)
        units{1}='';
        warnings{1}=unitsWarningStruct;
    end

    for indexIntoNames=2:numel(names)
        unitsWarning=[];
        expressionWarning=[];

        indexIntoMetadataCell=indexIntoNames-1;
        for indexIntoMetadata=1:numel(metadataCell{indexIntoMetadataCell})
            dataI=metadataCell{indexIntoMetadataCell}(indexIntoMetadata);




            isObservable(indexIntoNames)=isObservable(indexIntoNames)&&strcmp(dataI.Type,'observable');

            if isObservable(indexIntoNames)
                if indexIntoMetadata>1



                    isScalar{indexIntoNames}=dataI.Scalar&&isScalar{indexIntoNames};
                    if isempty(expressionWarning)&&~strcmpi(expressions{indexIntoNames},dataI.Expression)
                        expressions{indexIntoNames}='';
                        expressionWarning=expressionWarningStruct;
                    end
                    if isempty(unitsWarning)&&~strcmpi(units{indexIntoNames},dataI.Units)
                        units{indexIntoNames}='';
                        unitsWarning=unitsWarningStruct;
                    end
                else
                    expressions{indexIntoNames}=dataI.Expression;
                    units{indexIntoNames}=dataI.Units;
                    isScalar{indexIntoNames}=dataI.Scalar;
                    isObservable(indexIntoNames)=true;
                end
            else
                if indexIntoMetadata>1


                    if isempty(unitsWarning)&&~strcmpi(units{indexIntoNames},dataI.Units)
                        units{indexIntoNames}='';
                        unitsWarning=unitsWarningStruct;
                    end
                else
                    isScalar{indexIntoNames}=false;
                    expressions{indexIntoNames}='';
                    units{indexIntoNames}=dataI.Units;
                end
            end
        end
        warnings{indexIntoNames}=[expressionWarning,unitsWarning];
    end

    simDataInfo.expressions=expressions;
    simDataInfo.units=units;
    simDataInfo.isScalar=isScalar;
    simDataInfo.types=types;
    simDataInfo.isObservable=isObservable;
    simDataInfo.errorMsgs=getErrorMessages(simdata,names,warnings);

end

function out=getSimDataLength(simdata)

    out=0;

    for i=1:length(simdata)
        [t,~]=getdata(simdata(i));
        out=out+numel(t);
    end

end

function out=getExternalDataInfo(input)

    columnInfo={};

    INDEPENDENT='independent';
    DEPENDENT='dependent';

    dataInfo=getdataInfo(input);
    data=input.next;


    out=struct;

    if strcmp(dataInfo.type,'table')
        columnNames=dataInfo.columnNames;


        columnInfo=struct('name','','type','','classification','','groupingType','','groupingValue','','units','','expression','','errorMsgs','');
        columnInfo=repmat(columnInfo,numel(columnNames),1);


        groupingInfo=getGroupingInfo(data);

        for i=1:numel(columnNames)
            columnInfo(i).name=dataInfo.columnNames{i};
            columnInfo(i).type=dataInfo.columnTypes{i};
            columnInfo(i).classification=dataInfo.columnClassification{i};
            columnInfo(i).units=dataInfo.columnUnits{i};
            columnInfo(i).groupingType=groupingInfo.groupType{i};
            columnInfo(i).groupingValue=groupingInfo.groupValue{i};
            columnInfo(i).includedGroupingType=groupingInfo.groupType{i};
            columnInfo(i).includedGroupingValue=groupingInfo.groupValue{i};

            columnInfo(i).expression='';
            columnInfo(i).errorMsgs={};
        end

    elseif strcmp(dataInfo.type,'SimData')


        out.hasSensitivity=dataInfo.hasSensitivity;

        columnNames=dataInfo.columnNames;

        columnInfo=struct('name','','type','','classification','','groupingType','','groupingValue','','units','','expression','','errorMsgs','','observable','','scalar','');


        colIndex=1;
        if dataInfo.isMultiRun
            multiRunData=getMultiRunData(data);
            [groupingType,groupingValue]=getColumnGroupingInfo(multiRunData(1).value);
            columnInfo=repmat(columnInfo,numel(columnNames)+1,1);


            columnInfo(1).name=SimBiology.web.codegenerationutil('findUniqueName',columnNames,'SimDataRun');
            columnInfo(1).type=dataInfo.columnTypes{1};
            columnInfo(1).classification='';
            columnInfo(1).groupingType=groupingType;
            columnInfo(1).groupingValue=groupingValue;
            columnInfo(1).units='';
            columnInfo(1).expression='';
            columnInfo(1).errorMsgs={};
            columnInfo(1).includedGroupingType={};
            columnInfo(1).includedGroupingValue={};
            columnInfo(1).observable=false;
            columnInfo(1).scalar=false;

            colIndex=2;
        else
            columnInfo=repmat(columnInfo,numel(columnNames),1);
        end


        columnInfo(colIndex).name=dataInfo.columnNames{1};
        columnInfo(colIndex).type=dataInfo.columnTypes{1};
        columnInfo(colIndex).classification=INDEPENDENT;
        columnInfo(colIndex).groupingType={};
        columnInfo(colIndex).groupingValue={};
        columnInfo(colIndex).units=dataInfo.columnUnits{1};
        columnInfo(colIndex).expression='';
        columnInfo(colIndex).errorMsgs={};
        columnInfo(colIndex).includedGroupingType={};
        columnInfo(colIndex).includedGroupingValue={};
        columnInfo(colIndex).observable=false;
        columnInfo(colIndex).scalar=false;

        offset=0;
        if dataInfo.isMultiRun
            offset=1;
        end

        for i=2:numel(columnNames)
            index=i+offset;
            columnInfo(index).name=dataInfo.columnNames{i};
            columnInfo(index).type=dataInfo.columnTypes{i};
            columnInfo(index).classification=DEPENDENT;
            columnInfo(index).groupingType={};
            columnInfo(index).groupingValue={};
            columnInfo(index).units=dataInfo.columnUnits{i};
            columnInfo(index).expression=dataInfo.expressions{i};
            columnInfo(index).errorMsgs=dataInfo.errorMsgs{i};
            columnInfo(index).includedGroupingType={};
            columnInfo(index).includedGroupingValue={};
            columnInfo(index).observable=dataInfo.isObservable(i);
            columnInfo(index).scalar=dataInfo.isScalar{i};
        end
    end


    out.columnInfo=columnInfo;
    out.name=dataInfo.name;
    out.rows=dataInfo.rows;
    out.columns=dataInfo.columns;
    out.type=dataInfo.type;
    out.dataLength=dataInfo.dataLength;
    out.size=dataInfo.size;
    out.unitsConverted=dataInfo.unitsConverted;
    out.isMultiRun=dataInfo.isMultiRun;

end

function out=exportDataToWorkspace(action,input)

    variableName=input.varName;
    overwrite=input.overwrite;
    matfile=input.matfile;
    matfileVarName=input.matfileVariableName;
    derivedDataVarName=input.matfileDerivedVariableName;
    type=input.type;
    units=input.units;


    expr=['exist(','''',variableName,'''',')'];
    varAlreadyExist=evalin('base',expr);

    if(~varAlreadyExist||overwrite)

        data=loadVariable(matfile,matfileVarName);
        derivedData=loadVariable(matfile,derivedDataVarName);

        if strcmp(type,'deriveddata')||strcmp(type,'externalSimDataDerivedData')

            data=derivedData;
            derivedData=[];
        elseif strcmp(type,'programdata')



            derivedData=[];
        end



        if any(strcmp(type,{'programdata','programAndDerivedData'}))
            if~isempty(input.variableName)
                data=data.(input.variableName);
            end
        end

        if strcmpi(type,'simDataScalarObservablesFolder')
            if~isempty(input.variableName)
                data=data.(input.variableName);
                data=getSimdataScalarObservables(data);
            end

        elseif strcmpi(type,'externalSimDataScalarObservablesFolder')
            data=getSimdataScalarObservables(data);
        end



        if isa(data,'table')&&isa(derivedData,'table')&&height(data)==height(derivedData)

            data=[data,derivedData];


            data.Properties.VariableUnits=getTableUnits(units,data);
        else

            if~isempty(derivedData)


                if istable(derivedData)
                    derivedData.Properties.VariableUnits=getTableUnits(units,derivedData);
                end

                s=struct;
                s.data=data;
                s.observables=derivedData;
                data=s;
            end
        end



        if isstruct(data)
            props=fields(data);
            for j=1:numel(props)
                if isa(data.(props{j}),'SimBiology.Scenarios')
                    data.(props{j})=copy(data.(props{j}));
                end
            end
        elseif isa(data,'SimBiology.Scenarios')
            data=copy(data);
        end


        assignin('base',variableName,data)

        msg='';
    else
        msg=sprintf('Variable ''%s'' exists in the MATLAB workspace.',variableName);
    end

    info.message=msg;
    out={action,info};


end

function out=getTableUnits(units,data)
    allUnits={units.name};
    varNames=data.Properties.VariableNames;
    out=cell(1,numel(varNames));

    for j=1:numel(varNames)
        unit=units(ismember(allUnits,varNames{j}));
        if~isempty(unit)
            out{j}=unit.units;
        else
            out{j}='';
        end
    end


end

function out=saveData(action,inputs)


    matfile=inputs.matfileName;
    variableName=inputs.variableName;
    derivedDataName=inputs.derivedDataName;
    dataInfoName='dataInfo';
    programInfoName='programInfo';


    data=loadVariable(matfile,variableName);
    saveDataToMATFile([],variableName,matfile);


    derivedData=[];
    if SimBiology.internal.variableExistsInMatFile(matfile,derivedDataName)
        derivedData=loadVariable(matfile,derivedDataName);
        saveDataToMATFile([],derivedDataName,matfile);
    end


    dataInfo=[];
    if SimBiology.internal.variableExistsInMatFile(matfile,dataInfoName)
        dataInfo=loadVariable(matfile,dataInfoName);
        saveDataToMATFile([],dataInfoName,matfile);
    end


    programInfo=[];
    if SimBiology.internal.variableExistsInMatFile(matfile,programInfoName)
        programInfo=loadVariable(matfile,programInfoName);
        saveDataToMATFile([],programInfoName,matfile);
    end


    if SimBiology.internal.variableExistsInMatFile(matfile,'program')
        saveDataToMATFile([],'program',matfile);
    end


    newMatFile=[SimBiology.web.internal.desktopTempname(),'.mat'];


    saveDataToMATFile(data,variableName,newMatFile);

    if~isempty(derivedData)
        saveDataToMATFile(derivedData,derivedDataName,newMatFile);
    end

    if~isempty(dataInfo)
        saveDataToMATFile(dataInfo,dataInfoName,newMatFile);
    end

    if~isempty(programInfo)
        saveDataToMATFile(programInfo,programInfoName,newMatFile);
    end

    info.matfileName=newMatFile;
    info.programName=inputs.programName;
    info.name=inputs.name;
    info.oldName=inputs.oldName;
    info.dataType=inputs.dataType;

    out={action,info};


end

function deleteData(varargin)


    inputs=[varargin{:}];

    for i=1:numel(inputs)
        input=inputs(i);
        name=input.variableName;
        derivedDataName=input.derivedDataName;
        dataInfoName='dataInfo';
        programInfoName='programInfo';
        matfile=input.matfileName;
        deleteMATFile=input.deleteMATFile;

        if deleteMATFile
            deleteProgramData(matfile);
        else

            saveDataToMATFile([],name,matfile);


            if SimBiology.internal.variableExistsInMatFile(matfile,derivedDataName)
                saveDataToMATFile([],derivedDataName,matfile);
            end


            if SimBiology.internal.variableExistsInMatFile(matfile,dataInfoName)
                saveDataToMATFile([],dataInfoName,matfile);
            end


            if SimBiology.internal.variableExistsInMatFile(matfile,programInfoName)
                saveDataToMATFile([],programInfoName,matfile);
            end


            if SimBiology.internal.variableExistsInMatFile(matfile,'program')
                saveDataToMATFile([],'program',matfile);
            end
        end

        deleteModelCache(input);
        deleteDataCache(input);
    end
end

function deleteModelCache(inputs)


    if isfield(inputs,'isUsingModelCache')&&isfield(inputs,'modelCacheName')&&~isempty(inputs.modelCacheName)&&~inputs.isUsingModelCache
        modelCacheLookupFile=[SimBiology.web.internal.desktopTempdir,filesep,'modelCacheLookup.mat'];
        data=load(modelCacheLookupFile);
        modelCacheLookup=data.modelCacheLookup;
        existingNames={modelCacheLookup.name};
        cacheName=inputs.modelCacheName;
        idx=find(strcmp(cacheName,existingNames));

        if~isempty(idx)
            modelCacheLookup(idx)=[];
            if isempty(modelCacheLookup)
                modelCacheLookup=[];
            end
            saveDataToMATFile(modelCacheLookup,'modelCacheLookup',modelCacheLookupFile);
            deleteFile([SimBiology.web.internal.desktopTempdir,filesep,cacheName,'.mat']);
        end
    end

end

function deleteDataCache(inputs)


    if isfield(inputs,'isUsingDataCache')&&isfield(inputs,'dataCache')&&~isempty(inputs.dataCache)&&~any(inputs.isUsingDataCache)
        dataCacheLookupFile=[SimBiology.web.internal.desktopTempdir,filesep,'dataCacheLookup.mat'];
        data=load(dataCacheLookupFile);
        dataCacheLookup=data.dataCacheLookup;
        existingNames={dataCacheLookup.name};
        dataCache=inputs.dataCache;

        for i=1:numel(dataCache)
            if~inputs.isUsingDataCache(i)
                cacheName=dataCache(i).dataCacheName;
                idx=find(strcmp(cacheName,existingNames));

                if~isempty(idx)
                    dataCacheLookup(idx)=[];

                    if isempty(dataCacheLookup)
                        dataCacheLookup=[];
                        existingNames={};
                    else
                        existingNames={dataCacheLookup.name};
                    end


                    cacheFileName=[SimBiology.web.internal.desktopTempdir,filesep,cacheName,'.mat'];
                    if exist(cacheFileName,'file')
                        deleteFile(cacheFileName);
                    end
                end
            end
        end

        saveDataToMATFile(dataCacheLookup,'dataCacheLookup',dataCacheLookupFile);
    end

end

function out=getMultiRunData(data)



    allstates=getSimDataNames(data);

    runName=SimBiology.web.codegenerationutil('findUniqueName',allstates,'SimDataRun');


    info=struct('name',runName,'value',[]);
    info(2).name='time';
    info(2).value=[];

    for i=1:length(allstates)
        info(i+2).name=allstates{i};
        info(i+2).value=[];
    end


    infoStates={info.name};
    infoStates=infoStates(3:end);


    for i=1:numel(data)
        simdata=data(i);
        [t,x,~]=getdata(simdata);
        states=getSimDataNames(simdata);

        nextRun=i*ones(length(t),1);
        info(1).value=[info(1).value;nextRun];
        info(2).value=[info(2).value;t];


        for j=1:numel(infoStates)
            idx=strcmp(states,infoStates{j});
            if any(idx)
                info(j+2).value=[info(j+2).value;x(:,idx)];
            else
                info(j+2).value=[info(j+2).value;nan(length(t),1)];
            end
        end
    end

    out=info;

end

function out=evaluateExpression(input)

    source=input.source;
    data=loadVariable(source.matfile,source.matfileVariableName);



    if strcmp(source.sourceType,'programdata')
        if isfield(data,source.variableName)
            data=data.(source.variableName);
        else


            deleteInputs=struct;
            deleteInputs.columnNames=input.columnInfo.name;
            deleteInputs.source=input.source;
            deleteExpressionColumnForSimData(deleteInputs);
            out=[];
            return;
        end
    end

    switch class(data)
    case{'table'}
        out=evaluateExpressionForTable(input);
    case{'SimData'}
        out=evaluateExpressionForSimData(input);
    end

end

function out=evaluateExpressionForTable(input)


    source=input.source;
    sourceTable=loadVariable(source.matfile,source.matfileVariableName);


    expressionNames=input.expressionColumnNames;
    expressions=input.expressions;

    allExpressions=cell(1,numel(expressionNames));
    for i=1:numel(expressionNames)
        allExpressions{i}=sprintf('%s=%s',expressionNames{i},expressions{i});
    end

    hardError=false;
    if~isempty(allExpressions)

        try
            [results,errors]=SimBiology.internal.evaluateExpressions(allExpressions,sourceTable);
        catch ex

            errors=repmat(struct('Expression','','Message',''),numel(expressionNames),1);
            for i=1:numel(errors)

                if strcmp(expressionNames{i},input.columnInfo.name)
                    errors(i).Expression=i;
                    errors(i).Message=SimBiology.web.internal.errortranslator(ex);
                    errors(i).Severity='error';
                else
                    errors(i).Expression=i;
                    errors(i).Message=sprintf('This column was not recalculated. Error reported was: \n %s',ex.message);
                    errors(i).Severity='warning';
                end
            end
            hardError=true;
        end
    end



    if hardError
        derivedData=loadVariable(source.matfile,source.matfileDerivedVariableName);
        if isempty(derivedData)
            derivedData=table;
        end
    else

        derivedData=table;
    end

    columnInfo=repmat(struct,1,numel(expressionNames));
    for i=1:numel(expressionNames)

        if hardError


            editedColumn=input.columnInfo;
            if strcmp(editedColumn.name,expressionNames{i})
                data=nan(height(sourceTable),1);
            else
                if ismember(expressionNames(i),derivedData.Properties.VariableNames)
                    data=derivedData.(expressionNames{i});
                else
                    data=nan(height(sourceTable),1);
                end
            end
        else
            data=results.(expressionNames{i});
        end

        errorMsg=struct('message','','severity','','type','expression');

        columnErrors=errors([errors.Expression]==i);
        if~isempty(columnErrors)
            errorStr=strjoin({columnErrors.Message},'\n');


            if hardError
                severity=columnErrors(1).Severity;
            else
                severity='error';
            end

            errorMsg.message=errorStr;
            errorMsg.severity=severity;
        end


        derivedData.(expressionNames{i})=data;



        columnInfo(i).columnName=expressionNames{i};
        columnInfo(i).expression=expressions{i};
        columnInfo(i).results=scrubData(data);
        columnInfo(i).columnType=class(data);
        columnInfo(i).columnClassification='';
        columnInfo(i).errorMsg=errorMsg;

        [type,value]=getColumnGroupingInfo(data);

        columnInfo(i).groupType=type;
        columnInfo(i).groupValue=value;
        columnInfo(i).includedGroupType=type;
        columnInfo(i).includedGroupValue=value;

        if~isempty(input.exclusions)
            data(input.exclusions)=[];
            [type,value]=getColumnGroupingInfo(data);

            columnInfo(i).includedGroupType=type;
            columnInfo(i).includedGroupValue=value;
        end
    end


    if~isempty(derivedData)

        saveDataToMATFile(derivedData,source.matfileDerivedVariableName,source.matfile);
    end

    out.editedColumn=input.columnInfo;
    out.columnInfo=columnInfo;
    out.source=source;
    out.sourceEvent=input.sourceEvent;
    out.hardError=hardError;

end

function out=evaluateExpressionForSimData(input)


    source=input.source;
    simdata=loadVariable(source.matfile,source.matfileVariableName);

    if~isempty(source.variableName)
        simdata=simdata.(source.variableName);
    end







    if strcmpi(input.sourceEvent,'dataColumnExpressionChanged')||strcmpi(input.sourceEvent,'dataColumnAdded')
        simdataColumnNames=getSimDataNames(simdata);
        if ismember(input.columnInfo.name,simdataColumnNames)

            [simdata,~]=simdata.updateobservable(input.columnInfo.name,input.columnInfo.expression,'Units',input.columnInfo.units,'IssueWarnings',false);

            model=[];
            if isfield(input.source,'modelSessionID')&&input.source.modelSessionID~=-1
                model=SimBiology.web.modelhandler('getModelFromSessionID',input.source.modelSessionID);
            end


            if~isempty(model)




                if strcmpi(input.sourceEvent,'dataColumnExpressionChanged')

                    obsObj=sbioselect(model,'Type','observable','Name',input.columnInfo.name);
                    if~isempty(obsObj)
                        obsObj.Expression=input.columnInfo.expression;
                    else



                        model.addobservable(input.columnInfo.name,input.columnInfo.expression,'Units',input.columnInfo.units);
                    end
                end
            end
        elseif strcmpi(input.sourceEvent,'dataColumnAdded')

            [simdata,~]=simdata.addobservable(input.columnInfo.name,input.columnInfo.expression,'Units',input.columnInfo.units,'IssueWarnings',false);

            model=[];
            if isfield(input.source,'modelSessionID')&&input.source.modelSessionID~=-1
                model=SimBiology.web.modelhandler('getModelFromSessionID',input.source.modelSessionID);
            end


            if~isempty(model)
                model.addobservable(input.columnInfo.name,input.columnInfo.expression,'Units',input.columnInfo.units);
            end
        end


        if~isempty(source.variableName)
            data=updateVariableInProgramDataStruct(simdata,source.variableName,source.matfileVariableName,source.matfile);
            saveDataToMATFile(data,source.matfileVariableName,source.matfile);
        else
            saveDataToMATFile(simdata,source.matfileVariableName,source.matfile);
        end
    end


    isMultiRun=numel(simdata)>1;


    [simdataInfo,simdataColumnNames]=getSimDataInfo(simdata);
    simdataData=getMultiRunData(simdata);


    columnInfo=repmat(struct,1,numel(simdataInfo.isObservable(simdataInfo.isObservable==true)));

    obsIdx=1;
    for i=1:numel(simdataColumnNames)
        if simdataInfo.isObservable(i)

            data=simdataData(strcmp({simdataData.name},simdataColumnNames{i}));
            data=data.value;
            columnInfo(obsIdx).isObservable=simdataInfo.isObservable(i);
            columnInfo(obsIdx).columnName=simdataColumnNames{i};
            columnInfo(obsIdx).expression=simdataInfo.expressions{i};
            columnInfo(obsIdx).isScalar=simdataInfo.isScalar{i};
            columnInfo(obsIdx).results=scrubData(data);
            columnInfo(obsIdx).units=simdataInfo.units{i};
            columnInfo(obsIdx).columnType=class(data);
            columnInfo(obsIdx).columnClassification='dependent';
            columnInfo(obsIdx).errorMsg=simdataInfo.errorMsgs{i};

            obsIdx=obsIdx+1;
        end
    end


    out.editedColumn=input.columnInfo;
    out.columnInfo=columnInfo;
    out.source=source;
    out.multiRun=isMultiRun;
    out.sourceEvent=input.sourceEvent;
    out.hardError=false;



end

function out=getWarningsForSimDataColumn(columnName,warningCell,infoWarnings)


    errorMsgs=getWarningForColumnName(columnName,warningCell);
    if~isempty(errorMsgs.message)
        errorMsgs.type='expression';
        expressionErrors=errorMsgs;
    else
        expressionErrors={};
    end


    if~isempty(infoWarnings)
        idx=strcmpi({infoWarnings.type},'expression');
        expressionWarning=infoWarnings(idx);
    else
        expressionWarning={};
    end
    if~isempty(expressionWarning)
        if~isempty(expressionErrors)
            expressionErrors.message=sprintf('%s\n%s',expressionErrors.message,expressionWarning.message);
            expressionErrors.type='expression';
            expressionErrors={expressionErrors};
        else
            expressionErrors={expressionWarning};
        end
    end


    if~isempty(infoWarnings)
        idx=strcmpi({infoWarnings.type},'units');
        unitsWarning={infoWarnings(idx)};
    else
        unitsWarning={};
    end

    out=[expressionErrors,unitsWarning];



end

function out=getWarningForColumnName(columnName,warningCell)
    out='';
    isError=false;
    msgs={};
    for i=1:numel(warningCell)
        warningVal=warningCell{i};
        if~isempty(warningVal)
            idx=find(ismember(warningVal(:,4),columnName));
            for j=1:numel(idx)
                warnInfo=warningVal(idx(j),:);
                isError=isError||showWarningAsError(warnInfo{2});
                msgs{end+1}=SimBiology.web.internal.errortranslator(warnInfo{2},warnInfo{3});
            end
        end
    end

    msgs=unique(msgs);

    for i=1:numel(msgs)
        if i>1
            out=sprintf('%s\n%s',out,msgs{i});
        else
            out=sprintf('%s',msgs{i});
        end
    end

    if~isempty(out)
        if isError
            severity='error';
        else
            severity='warning';
        end
        out=struct('message',out,'severity',severity);
    else
        out=struct('message','','severity','');
    end



end

function out=showWarningAsError(messageID)
    out=strcmpi(messageID,'SimBiology:SimData:UnresolvedToken')||strcmpi(messageID,'SimBiology:bmodel:ObservableStr2funcError')||strcmpi(messageID,'SimBiology:sbservices:ObservableCircularDependency');

end

function out=deleteExpressionColumn(varargin)


    inputs=[varargin{:}];

    for i=1:numel(inputs)
        input=inputs(i);
        source=input.source;
        data=loadVariable(source.matfile,source.matfileVariableName);

        if strcmp(source.sourceType,'programdata')
            data=data.(source.variableName);
        end

        switch class(data)
        case{'table'}
            out=deleteExpressionColumnForData(input);
        case{'SimData'}
            out=deleteExpressionColumnForSimData(input);
        end
    end
end

function out=deleteExpressionColumnForData(input)


    columnNames=input.columnNames;
    if~iscell(columnNames)
        columnNames={columnNames};
    end


    source=input.source;
    derivedDataName=source.matfileDerivedVariableName;
    derivedData=loadVariable(source.matfile,derivedDataName);


    if~isempty(derivedData)

        headings=derivedData.Properties.VariableNames;
        for i=1:numel(columnNames)
            if find(ismember(headings,columnNames{i}),1)
                derivedData.(columnNames{i})=[];
            end
        end

        if isempty(derivedData)
            removeDataFromMATFile(derivedDataName,[],source.matfile);
        else
            saveDataToMATFile(derivedData,derivedDataName,source.matfile);
        end
    end


    out=struct;
    out.source=input.source;
    out.columnNames=columnNames;

end

function out=deleteExpressionColumnForSimData(input)


    columnNames=input.columnNames;
    if~iscell(columnNames)
        columnNames={columnNames};
    end


    source=input.source;
    simdata=loadVariable(source.matfile,source.matfileVariableName);

    if~isempty(source.variableName)
        simdata=simdata.(source.variableName);
    end


    simdataColumnNames=getSimDataNames(simdata);
    for i=1:numel(columnNames)
        observableName=columnNames{i};
        if ismember(observableName,simdataColumnNames)

            simdata=simdata.removeobservable(observableName);

            model=[];
            if isfield(input.source,'modelSessionID')&&input.source.modelSessionID~=-1
                model=SimBiology.web.modelhandler('getModelFromSessionID',input.source.modelSessionID);
            end


            if~isempty(model)

                obsObj=sbioselect(model,'Type','observable','Name',observableName);
                if~isempty(obsObj)
                    delete(obsObj);
                end
            end
        end
    end


    if~isempty(source.variableName)
        data=updateVariableInProgramDataStruct(simdata,source.variableName,source.matfileVariableName,source.matfile);
        saveDataToMATFile(data,source.matfileVariableName,source.matfile);
    else
        saveDataToMATFile(simdata,source.matfileVariableName,source.matfile);
    end


    out=struct;
    out.source=input.source;
    out.columnNames=columnNames;

end

function out=renameExpressionColumn(input)

    source=input.source;
    data=loadVariable(source.matfile,source.matfileVariableName);

    if strcmp(source.sourceType,'programdata')
        data=data.(source.variableName);
    end

    switch class(data)
    case{'table'}
        out=renameExpressionColumnForData(input);
    case{'SimData'}
        out=renameExpressionColumnForSimData(input);
    end

end

function out=renameExpressionColumnForData(input)


    columnName=input.columnName;
    newName=input.value;


    source=input.source;
    derivedDataName=source.matfileDerivedVariableName;
    derivedData=loadVariable(source.matfile,derivedDataName);


    if~isempty(derivedData)
        headings=derivedData.Properties.VariableNames;
        if find(ismember(headings,columnName),1)
            derivedData.Properties.VariableNames{strcmp(headings,columnName)}=newName;
            saveDataToMATFile(derivedData,derivedDataName,source.matfile);
        end
    end


    out=struct;
    out.source=source;
    out.columnName=columnName;
    out.value=newName;

end

function out=renameExpressionColumnForSimData(input)


    oldName=input.columnName;
    newName=input.value;


    source=input.source;
    simdata=loadVariable(source.matfile,source.matfileVariableName);

    if~isempty(source.variableName)
        simdata=simdata.(source.variableName);
    end



    [simdata,~]=renameobservable(simdata,oldName,newName,'IssueWarnings',false);


    if~isempty(source.variableName)
        data=updateVariableInProgramDataStruct(simdata,source.variableName,source.matfileVariableName,source.matfile);
        saveDataToMATFile(data,source.matfileVariableName,source.matfile);
    else
        saveDataToMATFile(simdata,source.matfileVariableName,source.matfile);
    end

    model=[];
    if isfield(input.source,'modelSessionID')&&input.source.modelSessionID~=-1
        model=SimBiology.web.modelhandler('getModelFromSessionID',input.source.modelSessionID);
    end


    if~isempty(model)
        observable=sbioselect(model,'Name',oldName,'Type','observable');
        if~isempty(observable)
            rename(observable,newName);
        else






            observable=sbioselect(model,'Name',newName,'Type','observable');
            if isempty(observable)




                observableSimData=simdata.selectbyname(newName);
                idx=arrayfun(@(sd)(sd.DataCount.Observable==1),observableSimData);
                expression=observableSimData(idx(end)).DataInfo{1}.Expression;
                units=observableSimData(idx(end)).DataInfo{1}.Units;
                model.addobservable(newName,expression,'Units',units);
            end
        end
    end


    out=struct;
    out.source=source;
    out.columnName=oldName;
    out.value=newName;

end

function out=evaluateExclusion(input)


    data=loadVariable(input.matfileName,input.matfileVariableName);


    derivedDataName=input.matfileDerivedVariableName;
    derivedData=loadVariable(input.matfileName,derivedDataName);


    switch class(data)
    case{'table'}
        dataLength=size(data,1);
        headings=data.Properties.VariableNames;

        for i=1:length(headings)
            columnData=data.(headings{i});


            if iscell(columnData)
                columnData=convertToDouble(columnData);%#ok<NASGU>
            end

            eval([headings{i},' = columnData;']);
        end

















    end


    if~isempty(derivedData)
        derivedColumnNames=derivedData.Properties.VariableNames;

        for i=1:numel(derivedColumnNames)
            columnData=derivedData.(derivedColumnNames{i});%#ok<NASGU>
            eval([derivedColumnNames{i},' = columnData;']);
        end
    end


    exclusions=input.exclusions;


    exclusionResults=struct('exclusionRowID','','excludedRowNumbers','','expression','','numMatches','',...
    'message','','description','','exclude','');
    exclusionResults=repmat(exclusionResults,numel(exclusions),1);

    for i=1:numel(exclusions)
        results=[];
        message='';
        try
            results=eval(exclusions(i).expression);
            if~all(size(results)==[dataLength,1])
                message='Expression result must return a 1-by-n vector where n is the number of rows in the data.';
            end
        catch ex
            message=SimBiology.web.internal.errortranslator(ex);
        end

        excludedRowNumbers=find(results);
        exclusionResults(i).excludedRowNumbers=excludedRowNumbers;
        exclusionResults(i).numMatches=numel(excludedRowNumbers);
        exclusionResults(i).message=message;
        exclusionResults(i).exclusionRowID=exclusions(i).exclusionRowID;
        exclusionResults(i).expression=exclusions(i).expression;
        exclusionResults(i).description=exclusions(i).description;
        exclusionResults(i).exclude=exclusions(i).exclude;
    end


    out=struct;
    out.dataName=input.dataName;
    out.exclusionResults=exclusionResults;

end

function out=getIncludedGroups(action,input)


    data=loadVariable(input.matfileName,input.matfileVariableName);


    derivedDataName=input.matfileDerivedVariableName;
    derivedData=loadVariable(input.matfileName,derivedDataName);


    data=[data,derivedData];
    data(input.excludedRowNumbers,:)=[];


    out=struct;
    out.dataName=input.dataName;
    out.groupingInfo=getGroupingInfo(data);

    out={action,out};

end

function types=getColumnTypes(data)

    names=data.Properties.VariableNames;
    types=cell(1,length(names));

    for i=1:length(names)
        types{i}=class(data.(names{i}));
    end

end

function out=getGroupingInfo(data)

    names=data.Properties.VariableNames;
    types=cell(1,length(names));
    values=cell(1,length(names));

    for i=1:length(names)
        [types{i},values{i}]=getColumnGroupingInfo(data.(names{i}));
    end

    out=struct;
    out.groupType=types;
    out.groupValue=values;

end

function[type,value]=getColumnGroupingInfo(data)


    if iscell(data)
        if iscellstr(data)
            next=unique(data,'stable');
        else



            next={};
            next{1}=data{1};
            currentVal=data{1};

            for i=1:numel(data)
                if~isequal(currentVal,data{i})
                    includeValue=cellfun(@(x)(isequal(x,data{i})),next,'UniformOutput',false);
                    if~any([includeValue{:}])
                        next{end+1}=data{i};
                    end
                    currentVal=data{i};
                end
            end
        end
    else

        next=unique(data,'stable');
    end

    if isa(next,'categorical')

        if any(isundefined(next))
            next=[next(~isundefined(next));cellstr(categorical(NaN))];
        end
        next=cellstr(next);
    end

    if isnumeric(next)

        if any(isnan(next))
            next=[num2cell(next(~isnan(next)));{num2str(NaN)}];
        end
        type='vector';
        value=next;
    else
        type='categorical';
        value=next;
    end

end

function out=convertToDouble(input)



    out=input;
    try
        out=cell2mat(input);
    catch
    end
    if~isnumeric(out)||size(input,1)~=size(out,1)
        out=input;
    end

end

function data=loadVariable(matfile,matfileVarName)

    if SimBiology.internal.variableExistsInMatFile(matfile,matfileVarName)
        data=load(matfile,matfileVarName);
        data=data.(matfileVarName);
    else
        data=[];
    end


end

function data=updateVariableInProgramDataStruct(value,varname,matfileVarname,matfile)



    data=struct;


    if exist(matfile,'file')~=0&&SimBiology.internal.variableExistsInMatFile(matfile,matfileVarname)

        tempStruct=load(matfile);

        if isstruct(tempStruct.(matfileVarname))
            data=tempStruct.(matfileVarname);
        end
    end

    data.(varname)=value;


end

function saveDataToMATFile(value,varname,matfile)






    if exist(matfile,'file')==0

        structToSave.(varname)=value;
        saveHelper(matfile,true,false,structToSave);
    else

        if SimBiology.internal.variableExistsInMatFile(matfile,varname)

            tempStruct=load(matfile);


            tempStruct.(varname)=value;


            saveHelper(matfile,true,false,tempStruct);
        else
            tempStruct.(varname)=value;
            saveHelper(matfile,true,true,tempStruct);
        end
    end



end

function saveDatasToMATFile(values,varnames,matfile)
    if exist(matfile,'file')==0
        tempStruct=struct;
    else
        tempStruct=load(matfile);
    end

    for i=1:numel(values)
        tempStruct.(varnames{i})=values{i};
    end

    saveHelper(matfile,true,false,tempStruct);



end

function saveHelper(matfile,useStruct,useAppend,variableToSave)
    if useStruct
        structOpts={'-struct'};
    else
        structOpts={};
    end
    if useAppend
        appendOpts={'-append'};
    else
        appendOpts={};
    end


    try
        save(matfile,structOpts{:},'variableToSave',appendOpts{:});
    catch ex
        if strcmp(ex.identifier,'MATLAB:save:errorClosingFile')
            save(matfile,'-v7.3',structOpts{:},'variableToSave',appendOpts{:});
            m=message('SimBiology:sbiodesktoperrortranslator:PROGRAM_DATA_SAVED_WITH_DIFFERENT_MATFILE_VERSION');
            warning(m);
        else
            throw ex;
        end
    end


end

function removeDataFromMATFile(varname,propName,matfile)


    if exist(matfile,'file')

        if SimBiology.internal.variableExistsInMatFile(matfile,varname)

            tempStruct=load(matfile);

            if isempty(propName)

                tempStruct=rmfield(tempStruct,varname);
            else
                varStruct=tempStruct.(varname);
                if isfield(varStruct,propName)
                    varStruct=rmfield(varStruct,propName);
                end

                if isempty(fields(varStruct))
                    tempStruct=rmfield(tempStruct,varname);
                else
                    tempStruct.(varname)=varStruct;
                end
            end


            save(matfile,'-struct','tempStruct');
        end
    end


end

function deleteProgram(varargin)


    inputs=[varargin{:}];

    for i=1:numel(inputs)
        input=inputs(i);
        deleteProgramData(input.programMatfile);





        idx=arrayfun(@(c)isempty(c.modelCacheName),input.modelCaches);
        modelCaches=input.modelCaches(~idx);
        if~isempty(modelCaches)
            [~,idx]=unique({modelCaches.modelCacheName});
            modelCaches=modelCaches(idx);
            for m=1:numel(modelCaches)
                deleteModelCache(modelCaches(m));
            end
        end


        idx=arrayfun(@(c)isempty(c.dataCache),input.dataCaches);
        dataCaches=input.dataCaches(~idx);
        [~,idx]=unique(arrayfun(@(c)c.dataCache.dataCacheName,dataCaches,'UniformOutput',false));
        dataCaches=dataCaches(idx);
        for i=1:numel(dataCaches)
            deleteDataCache(dataCaches(i));
        end
    end

end

function deleteProgramData(matfile)

    if~isempty(matfile)&&exist(matfile,'file')
        oldState=recycle;
        recycle('off');
        delete(matfile)
        recycle(oldState);
    end


end

function out=getDataWithPostProcessing(action,inputs)



    warnState=warning('off','SimBiology:SamplingData:PotentialDuplicate');
    cleanup=onCleanup(@()warning(warnState));

    data=getresults("getdata",inputs);

    columns=data{2}.variables;

    out=struct;


    for i=1:numel(columns)
        columnObj=columns(i);


        dataInfo=struct;
        dataInfo.sourceType=columnObj.SourceType;
        dataInfo.sourceName=columnObj.SourceName;
        dataInfo.dataName=columnObj.DataName;
        dataInfo.variableName=columnObj.StructFieldName;
        dataInfo.parentType=columnObj.ParentType;



        if isfield(columnObj.data,'tableMetaData')

            out(i).dataInfo=dataInfo;
            out(i).tableMetaData=columnObj.data.tableMetaData;
            out(i).tables=vertcat(columnObj.data.tables);
        else


            columnStruct=struct;
            columnStruct.name=columnObj.ColumnName;


            columnObj.data=scrubData(columnObj.data);

            columnStruct.data=columnObj.data;
            columnStruct.isExpression=false;



            mergedColumns=false;
            for j=1:numel(out)
                if i>1&&isequal(out(j).dataInfo,dataInfo)


                    addedColumns={out(j).tables.columnInfo.name};
                    if~any(strcmp(addedColumns,columnStruct.name))
                        out(j).tables.columnInfo(end+1)=columnStruct;
                    end
                    mergedColumns=true;
                    break;
                end
            end

            if(mergedColumns)
                continue;
            end


            out(i).dataInfo=dataInfo;



            tableMetaData=struct;
            tableMetaData.supportsExclusions=false;
            tableMetaData.dataType='data';
            tableMetaData.canHideColumns=true;


            tableType='';
            switch columnObj.type
            case{'SimDataAll','SimData','DerivedDataAll','deriveddata','SimDataColumn','SimDataRun','simDataScalarObservablesFolder','simDataScalarObservableColumn'}
                tableType='SimData';

            case{'table','tableColumn'}
                if strcmp(dataInfo.sourceType,'externaldata')
                    tableType='externaldata';
                    tableMetaData.supportsExclusions=true;




                elseif strcmp(dataInfo.parentType,'Group Simulation')||strcmp(dataInfo.parentType,'Custom')
                    tableType='table';
                else
                    tableType='rawdata';
                end

            case{'SimBiology.Variant','logical','char','cell','categorical','double','SimBiology.Scenarios'}
                tableType='rawdata';
                tableMetaData.canHideColumns=false;
            end


            out(i).tableMetaData=tableMetaData;






            tables=struct;
            tables.name=dataInfo.dataName;
            tables.tableType=tableType;
            tables.reshapeForComparison=false;
            tables.allowSorting=false;
            tables.additionalRows=struct;
            tables.mergeUsingGroups=false;
            tables.tablePosition=struct('x','','y','');
            tables.tableSize=struct('width','','height','');
            tables.datasheetDisplayIndex=0;
            tables.columnInfo=columnStruct;


            out(i).tables=tables;
        end
    end

    out={action,out};



end

function out=exportDatasheetToFile(action,inputs)

    fileName=inputs.fileName;
    info.fileName=fileName;
    info.message='';


    if exist(fileName,'file')>0


        [fid,~]=fopen(fileName,'a');
        if fid==-1
            info.message=sprintf("Cannot access file %s. File is already open in another program",fileName);
            out={action,info};
            return;
        else
            fclose(fid);
            delete(fileName);
        end
    end

    try


        datasheets=cell(1,numel(inputs.datasheetInfo));



        for i=1:numel(inputs.datasheetInfo)
            datasheet=struct('name',inputs.datasheetInfo(i).datasheetName);


            tableInfo=inputs.datasheetInfo(i).tables;




            if strcmp(inputs.datasheetInfo(i).datasheetType,'fitdata')
                datasheet.tables=getFitDataTables(tableInfo);
            else
                datasheet.tables=getDataTables(tableInfo);
            end

            datasheets{i}=datasheet;
        end


        writeData(fileName,datasheets);

    catch ex
        info.message=SimBiology.web.internal.errortranslator(ex);
    end

    out={action,info};








end

function tables=getFitDataTables(tableInfo)


    uniqueSources=tableInfo(1).sourceInfo;
    for i=2:numel(tableInfo)
        if~isStructMatch(tableInfo(i),uniqueSources)
            uniqueSources(end+1)=tableInfo(i).sourceInfo;
        end
    end


    fitData=struct;



    for i=1:numel(uniqueSources)

        data=getDataWithPostProcessing('',uniqueSources(i));
        fieldName=getFitStructFieldName(uniqueSources(i).variables.SourceName,uniqueSources(i).variables.DataName);
        fitData.(fieldName)=data{2};
    end

    tables={};


    for i=1:numel(tableInfo)



        if numel(tableInfo(i).sourceInfo)==1


            fieldName=getFitStructFieldName(tableInfo(i).sourceInfo.variables.SourceName,tableInfo(i).sourceInfo.variables.DataName);
            fitDataForSource=fitData.(fieldName);
            tableNames={fitDataForSource.tables.name};

            idx=strcmp(tableNames,tableInfo(i).name);
            if any(idx)
                [titleTable,headerTable,dataTable]=createTableForWrite(fitDataForSource.tables(idx),tableInfo(i));
                tables{end+1}=struct('titleTable',titleTable,'headerTable',headerTable,'dataTable',dataTable);
            end

        else


            tableData=[];
            sourceNames={};
            for j=1:numel(tableInfo(i).sourceInfo)
                fieldName=getFitStructFieldName(tableInfo(i).sourceInfo(j).variables.SourceName,tableInfo(i).sourceInfo(j).variables.DataName);
                fitDataForSource=fitData.(fieldName);

                tableNames={fitDataForSource.tables.name};
                idx=strcmp(tableNames,tableInfo(i).name);
                if any(idx)
                    if isempty(tableData)
                        tableData=fitDataForSource.tables(idx);
                    else
                        tableData(end+1)=fitDataForSource.tables(idx);
                    end
                end


                sourceNames{end+1}=fieldName;
            end




            [titleTable,headerTable,dataTable]=mergeTableForWrite(tableData,tableInfo(i),sourceNames);
            tables{end+1}=struct('titleTable',titleTable,'headerTable',headerTable,'dataTable',dataTable);
        end
    end


end

function out=getFitStructFieldName(sourceName,varName)
    out=genvarname(sprintf('%s_%s',sourceName,varName));



end

function[titleTable,headerTable,dataTable]=mergeTableForWrite(tableData,tableInfo,sourceNames)


    titleTable=table({tableInfo.title});




    if tableData(1).reshapeForComparison


        data=[];
        for i=1:numel(tableData)

            for j=2:numel(tableData(i).columnInfo)
                data=vertcat(data,tableData(i).columnInfo(j).data);
            end
        end


        rowNumbers=(1:numel(sourceNames));



        dataTable=array2table(rowNumbers');
        dataTable(:,end+1)=sourceNames';


        dataTable=[dataTable,array2table(data)];



        assert(numel(tableInfo.propertyNames)+1==numel(dataTable.Properties.VariableNames));


        columnNames=horzcat({''},tableInfo.columnNames');
        headerTable=cell2table(columnNames);
    else



        titleTable=table({tableInfo.title});

        commonColumns={};
        tables=cell(1,numel(tableData));



        for i=1:numel(tableData)
            columnInfo=tableData(i).columnInfo;

            t=table;
            for j=1:numel(columnInfo)

                data=scrubDataForMerging(columnInfo(j).data(:));
                if isempty(t)
                    t{:,j}=data;
                else
                    t{:,j}=data(1:height(t));
                end
                if columnInfo(j).isCommon
                    t.Properties.VariableNames{j}=columnInfo(j).name;
                    commonColumns{end+1}=columnInfo(j).name;
                end
            end

            tables{i}=t;
        end


        commonColumns=unique(commonColumns,'stable');


        dataTable=tables{1};
        for i=2:numel(tables)
            [dataTable,ia,ib]=outerjoin(dataTable,tables{i},'Keys',commonColumns,'MergeKeys',true);




            if~any(ia==0)
                [~,idx]=sort(ia);
                dataTable=dataTable(idx,:);
            else




                offset=height(dataTable);
                iab=ia;
                iab(ia==0)=ib(iab==0)+offset;
                [~,idx]=sort(iab);
                dataTable=dataTable(idx,:);
            end
        end


        headerInfo=tableInfo.headerInfo;
        propertyNames=tableInfo.propertyNames;
        numHeaders=numel(headerInfo);
        numAttrs=numel(propertyNames);





        tableValues=cell(numHeaders,numAttrs);
        for i=1:numAttrs
            for j=1:numHeaders
                tableValues{j,i}=headerInfo(j).(propertyNames{i});

                if~isempty(headerInfo(j).columnSpan)&&headerInfo(j).columnSpan(i)==-1
                    tableValues{j,i}='';
                end
            end
        end


        headerTable=cell2table(tableValues);
    end



end

function out=isStructMatch(tableInfo,uniqueSources)
    out=false;

    for j=1:numel(uniqueSources)
        for k=1:numel(tableInfo.sourceInfo)
            if isequal(tableInfo.sourceInfo(k).variables,uniqueSources(j).variables)
                out=true;
                return;
            end
        end
    end






end

function tables=getDataTables(tableInfos)


    tables={};


    for j=1:numel(tableInfos)


        data=getDataForTable(tableInfos(j));
        title=tableInfos(j).title;



        allTables=[data.tables];
        allTitles={allTables.name};
        idx=findTable(title,allTitles);
        [titleTable,headerTable,dataTable]=createTableForWrite(allTables(idx),tableInfos(j));

        tables{end+1}=struct('titleTable',titleTable,'headerTable',headerTable,'dataTable',dataTable);
    end

end

function idx=findTable(title,allTitles)

    idx=1;

    for i=1:numel(allTitles)
        if startsWith(title,allTitles{i})
            idx=i;
            return;
        end
    end


end

function data=getDataForTable(tableInfo)





    sources=tableInfo.sourceInfo;

    for i=1:numel(sources)
        tmp=getDataWithPostProcessing('',sources(i));
        if i==1
            data=tmp{2};
        else

            tmp=tmp{2};
            data.tables.columnInfo=horzcat(data.tables.columnInfo,tmp.tables.columnInfo);
        end


        if~isempty(tableInfo.expressionColumnNames)&&strcmp(sources(i).variables.type,'SimData')
            sources(i).variables.type='deriveddata';


            expressionData=getDataWithPostProcessing('',sources(i));
            expressionData=expressionData{2};



            columnNames={data.tables.columnInfo.name};
            for j=1:numel(expressionData.tables.columnInfo)
                if~ismember(expressionData.tables.columnInfo(j).name,columnNames)
                    data.tables.columnInfo=horzcat(data.tables.columnInfo,expressionData.tables.columnInfo(j));
                end
            end
        end
    end


end

function[titleTable,headerTable,dataTable]=createTableForWrite(tableObj,tableInfo)


    titleTable=table({tableInfo.title});


    columnInfo=[tableObj.columnInfo];






    rowHeaders={};
    for i=1:numel(tableInfo.headerInfo)
        rowHeaders{i}=tableInfo.headerInfo(i).rowHeader;
    end


    headerTable=table(rowHeaders');



    columnData=1:numel(columnInfo(1).data);
    dataTable=table(columnData');



    for i=1:numel(tableInfo.columnNames)
        idx=strcmp(tableInfo.columnNames{i},{columnInfo.name});

        if any(idx)
            idx=find(idx);
            idx=idx(1);
            colInfo=columnInfo(idx);


            if~isempty(tableInfo.propertyNames)
                propName=tableInfo.propertyNames{strcmp(colInfo.name,tableInfo.columnNames)};
                headers={};
                for j=1:numel(tableInfo.headerInfo)
                    propName=matlab.lang.makeValidName(propName);
                    headers{end+1}=tableInfo.headerInfo(j).(propName);
                end


                headerTable(:,end+1)=headers';
            end




            data=colInfo.data;
            dataSize=size(data,2);


            if~any(size(data)==1)

                additionalCols=cell(numel(tableInfo.headerInfo),dataSize-1);
                headerTable=[headerTable,cell2table(additionalCols)];

                dataTable=[dataTable,array2table(data)];
            else
                try
                    dataTable{:,end+1}=data(:);
                catch
                    x=5;
                end
            end


            columnInfo(idx).name='';
            tableInfo.columnNames{idx}='';
        end
    end


end

function writeData(fileName,datasheets)






    warnState=warning('off','MATLAB:xlswrite:AddSheet');
    cleanup=onCleanup(@()warning(warnState));

    for i=1:numel(datasheets)
        datasheet=datasheets{i};

        range=1;
        sheetName=sprintf('Sheet%d',i);

        for j=1:numel(datasheet.tables)
            tableInfo=datasheet.tables{j};


            writetable(tableInfo.titleTable,fileName,'WriteVariableNames',false,'Range',sprintf('A%d',range),'Sheet',sheetName);

            range=range+1;


            writetable(tableInfo.headerTable,fileName,'WriteVariableNames',false,'Range',sprintf('A%d',range),'Sheet',sheetName);

            range=range+height(tableInfo.headerTable);


            writetable(tableInfo.dataTable,fileName,'WriteVariableNames',false,'Range',sprintf('A%d',range),'Sheet',sheetName);

            range=range+height(tableInfo.dataTable)+5;
        end
    end


end

function out=loadDatasheet(action,datasheetInfo)

    tableData={};



    tableInfos=datasheetInfo.tableInfos;
    if strcmp(datasheetInfo.datasheetType,'fitdata')
        tableInfos=datasheetInfo.tableInfos(1);
    elseif strcmp(datasheetInfo.datasheetType,'gsadata')
        tableInfos=datasheetInfo.tableInfos(1);
    end



    for i=1:numel(tableInfos)
        tableInfo=tableInfos(i);




        sources=tableInfo.sourceInfo;
        if strcmp(datasheetInfo.datasheetType,'data')
            for j=1:numel(sources)
                tableInfo.sourceInfo=sources(j);
                data=getDataForTable(tableInfo);

                if data(1).tableMetaData.canHideColumns
                    tmp=[data.tables];
                    tmp=[tmp.columnInfo];
                    loadedColumnNames={tmp.name};


                    idx=ismember(loadedColumnNames,tableInfo.columnNames);


                    if any(idx)
                        data.tables.columnInfo=data.tables.columnInfo(idx);
                    end
                end


                tablePosition=struct('x','','y','');
                if isfield(tableInfo,'tablePosition')
                    tablePosition=tableInfo.tablePosition;
                end

                tableSize=struct('width','','height','');
                if isfield(tableInfo,'tableSize')
                    tableSize=tableInfo.tableSize;
                end


                for m=1:numel(data)
                    data(m).tables.tablePosition=tablePosition;
                    data(m).tables.tableSize=tableSize;
                    data(m).tables.datasheetDisplayIndex=0;
                    tableData{end+1}=data(m);
                end
            end

        elseif strcmp(datasheetInfo.datasheetType,'fitdata')||strcmp(datasheetInfo.datasheetType,'gsadata')||strcmp(datasheetInfo.datasheetType,'parameterConfidenceInterval')||strcmp(datasheetInfo.datasheetType,'predictionConfidenceInterval')

            sources=tableInfo.sourceInfo;
            for j=1:numel(sources)
                tableInfo.sourceInfo=sources(j);
                tables=getDataForTable(tableInfo);


                assignedDisplayIndices=[tables.tables.datasheetDisplayIndex];
                existingDisplayIndices=[datasheetInfo.tableInfos.datasheetDisplayIndex];

                if numel(assignedDisplayIndices)==numel(existingDisplayIndices)&&isempty(setdiff(assignedDisplayIndices,existingDisplayIndices))


                    for k=1:numel(tables.tables)
                        idx=ismember([datasheetInfo.tableInfos.datasheetDisplayIndex],tables.tables(k).datasheetDisplayIndex);
                        tInfo=datasheetInfo.tableInfos(idx);
                        tInfo=tInfo(1);


                        tables.tables(k).tablePosition=tInfo.tablePosition;
                        tables.tables(k).tableSize=tInfo.tableSize;
                    end
                end

                tableData{end+1}=tables;
            end
        end
    end


    out=struct;
    out.datasheetName=datasheetInfo.datasheetName;
    out.tableInfos=tableData;

    out={action,out};

end

function data=getDataWithExclusions(input)

    data=loadVariable(input.dataMATFile,input.dataMATFileVariableName);
    derivedData=loadVariable(input.dataMATFile,input.matfileDerivedVariableName);

    if~isempty(derivedData)
        for i=1:width(derivedData)
            data(:,end+1)=derivedData(:,i);
        end
    end


    data(input.exclusions,:)=[];


end

function out=duplicateData(action,inputs)
    out=struct('dataInfo','','errorMsg','');
    out=repmat(out,numel(inputs),1);

    filename=inputs.filename;
    dataInfos=inputs.dataInfo;


    dataToSave={};
    vars={};

    for i=1:numel(dataInfos)
        errorMsg='';
        dataInfo=dataInfos(i);
        try
            data=loadVariable(filename,dataInfo.copyFrom.matfileVariableName);
            dataToSave{end+1}=data;
            vars{end+1}=dataInfo.matfileVariableName;

            derivedData=loadVariable(filename,dataInfo.copyFrom.matfileDerivedVariableName);
            dataToSave{end+1}=derivedData;
            vars{end+1}=dataInfo.matfileDerivedVariableName;
        catch
            errorMsg=sprintf('An unexpected error occured when duplicating %s.',dataInfo.copyFrom.name);
        end
        out(i).dataInfo=dataInfo;
        out(i).errorMsg=errorMsg;
    end

    saveDatasToMATFile(dataToSave,vars,filename);

    out={action,out};


end

function data=scrubData(data)

    if iscategorical(data)
        data=cellstr(data);
    end

    if isa(data,'datetime')||isa(data,'duration')
        data=string(data);
    end



    if isnumeric(data)
        data=num2cell(data);
    end


    if iscell(data)
        for i=1:numel(data)
            if isNaN(data{i})
                data{i}='NaN';
            elseif isPositiveInf(data{i})
                data{i}='Inf';
            elseif isNegativeInf(data{i})
                data{i}='-Inf';
            end
        end
    end


end

function data=scrubDataForMerging(data)

    if isnumeric(data)
        data=num2cell(data);
    end


    if iscell(data)
        for i=1:numel(data)
            if isnumeric(data{i})
                data{i}=sprintf('%d',data{i});
            end
        end
    end


end

function out=isNaN(value)
    if isnumeric(value)
        out=isnan(value);
    else
        out=strcmpi(value,'nan');
    end


end

function out=isPositiveInf(value)
    if isnumeric(value)
        out=value==Inf;
    else
        out=strcmpi(value,'inf');
    end


end

function out=isNegativeInf(value)
    if isnumeric(value)
        out=value==-Inf;
    else
        out=strcmpi(value,'-inf');
    end

end

function out=convertToOneDimensional(x)
    numRows=size(x,1);
    numCols=size(x,2);

    if numCols==1
        out=x;
        return;
    end

    out=cell(numRows,1);
    for i=1:numRows
        out{i}=strjoin(x(i,:),', ');
    end



end

function out=getRangesFromArray(arr)
    arr=sort(arr);
    out={};

    i=1;
    while i<=numel(arr)
        startRange=arr(i);
        endRange=startRange;

        while i<numel(arr)&&arr(i+1)-arr(i)==1
            endRange=arr(i+1);
            i=i+1;
        end

        if startRange==endRange
            out{end+1}=startRange;
            i=i+1;
        else
            out{end+1}=[startRange,endRange];
        end
    end



end

function out=getArrayFromRanges(range)
    out=[];

end

function out=columnClassificationChanged(inputs)
    out=inputs;

    variableName=inputs.row.matfileVariableName;
    derivedVariableName=inputs.row.matfileDerivedVariableName;
    matfile=inputs.row.matfileName;


    dataStruct=loadVariable(matfile,variableName);
    derivedData=loadVariable(matfile,derivedVariableName);

    columnNames={inputs.dataInfo.columnInfo.name};
    classification={inputs.dataInfo.columnInfo.classification};
    groupColIdx=find(strcmp(classification,'group'),1);
    timeColIdx=find(strcmp(classification,'independent'),1);

    if strcmpi(inputs.row.type,'programdata')
        data=dataStruct.(inputs.dataInfo.name);
    else
        data=dataStruct;
    end

    if~isempty(groupColIdx)&&inputs.resortData

        sortCols={columnNames{groupColIdx}};

        if~isempty(timeColIdx)
            sortCols{end+1}=columnNames{timeColIdx};
        end


        fullTable=[data,derivedData];


        fullTable=sortrows(fullTable,sortCols);


        if~isempty(derivedData)
            data=fullTable(:,1:(width(fullTable)-width(derivedData)));
            derivedData=fullTable(:,(width(fullTable)-width(derivedData)+1):end);
        else
            data=fullTable;
        end
    end



    data.Properties.VariableDescriptions=classification(ismember(columnNames,data.Properties.VariableNames));


    if~isempty(derivedData)
        derivedData.Properties.VariableDescriptions=classification(ismember(columnNames,derivedData.Properties.VariableNames));
    end



    if strcmpi(inputs.row.type,'programdata')

        dataStruct.(inputs.dataInfo.name)=data;
        saveDataToMATFile(dataStruct,variableName,matfile);
    else

        saveDatasToMATFile({data,derivedData},{variableName,derivedVariableName},matfile);
    end

end

function out=verifyAndUpdateUnits(args)
    inputs=args.inputs;
    warningMsg=struct('message','','severity','');


    if strcmp(inputs.source.type,'externaldata')
        matfile=inputs.source.matfileName;


        if inputs.isExpressionColumn&&strcmp(inputs.dataInfo.type,'table')
            variableName=inputs.source.matfileDerivedVariableName;
            data=loadVariable(matfile,variableName);
        else
            variableName=inputs.source.matfileVariableName;
            data=loadVariable(matfile,variableName);
        end


        if~isempty(data)

            if strcmp(inputs.dataInfo.type,'SimData')
                columnName=inputs.userData.column.columnName;
                units=inputs.userData.column.units;

                [data,warningCell]=updateobservable(data,columnName,'Units',units,'IssueWarnings',false);
                warningMsg=getWarningsForSimDataColumn(columnName,warningCell,[]);


            elseif strcmp(inputs.dataInfo.type,'table')
                units=data.Properties.VariableUnits;
                allColumnNames=data.Properties.VariableNames;
                columnName=inputs.userData.column.columnName;


                if isempty(units)
                    units=repmat({''},1,numel(allColumnNames));
                end

                units{ismember(allColumnNames,columnName)}=inputs.value;
                data.Properties.VariableUnits=units;
            end


            saveDataToMATFile(data,variableName,matfile);
        end
    elseif strcmp(inputs.source.type,'programdata')

        source=inputs.source;
        programData=loadVariable(source.matfileName,source.matfileVariableName);

        if~isempty(inputs.dataInfo.name)
            simdata=programData.(inputs.dataInfo.name);
        end


        if isa(simdata,'SimData')
            observableName=inputs.userData.column.columnName;
            units=inputs.userData.column.units;




            [simdata,warningCell]=updateobservable(simdata,observableName,'Units',units,'IssueWarnings',false);
            warningMsg=getWarningsForSimDataColumn(observableName,warningCell,[]);


            programData.(inputs.dataInfo.name)=simdata;
            saveDataToMATFile(programData,source.matfileVariableName,source.matfileName);

            model=[];
            if isfield(inputs.userData.source,'modelSessionID')&&inputs.userData.source.modelSessionID~=-1
                model=SimBiology.web.modelhandler('getModelFromSessionID',inputs.userData.source.modelSessionID);
            end



            if~isempty(model)
                observable=sbioselect(model,'Name',observableName,'Type','observable');
                if~isempty(observable)

                    w=warning('off','all');


                    observable.Units=units;


                    warning(w);
                end
            end
        elseif istable(programData)
            units=programData.Properties.VariableUnits;
            allColumnNames=programData.Properties.VariableNames;
            columnName=inputs.userData.column.columnName;



            if isempty(units)
                units=repmat({''},1,numel(allColumnNames));
            end


            units{ismember(allColumnNames,columnName)}=inputs.value;
            programData.Properties.VariableUnits=units;


            data=updateVariableInProgramDataStruct(programData,source.variableName,source.matfileVariableName,source.matfile);
            saveDataToMATFile(data,source.matfileVariableName,source.matfileName);
        end
    end


    out=SimBiology.web.unithandler('verifyUnits',args);


    out.info.warningMsg=warningMsg;

end

function deleteFile(name)

    oldState=recycle;
    recycle('off');
    delete(name)
    recycle(oldState);
end
