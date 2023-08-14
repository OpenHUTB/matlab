
function debugUsingSlicerRefresher(cbinfo,action)





    [res,isTestGen]=isBlockValidForDebug(cbinfo);
    if res
        action.enabled=true;
    else
        action.enabled=false;
    end
    if isTestGen
        action.text="Sldv:toolstrip:InspectUsingSlicerDesignVerifierActionText";
        action.description="Sldv:toolstrip:InspectUsingSlicerDesignVerifierActionDescription";
        action.icon="inspectUsingSlicer";
    else
        action.text="Sldv:toolstrip:DebugUsingSlicerDesignVerifierActionText";
        action.description="Sldv:toolstrip:DebugUsingSlicerDesignVerifierActionDescription";
        action.icon="debugUsingSlicer";
    end
end

function[res,isTestGen]=isBlockValidForDebug(cbinfo)
    res=true;
    isTestGen=false;

    if~isAnalysisDataFileExists(cbinfo)
        res=false;
        return;
    end


    [status,isTestGen]=isDebuggableBlockSelected(cbinfo);
    if~status
        res=false;
        return;
    end

    function yesno=isAnalysisDataFileExists(cbinfo)
        appContext=Sldv.ui.toolstrip.internal.getappcontextobj(cbinfo);
        if~isempty(appContext)&&~isempty(appContext.currentResults.DataFile)
            yesno=true;
        elseif isDataFileExistsInBdRootMdlForObsBlks(cbinfo)
            yesno=true;
        else
            yesno=false;
        end

        function isFileExists=isDataFileExistsInBdRootMdlForObsBlks(cbinfo)
            isFileExists=false;
            model=SLStudio.Utils.getModelName(cbinfo);
            modelH=get_param(model,'Handle');


            modelH=Sldv.ui.toolstrip.results.updateModelHandleIfObsMdl(modelH);


            avData=get_param(modelH,'AutoVerifyData');
            if isfield(avData,'currentResult')&&~isempty(avData.currentResult.DataFile)
                isFileExists=true;
            end
        end
    end

    function[yesno,isTestGen]=isDebuggableBlockSelected(cbinfo)
        yesno=true;
        isTestGen=false;
        debugService=[];

        model=SLStudio.Utils.getModelName(cbinfo);
        modelH=get_param(model,'Handle');


        modelH=Sldv.ui.toolstrip.results.updateModelHandleIfObsMdl(modelH);


        avData=get_param(modelH,'AutoVerifyData');
        if isfield(avData,'DebugService')&&~isempty(avData.DebugService)
            debugService=avData.DebugService;
            isTestGen=SldvDebugger.DebugService.isGeneratedForTestGeneration(debugService.sldvData);
        end


        selectedObjectHandle=[];
        if isa(cbinfo.domain,'SLM3I.SLDomain')
            selectedObjectHandle=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
        elseif isa(cbinfo.domain,'StateflowDI.SFDomain')
            selectedStatesAndTransitionIds=SFStudio.Utils.getSelectedStatesAndTransitionIds(cbinfo);
            selectedObjectHandle=idToHandle(sfroot,selectedStatesAndTransitionIds);
        end


        if length(selectedObjectHandle)>1||isempty(selectedObjectHandle)
            yesno=false;
            return;
        end

        selectedObjectSID=Simulink.ID.getSID(selectedObjectHandle);

        if~isempty(debugService)

            if isTestGen&&isBlockInspectable(debugService,selectedObjectSID)
                yesno=true;
                return;
            end


            if~isObjectivesTypeArrayBounds(selectedObjectSID,debugService)
                yesno=false;
                return;
            end



            isFalsifiedBlock=debugService.isDebugEnabled(selectedObjectSID);
            if~isFalsifiedBlock
                yesno=false;
            end
        else
            yesno=false;
        end
    end

    function yesno=isObjectivesTypeArrayBounds(selectedObjectSID,debugService)
        yesno=true;


        objId=debugService.getObjectiveIdFromSid(selectedObjectSID);
        if~isempty(objId)
            cntObjOfTypeArrayBounds=0;
            for i=1:length(objId)
                type=debugService.getObjectiveType(objId(i));
                if strcmp(type,'Array bounds')
                    cntObjOfTypeArrayBounds=cntObjOfTypeArrayBounds+1;
                end
            end
            if eq(length(objId),cntObjOfTypeArrayBounds)
                yesno=false;
            end
        else
            yesno=false;
        end
    end

    function yesNo=isBlockInspectable(debugService,selectedObjectSID)

        yesNo=false;
        objectivesId=debugService.getObjectiveIdFromSid(selectedObjectSID);

        if~isempty(objectivesId)


            for idx=1:length(objectivesId)
                sldvObjective=debugService.sldvData.Objectives(objectivesId(idx));

                if isfield(sldvObjective,'testCaseIdx')&&...
                    ~isempty(sldvObjective.testCaseIdx)
                    yesNo=true;
                    return;
                end
            end
        end
    end
end
