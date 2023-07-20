function handleEditorChange(cbinfo,ev)

    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    st=studios(1);
    stApp=st.App;
    activeEditor=stApp.getActiveEditor;
    blockDiagramHandle=activeEditor.blockDiagramHandle;
    currentLevelModel=getfullname(blockDiagramHandle);
    topLevelModel=getfullname(stApp.topLevelDiagram.handle);

    if(slfeature('TaskBasedSorting')>0&&...
        isequal(get_param(topLevelModel,'ExecutionOrderLegendDisplay'),'on'))


        set_param(currentLevelModel,'ExecutionOrderLegendDisplay','on');


        if(isa(st.App.getActiveModel,'StateflowDI.Model')||...
            Simulink.internal.isArchitectureModel(currentLevelModel))
            taskIdVec=[];
            systemIdx=-101;
        else
            [taskIdVec,systemIdx]=Simulink.STOSpreadSheet.SortedOrder.subsystemTaskIdxCollection(st.App.getActiveModel.diagram.handle);
        end


        compName=char(st.getStudioTag+"ssTaskLegend");
        ssComp=st.getComponent('GLUE2:SpreadSheet',compName);

        warningStruct=warning('off','Simulink:Engine:CompileNeededForSampleTimes');
        legendBlockInfo=get_param(currentLevelModel,'rateIndexTaskIdxMap');
        warning(warningStruct.state,'Simulink:Engine:CompileNeededForSampleTimes');

        if(isempty(legendBlockInfo)&&~isempty(ssComp)&&ssComp.isvalid)
            st.hideComponent(ssComp);
            return;
        end

        mlock;
        ssConfigStr='{"disablepropertyinspectorupdate":true, "expandall":true}';

        if(isempty(ssComp)||~ssComp.isvalid)
            ssComp=GLUE2.SpreadSheetComponent(st,compName);
            st.registerComponent(ssComp);
            ssSource=Simulink.STOSpreadSheet.SortedOrder.SortedOrderSource(...
            currentLevelModel,topLevelModel,ssComp,st,taskIdVec,systemIdx);

            st.moveComponentToDock(ssComp,'Execution Order','Right','stacked');
            ssComp.setSource(ssSource);
        else
            ssSource=ssComp.getSource;
            ssSource.update(currentLevelModel,topLevelModel,ssComp,st,taskIdVec,systemIdx);
            ssComp.setSource(ssSource);
        end
        ssComp.setConfig(ssConfigStr);
        ssComp.disableSort;
        st.showComponent(ssComp);
        ssComp.update();
    else
        set_param(currentLevelModel,'ExecutionOrderLegendDisplay','off');
    end