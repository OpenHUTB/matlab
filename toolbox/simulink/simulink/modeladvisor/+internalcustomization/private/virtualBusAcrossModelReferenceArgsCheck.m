function ResultDescription=virtualBusAcrossModelReferenceArgsCheck(system)




    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    if get_param(bdroot(system),'handle')~=get_param(system,'handle')
        ResultDescription=ModelAdvisor.Text(DAStudio.message('Simulink:tools:MAUnableToRunCheckOnSubsystem'));
        mdladvObj.setCheckResultStatus(false);
        return;
    end
    checkData=loc_doAdvisorCheck(system);
    [checkData,ResultDescription]=loc_ReportResult(checkData);


    currentCheckObj=mdladvObj.CheckCellArray{mdladvObj.ActiveCheckID};
    currentCheckObj.ResultData=checkData;

    if checkData.hasIssue
        mdladvObj.setCheckResultStatus(false);
        mdladvObj.setActionEnable(true);
    else
        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(false);
    end
end




function checkData=loc_doAdvisorCheck(topModel)
    checkData.hasIssue=false;
    checkData.argLimit=loc_getArgumentLimit(topModel);


    loc_buildModelRefSimTargets(topModel);


    checkData.info=loc_analyzeHierarchy(topModel);
end




function[checkData,ResultDescription]=loc_ReportResult(checkData)
    ResultDescription={};
    argLimit=checkData.argLimit;

    if(isempty(checkData.info.refModels))
        ResultDescription{end+1}=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReferenceArgs_NoRefModels'));
    else
        modelsToReport=[];

        for mdlIdx=1:length(checkData.info.refModels)
            refModel=checkData.info.refModels{mdlIdx};
            refModelData=checkData.info.refModelData(refModel);

            maxCount=0;
            maxFcn='';

            if(~isempty(refModelData))
                fcns=fields(refModelData);
                for fcnIdx=1:length(fcns)
                    fcn=fcns{fcnIdx};

                    before=refModelData.(fcn).before;
                    after=refModelData.(fcn).after;
                    delta=before-after;
                    if((delta>argLimit)&&(delta>maxCount))
                        maxCount=delta;
                        maxFcn=fcn;
                    end
                end
            end

            if(maxCount>0)
                modelToReport.model=refModel;
                modelToReport.fcn=refModelData.(maxFcn).name;
                modelToReport.before=refModelData.(maxFcn).before;
                modelToReport.after=refModelData.(maxFcn).after;

                if(isempty(modelsToReport))
                    modelsToReport=modelToReport;
                else
                    modelsToReport(end+1)=modelToReport;%#ok<AGROW>
                end
            end
        end

        if(isempty(modelsToReport))
            ResultDescription{end+1}=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReferenceArgs_NoUpdatesNeeded'));
        else
            checkData.hasIssue=true;
            ResultDescription{end+1}=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReferenceArgs_NeedsUpdateHeader'));


            [~,indexes]=sort({modelsToReport.model});
            modelsToReport=modelsToReport(indexes);

            numIssues=length(modelsToReport);
            table=ModelAdvisor.Table(numIssues,4);
            table.setColHeading(1,DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReferenceArgs_ModelColumn'));
            table.setColHeading(2,DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReferenceArgs_MethodNameColumn'));
            table.setColHeading(3,DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReferenceArgs_BeforeColumn'));
            table.setColHeading(4,DAStudio.message('ModelAdvisor:engine:MACheckVirtualBusAcrossModelReferenceArgs_AfterColumn'));

            for i=1:numIssues
                table.setEntry(i,1,modelsToReport(i).model);
                table.setEntry(i,2,modelsToReport(i).fcn);
                table.setEntry(i,3,num2str(modelsToReport(i).before));
                table.setEntry(i,4,num2str(modelsToReport(i).after));
            end

            checkData.modelsToEdit={modelsToReport.model};
            ResultDescription{end+1}=table;
        end
    end
end



function data=loc_analyzeHierarchy(topModel)
    data=[];
    if Simulink.internal.useFindSystemVariantsMatchFilter()
        data.refModels=find_mdlrefs(topModel,...
        'IncludeProtectedModels',false,...
        'MatchFilter',@Simulink.match.activeVariants,...
        'IncludeCommented',false,...
        'ReturnTopModelAsLastElement',false);
    else
        data.refModels=find_mdlrefs(topModel,...
        'IncludeProtectedModels',false,...
        'Variants','ActiveVariants',...
        'IncludeCommented',false,...
        'ReturnTopModelAsLastElement',false);
    end

    data.refModelData=containers.Map('KeyType','char','ValueType','any');



    lSystemTargetFile=get_param(topModel,'SystemTargetFile');

    for i=1:length(data.refModels)
        refModel=data.refModels{i};
        refModelData=loc_analyzeOneModel(refModel,lSystemTargetFile);
        data.refModelData(refModel)=refModelData;
    end
end



function data=loc_analyzeOneModel(refModel,lSystemTargetFile)
    data=[];




    infoStruct=coder.internal.infoMATPostBuild...
    ('load','binfo',refModel,'SIM',lSystemTargetFile);
    ouFcns=loc_getOutputUpdateFunctions(infoStruct);
    for i=1:length(ouFcns)
        ouFcn=ouFcns{i};
        data.(ouFcn)=loc_analyzeOneFunction(infoStruct,ouFcn);
    end
end




function data=loc_analyzeOneFunction(infoStruct,ouFcn)
    fcnDef=infoStruct.modelInterface.(ouFcn);
    fcnName=fcnDef.FcnName;

    if(fcnDef.NumArgs==0)
        before=0;
        after=0;
    else
        if(isfield(infoStruct.modelInterface,'Inports'))
            origInportNum=getOriginalPort(infoStruct.modelInterface.Inports);
            usedExpandedInputPorts=loc_getUsedPorts(fcnDef.ArgSource,'I');

            usedCollapsedInputPorts=unique(origInportNum(usedExpandedInputPorts+1));
            deltaInputs=length(usedCollapsedInputPorts)-length(usedExpandedInputPorts);
        else
            deltaInputs=0;
        end

        if(isfield(infoStruct.modelInterface,'Outports'))

            origOutportNum=getOriginalPort(infoStruct.modelInterface.Outports);
            usedExpandedOutputPorts=loc_getUsedPorts(fcnDef.ArgSource,'O');

            usedCollapsedOutputPorts=unique(origOutportNum(usedExpandedOutputPorts+1));
            deltaOutputs=length(usedCollapsedOutputPorts)-length(usedExpandedOutputPorts);
        else
            deltaOutputs=0;
        end

        argSourceSize=size(fcnDef.ArgSource);
        before=argSourceSize(1);
        after=before+deltaInputs+deltaOutputs;
    end

    data=struct(...
    'before',before,...
    'after',after,...
    'name',fcnName);
end




function usedPorts=loc_getUsedPorts(argSources,inout)
    usedPorts=[];
    sizes=size(argSources);
    for i=1:sizes(1)
        argSource=argSources(i,:);



        tokenNames=regexp(argSource,['^',inout,'(?<port>\d+)(\s|\0)*$'],'names');

        if(~isempty(tokenNames))
            usedPorts(end+1)=str2double(tokenNames.port);%#ok<AGROW>
        end
    end
end






function ouFcns=loc_getOutputUpdateFunctions(infoStruct)
    fieldNames=fields(infoStruct.modelInterface);
    matches=regexp(fieldNames,'^(Output|Update|OutputUpdate)(TID\d+)?Fcn$');
    ouFcns=fieldNames(cellfun(@(x)~isempty(x),matches,'UniformOutput',true));
end






function maxAllowed=loc_getArgumentLimit(model)
    try
        maxAllowed=get_param(model,'PassReuseOutputArgsThreshhold');
    catch
        maxAllowed=12;
    end
end





function loc_buildModelRefSimTargets(topModel)
    if Simulink.internal.useFindSystemVariantsMatchFilter()
        refMdls=find_mdlrefs(topModel,...
        'AllLevels',false,...
        'IncludeProtectedModels',false,...
        'MatchFilter',@Simulink.match.activeVariants,...
        'IncludeCommented',false,...
        'ReturnTopModelAsLastElement',false);
    else
        refMdls=find_mdlrefs(topModel,...
        'AllLevels',false,...
        'IncludeProtectedModels',false,...
        'Variants','ActiveVariants',...
        'IncludeCommented',false,...
        'ReturnTopModelAsLastElement',false);
    end

    for i=1:length(refMdls)
        refMdl=refMdls{i};
        slbuild(refMdl,'ModelReferenceSimTarget');
    end
end

function originalPort=getOriginalPort(ports)
    if(isempty(ports))
        originalPort=[];
    else
        if(~iscell(ports))
            ports={ports};
        end
        originalPort=cellfun(@(x)x.OriginalPortIndex,ports,'UniformOutput',true);
    end
end
