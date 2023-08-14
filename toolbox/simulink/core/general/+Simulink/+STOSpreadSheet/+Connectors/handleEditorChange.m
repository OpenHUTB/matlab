function handleEditorChange(cbinfo,ev)

    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    st=studios(1);
    stApp=st.App;
    activeEditor=stApp.getActiveEditor;
    blockDiagramHandle=activeEditor.blockDiagramHandle;
    currentLevelModel=getfullname(blockDiagramHandle);
    topLevelModel=getfullname(stApp.topLevelDiagram.handle);

    if(slfeature('GeneralConnector')>0&&...
        isequal(get_param(topLevelModel,'GeneralConnectorDisplay'),'on'))


        set_param(currentLevelModel,'GeneralConnectorDisplay','on');


        compName=char(st.getStudioTag+"ssSimulinkConnectors");
        ssComp=st.getComponent('GLUE2:SpreadSheet',compName);


        mlock;
        ssConfigStr='{"disablepropertyinspectorupdate":true, "expandall":true, "enablemultiselect":false}';


        if(isempty(ssComp)||~ssComp.isvalid)
            ssComp=GLUE2.SpreadSheetComponent(st,compName);
            st.registerComponent(ssComp);
            ssSource=Simulink.STOSpreadSheet.Connectors.ConnectorsSource(...
            currentLevelModel,topLevelModel,ssComp,st);

            st.moveComponentToDock(ssComp,DAStudio.message('Simulink:studio:GeneralConnectors'),'Right','stacked');
            ssComp.setSource(ssSource);
        else
            ssSource=ssComp.getSource;
            ssSource.update(currentLevelModel,topLevelModel,ssComp,st);
            ssComp.setSource(ssSource);
        end
        ssComp.setConfig(ssConfigStr);
        ssComp.disableSort;
        st.showComponent(ssComp);
        ssComp.update();
    else
        set_param(currentLevelModel,'GeneralConnectorDisplay','off');
    end
