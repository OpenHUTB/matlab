function[idMap,ids]=EMLInstrumentationMLInterface(in,isOvCount)




    map=[];
    ids=[];
    idMap=createEmptyMap(in);
    if(~isempty(in))
        mdl=Simulink.ID.getModel(in(1).Key(2:end));


        appData=SimulinkFixedPoint.getApplicationData(mdl);
        fptDataset=appData.dataset;
        runName=get_param(mdl,'FPTRunName');
        runObj=fptDataset.getRun(runName);
    end
    for chartIdx=1:size(in,2)
        results.Functions=in(chartIdx).Functions;
        key=in(chartIdx).Key;
        blockSID=key(2:end);
        blockHandle=Simulink.ID.getHandle(blockSID);
        blockObj=get_param(blockHandle,'Object');
        blockChildren=blockObj.getChildren;
        chartIndex=arrayfun(@(blockChild)isa(blockChild,'Stateflow.EMChart'),blockChildren);
        emlChart=blockChildren(chartIndex);
        chartId=emlChart.Id;
        chartDir=sf('SFunctionSpecialization',chartId,blockHandle);
        [~,~,mainInfoName,~]=sfprivate('get_report_path',pwd,chartDir,false);




        fileInfo=dir(mainInfoName);
        uniqueFileKey=sprintf('%s %s',mainInfoName,fileInfo.date);

        load(mainInfoName,'report');
        results.CompilationReport=report;


        results.MexFileName='';
        results.TimeStamp='';
        results.buildDir='';

        results.NumberOfHistogramBins=0;
        [CompilationReport,loggedVariables]=...
        fixed.internal.processInstrumentedMxInfoLocations(results);

        loggedVariables.SID=blockSID;





        if(isOvCount==1)

            fxptds.putMATLABFunctionBlockDataIntoRunObject(...
            runObj,CompilationReport,loggedVariables,uniqueFileKey);



            mergedRunObj=fptDataset.getRun(fxptds.FPTDataset.MLFBInternalRunName());
            fxptds.putMATLABFunctionBlockDataIntoRunObject(...
            mergedRunObj,CompilationReport,loggedVariables,uniqueFileKey);

        else

            assert(isequal(isOvCount,0));

            [tempMap,tempIds]=createIdentifiersMap(CompilationReport,loggedVariables,uniqueFileKey);

            map=[map;tempMap];%#ok<AGROW>
            ids=[ids;tempIds];%#ok<AGROW>

        end
    end

    if(isOvCount==0)
        idMap=populateIDStrings(idMap,map);
    end

end

function idMap=populateIDStrings(idMap,map)
    for mapIndex=1:size(idMap,2)
        thisPoint=idMap(mapIndex).VarIDsArrayIdx;
        if map.isKey(thisPoint)
            idMap(mapIndex).VarIDs=cell(map(thisPoint).toArray);
        end
    end
end

function idMap=createEmptyMap(in)

    idMap=[];

    count=1;
    for chartIdx=1:size(in,2)
        Functions=in(chartIdx).Functions;


        key=in(chartIdx).Key;
        blockSID=key(2:end);
        blockHandle=Simulink.ID.getHandle(blockSID);
        blockObj=get_param(blockHandle,'Object');
        blockChildren=blockObj.getChildren;
        chartIndex=arrayfun(@(blockChild)isa(blockChild,'Stateflow.EMChart'),blockChildren);
        emlChart=blockChildren(chartIndex);
        chartId=emlChart.Id;
        for fcnIdx=1:size(Functions,2)
            loggedLocations=Functions(fcnIdx).loggedLocations;
            for locIdx=1:size(loggedLocations,2)
                idMap(count).VarIDsArrayIdx=loggedLocations(locIdx).VarIDsArrayIdx;%#ok<AGROW>
                idMap(count).blockHandle=blockHandle;%#ok<AGROW>
                idMap(count).chartId=chartId;%#ok<AGROW>
                idMap(count).VarIDs={};%#ok<AGROW>
                count=count+1;
            end
        end
    end

end

function[map,ids]=createIdentifiersMap(CompilationReport,loggedVariablesData,uniqueFileKey)

    functionIds=zeros(1,length(loggedVariablesData.Functions));
    for compReportFunctionIndex=1:length(loggedVariablesData.Functions)
        functionIds(compReportFunctionIndex)=CompilationReport.InstrumentedData.InstrumentedFunctions(compReportFunctionIndex).FunctionID;
    end

    mxInfos=loggedVariablesData.MxInfos;
    map=containers.Map('KeyType','double','ValueType','any');
    ids=containers.Map;

    masterInference=fxptds.MATLABIdentifier.setCurrentInferenceReport(CompilationReport.inference,uniqueFileKey);

    for j=1:length(loggedVariablesData.Functions)

        logged_function=loggedVariablesData.Functions(j);

        ScriptID=CompilationReport.inference.Functions(logged_function.FunctionID).ScriptID;
        function_identifier=fxptds.MATLABFunctionIdentifier(...
        loggedVariablesData.SID,...
        CompilationReport.inference.Scripts(ScriptID).ScriptPath,...
        logged_function.FunctionID,...
        logged_function.InstanceCount,...
        logged_function.NumberOfInstances,...
        CompilationReport.inference.RootFunctionIDs,...
        masterInference);

        compReportFunctionIndex=(functionIds==logged_function.FunctionID);
        instrumentedLocations=CompilationReport.InstrumentedData.InstrumentedFunctions(compReportFunctionIndex).InstrumentedMxInfoLocations;

        [expressionIDs,exprArrayIndexes]=createExprIDs(function_identifier,...
        instrumentedLocations,...
        masterInference);

        data_array=createVarIdData(function_identifier,...
        logged_function.NamedVariables,...
        expressionIDs,...
        mxInfos);
        varIDs=createVarIDs(data_array);

        currentFuncMap=containers.Map('KeyType','double','ValueType','any');
        currentFuncIds=containers.Map;


        for arrayIndex=1:numel(data_array)
            currentExprLocations=data_array{arrayIndex}.MxInfoLocationIDs;
            for exprindex=1:numel(currentExprLocations)
                currentExpr=currentExprLocations(exprindex);
                instPoints=exprArrayIndexes{currentExpr};
                for i=1:numel(instPoints)
                    instPoint=instPoints(i).idx;

                    if instPoint==-1
                        continue;
                    end


                    if(isfield(data_array{arrayIndex},'LoggedField')&&...
                        ~strcmp(instPoints(i).field,data_array{arrayIndex}.LoggedField))
                        continue;
                    end

                    if~currentFuncMap.isKey(instPoint)
                        currentFuncMap(instPoint)=java.util.HashSet;
                    end

                    currentFuncMap(instPoint).add(expressionIDs(currentExpr).UniqueKey);
                    currentFuncMap(instPoint).add(varIDs{arrayIndex}.UniqueKey);

                    currentFuncIds(expressionIDs(currentExpr).UniqueKey)=expressionIDs(currentExpr);
                    currentFuncIds(varIDs{arrayIndex}.UniqueKey)=varIDs{arrayIndex};
                end
            end
        end


        for exprIndex=1:length(exprArrayIndexes)
            pointIndices=exprArrayIndexes{exprIndex};
            for i=1:numel(pointIndices)
                pointIndex=pointIndices(i).idx;

                if pointIndex==-1
                    continue;
                end

                if~currentFuncMap.isKey(pointIndex)
                    currentFuncMap(pointIndex)=java.util.HashSet;
                end

                currentFuncMap(pointIndex).add(expressionIDs(exprIndex).UniqueKey);
                currentFuncIds(expressionIDs(exprIndex).UniqueKey)=expressionIDs(exprIndex);
            end
        end


        map=mergeMaps(map,currentFuncMap);
        ids=mergeMaps(ids,currentFuncIds);
    end
end

function mergedMap=mergeMaps(mapA,mapB)
    if isempty(mapA)
        mergedMap=mapB;
        return;
    end

    keys=mapB.keys;
    for i=1:numel(keys)
        if isa(mapB(keys{i}),'java.util.HashSet')
            if mapA.isKey(keys{i})
                mapA(keys{i}).addAll(mapB(keys{i}));
            else
                mapA(keys{i})=mapB(keys{i});
            end
        else
            mapA(keys{i})=mapB(keys{i});
        end
    end

    mergedMap=mapA;
end

function[ids,exprArrayIndexes]=createExprIDs(function_identifier,locations,masterInference)
    numLocations=size(locations,2);
    ids=fxptds.MATLABExpressionIdentifier.empty(0,numLocations);

    exprArrayIndexes=cell(1,numLocations);
    exprArrayIndexes(:)={struct('idx',-1)};

    for locationCount=1:numLocations
        location=locations(locationCount);

        ids(locationCount)=fxptds.MATLABExpressionIdentifier(...
        function_identifier,...
        location.MxInfoID,...
        location.TextStart,...
        location.TextLength,...
        location.IsArgin,...
        location.IsArgout,...
        location.IsGlobal,...
        location.IsPersistent,...
        location.Reason,...
        masterInference);

        if~isempty(location.VarIDsArrayIndex)
            exprArrayIndexes{locationCount}=[];
            for i=1:numel(location.VarIDsArrayIndex)
                exprArrayIndexes{locationCount}=...
                [exprArrayIndexes{locationCount},location.VarIDsArrayIndex(i)];
            end
        end
    end
end

function data_array=createVarIdData(function_identifier,named_variables,expressionIDs,mxInfos)




    nvars_expanded=0;
    nstructs=0;
    for k=1:length(named_variables)

        named_variable=named_variables(k);
        mxInfoID=named_variable.MxInfoID;
        mxInfo=mxInfos{mxInfoID};
        if isa(mxInfo,'eml.MxStructInfo')
            nvars_expanded=nvars_expanded+length(named_variable.LoggedFieldNames);
            nstructs=nstructs+1;
        else
            nvars_expanded=nvars_expanded+1;
        end
    end

    if nstructs==0


        data_array=cell(1,length(named_variables));
        for k=1:length(named_variables)
            data_array{k}=named_variables(k);
            data_array{k}.MATLABFunctionIdentifier=function_identifier;
            data_array{k}.MATLABExpressionIdentifiers=expressionIDs(data_array{k}.MxInfoLocationIDs);
        end
    else




        data_array=cell(1,nvars_expanded);
        n_data_array=0;

        for k=1:length(named_variables)
            named_variable=named_variables(k);
            named_variable.MATLABFunctionIdentifier=function_identifier;
            mxInfoID=named_variable.MxInfoID;
            mxInfo=mxInfos{mxInfoID};
            if isa(mxInfo,'eml.MxStructInfo')
                for m=1:length(named_variable.LoggedFieldNames)
                    field_name=[named_variable.SymbolName,'.',...
                    named_variable.LoggedFieldNames{m}];
                    n_data_array=n_data_array+1;
                    data_array{n_data_array}=named_variable;


                    data_array{n_data_array}.SymbolName=field_name;
                    data_array{n_data_array}.MxInfoID=named_variable.LoggedFieldMxInfoIDs{m}(end);
                    data_array{n_data_array}.SimMin=named_variable.SimMin(m);
                    data_array{n_data_array}.SimMax=named_variable.SimMax(m);
                    data_array{n_data_array}.IsAlwaysInteger=named_variable.IsAlwaysInteger(m);
                    data_array{n_data_array}.NumberOfZeros=named_variable.NumberOfZeros(m);
                    data_array{n_data_array}.NumberOfPositiveValues=named_variable.NumberOfPositiveValues(m);
                    data_array{n_data_array}.NumberOfNegativeValues=named_variable.NumberOfNegativeValues(m);
                    data_array{n_data_array}.TotalNumberOfValues=named_variable.TotalNumberOfValues(m);
                    data_array{n_data_array}.SimSum=named_variable.SimSum(m);
                    data_array{n_data_array}.HistogramOfPositiveValues=named_variable.HistogramOfPositiveValues(m,:);
                    data_array{n_data_array}.HistogramOfNegativeValues=named_variable.HistogramOfNegativeValues(m,:);
                    data_array{n_data_array}.LoggedFieldNames={};
                    data_array{n_data_array}.LoggedFieldMxInfoIDs={};
                    data_array{n_data_array}.ProposedSignedness=named_variable.ProposedSignedness(m);
                    data_array{n_data_array}.ProposedWordLengths=named_variable.ProposedWordLengths(m);
                    data_array{n_data_array}.ProposedFractionLengths=named_variable.ProposedFractionLengths(m);
                    data_array{n_data_array}.OutOfRange=named_variable.OutOfRange(m);
                    data_array{n_data_array}.RatioOfRange=named_variable.RatioOfRange(m);
                    data_array{n_data_array}.MATLABExpressionIdentifiers=expressionIDs(named_variable.MxInfoLocationIDs);
                    data_array{n_data_array}.LoggedField=named_variable.LoggedFieldNames{m};
                end
            else
                n_data_array=n_data_array+1;
                data_array{n_data_array}=named_variable;
                data_array{n_data_array}.MATLABExpressionIdentifiers=expressionIDs(named_variable.MxInfoLocationIDs);
            end
        end
    end
end

function ids=createVarIDs(data)
    numVarIDs=numel(data);
    ids=cell(1,numVarIDs);

    for varIndex=1:numVarIDs
        ids{varIndex}=fxptds.MATLABVariableIdentifier(...
        data{varIndex}.MATLABFunctionIdentifier,...
        data{varIndex}.MATLABExpressionIdentifiers,...
        data{varIndex}.SymbolName,...
        data{varIndex}.MxInfoID,...
        data{varIndex}.InstanceCount,...
        data{varIndex}.NumberOfInstances,...
        data{varIndex}.TextLength);
    end
end

