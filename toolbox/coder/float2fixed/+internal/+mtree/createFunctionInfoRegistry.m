function[fcnInfoRegistry,exprMap,designNames,messages]=createFunctionInfoRegistry(report,chartData)





    if nargin<2

        chartData=internal.mtree.mlfb.IOInfo;
    end

    messages=internal.mtree.Message.empty;

    [userWrittenFunctions,designNames]=getUserWrittenFunctions(report);
    fcnInfoRegistry=coder.internal.FunctionTypeInfoRegistry;
    [~,exprMap]=internal.mtree.FcnInfoRegistryBuilder.populateFcnInfoRegistryFromInferenceInfo(...
    report,designNames,userWrittenFunctions,chartData,fcnInfoRegistry,{});

    functionIds=fcnInfoRegistry.registry.keys();




    if isempty(functionIds)
        messages(end+1)=internal.mtree.Message([],[],...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:OnlyInternalCode');
    end


    for i=1:length(functionIds)
        functionId=functionIds{i};

        fcnTypeInfo=fcnInfoRegistry.getFunctionTypeInfo(functionId);
        if fcnTypeInfo.isPCoded
            messages(end+1)=internal.mtree.Message(...
            fcnTypeInfo,...
            [],...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:NoPCode',...
            fcnTypeInfo.functionName);%#ok<AGROW>
        end
    end

    if internal.mtree.Message.containErrorMsgs(messages)
        return;
    end



    for i=1:length(functionIds)
        functionId=functionIds{i};

        fcnTypeInfo=fcnInfoRegistry.getFunctionTypeInfo(functionId);

        fcnExprInfo=coder.internal.lib.Map.empty();
        if~isempty(exprMap)&&isKey(exprMap,functionId)
            fcnExprInfo=exprMap(functionId);
        end

        internal.mtree.analysis.FillCompiledInfoPass(fcnTypeInfo,fcnExprInfo).run();



        constrainer=coder.internal.Float2FixedConstrainer(fcnTypeInfo.tree,...
        fcnTypeInfo,fcnTypeInfo.scriptPath,false,false,[]);
        constrainer.setCompiledExprInfo(fcnExprInfo);
        constrainer.constrain();
    end





    specializationMsgs=internal.mtree.utils.checkSpecializationsAreEquivalent(...
    fcnInfoRegistry,exprMap);

    messages=[messages,specializationMsgs];


    try
        internal.mtree.analysis.ConstAnnotator.run(fcnInfoRegistry,false,inf);
    catch ex
        internal.mtree.utils.errorWithContext(ex,'Constant folding error: ');
    end
end

function[userWrittenFunctions,designNames]=getUserWrittenFunctions(inferenceReport)
    inferenceReportFunctions=inferenceReport.Functions;
    inferenceReportScripts=inferenceReport.Scripts;
    rootFcns=inferenceReport.RootFunctionIDs;

    designNames=cell(1,length(inferenceReportFunctions));
    designNamesIdx=1;

    userWrittenFunctions=containers.Map;
    for ii=1:length(inferenceReportFunctions)
        fcnInfo=inferenceReportFunctions(ii);
        fcnName=fcnInfo.FunctionName;

        if(fcnInfo.ScriptID<1)||...
            (fcnInfo.ScriptID>length(inferenceReportScripts))
            continue;
        end

        script=inferenceReportScripts(fcnInfo.ScriptID);

        if~script.IsUserVisible&&~internal.mtree.isTranslatableInternalFunction(script.ScriptPath)


            continue;
        end






        userWrittenFunctions(fcnName)=true;

        if any(ii==rootFcns)
            designNames{designNamesIdx}=fcnName;
            designNamesIdx=designNamesIdx+1;
        end
    end

    designNames(designNamesIdx:end)=[];
end


