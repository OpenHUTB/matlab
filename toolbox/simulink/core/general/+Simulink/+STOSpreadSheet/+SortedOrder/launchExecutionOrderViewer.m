function launchExecutionOrderViewer(studio)


    st=studio;
    stApp=st.App;
    activeEditor=stApp.getActiveEditor;
    blockDiagramHandle=activeEditor.blockDiagramHandle;
    currentLevelModel=getfullname(blockDiagramHandle);
    topLevelModel=getfullname(stApp.topLevelDiagram.handle);



    if(slfeature('TaskBasedSorting')>0&&...
        isequal(get_param(topLevelModel,'ExecutionOrderLegendDisplay'),'on'))

        compName=char(st.getStudioTag+"ssTaskLegend");
        ssComp=st.getComponent('GLUE2:SpreadSheet',compName);



        if(isa(st.App.getActiveModel,'StateflowDI.Model')||...
            Simulink.internal.isArchitectureModel(currentLevelModel))
            taskIdVec=[];
            systemIdx=-101;
        else
            [taskIdVec,systemIdx]=Simulink.STOSpreadSheet.SortedOrder.subsystemTaskIdxCollection(st.App.getActiveModel.diagram.handle);
        end

        warningStruct=warning('off','Simulink:Engine:CompileNeededForSampleTimes');
        legendBlockInfo=get_param(currentLevelModel,'rateIndexTaskIdxMap');
        warning(warningStruct.state,'Simulink:Engine:CompileNeededForSampleTimes');

        if(isempty(legendBlockInfo)&&~isempty(ssComp)&&ssComp.isvalid)
            st.hideComponent(ssComp);
            return;
        end

        mlock;
        ssConfigStr='{"disablepropertyinspectorupdate":true, "expandall":true, "enablemultiselect":false}';

        if(isempty(ssComp)||~ssComp.isvalid)
            ssComp=GLUE2.SpreadSheetComponent(st,compName);
            st.registerComponent(ssComp);
            ssSource=Simulink.STOSpreadSheet.SortedOrder.SortedOrderSource(...
            currentLevelModel,topLevelModel,ssComp,st,taskIdVec,systemIdx);

            st.moveComponentToDock(ssComp,DAStudio.message('Simulink:studio:ExecutionOrderTitle'),'Right','stacked');
            ssComp.setSource(ssSource);
        else
            if(ssComp.isVisible)
                ssSource=ssComp.getSource;
                ssSource.currentSelection=ssSource;
                ssSource.update(currentLevelModel,topLevelModel,ssComp,st,taskIdVec,systemIdx);
                ssComp.setSource(ssSource);
                if(isequal(length(ssSource.mTaskData),1))
                    ssSource.handleSelectionChange(ssComp,ssSource.mTaskData);
                end
            else
                ssSource=Simulink.STOSpreadSheet.SortedOrder.SortedOrderSource(...
                currentLevelModel,topLevelModel,ssComp,st,taskIdVec,systemIdx);
                ssComp.setSource(ssSource);
            end
        end
        ssComp.setConfig(ssConfigStr);
        ssComp.disableSort;
        st.showComponent(ssComp);
        ssComp.update();

        if bdIsLoaded(topLevelModel)
            modelHandle=get_param(topLevelModel,'Handle');
            Simulink.addBlockDiagramCallback(modelHandle,...
            'PostNameChange','ExecutionOrderViewer',...
            @()Simulink.STOSpreadSheet.SortedOrder.changeModelName(topLevelModel,get_param(modelHandle,'Name')),...
            true);
        end

        c=st.getService('GLUE2:ActiveEditorChanged');
        registerCallbackId=c.registerServiceCallback(@Simulink.STOSpreadSheet.SortedOrder.handleEditorChange);%#ok<NASGU>

    end

end
