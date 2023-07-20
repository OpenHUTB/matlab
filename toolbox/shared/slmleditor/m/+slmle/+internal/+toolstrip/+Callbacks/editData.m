function editData(userdata,cbinfo)




    if~strcmp(userdata,'edit_data')
        return;
    end

    studio=cbinfo.studio;
    studioTag=studio.getStudioTag();
    e=cbinfo.studio.App.getActiveEditor;
    diagram=e.getDiagram;
    chartId=sfprivate('block2chart',diagram.blockHandle);


    sM=studio.getComponent('GLUE2:DDG Component','SymbolManager');

    if isempty(sM)
        viewObjId=chartId;
        Stateflow.internal.SymbolManager.ShowSymbolManagerForStudio(viewObjId,chartId,studioTag);
        sM=studio.getComponent('GLUE2:DDG Component','SymbolManager');
    end


    sM.dock;


    if sM.isMinimized()
        sM.restore();
    elseif~sM.isVisible
        symbolPaneObj=Stateflow.internal.SymbolManager.GetAllSymbolManagers;


        if length(symbolPaneObj)>1
            for i=1:length(symbolpaneObj)
                if symbolpaneObj(i).currentSubviewerId==chartId
                    symbolPaneObj=symbolPaneObj(i);
                    break;
                end
            end
        end



        symbolPaneObj.showInterfacePanel(false);
    end



    pi=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');
    pi.dock;
    if pi.isMinimized()
        pi.restore();
    elseif~pi.isVisible
        showComponent(studio,pi);
    end




    selectedItems=Stateflow.Interface.JSController.dispatchUIRequest(studioTag,'getSelectedItems',[],true);

    selectedObj='';

    if length(selectedItems)==1
        selectedObj=selectedItems;
    elseif length(selectedItems)>1
        selectedObj=selectedItems(end);
    end

    if~isempty(selectedObj)
        selectedObjH=sf('IdToHandle',str2double(selectedObj.id));
        StateflowDI.SFDomain.notifyPropertyInspector(studio.App,selectedObjH);
    end
