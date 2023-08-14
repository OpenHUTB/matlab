function[selectedViewElem,diagElem]=getCurrentSelection()



    bdH=sysarch.getBDRoot;

    selectedViewElem={};
    diagElem={};
    if~isempty(bdH)

        sysArchApp=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
        if~isempty(sysArchApp)

            studioMgr=sysArchApp.getArchViewsAppMgr.getStudioMgr;
            if~isempty(studioMgr)

                selectedElems=studioMgr.getSelection().getSelected();
                if~isempty(selectedElems)
                    diagElem=cell.empty(0,numel(selectedElems));
                    selectedViewElem=cell.empty(0,numel(selectedElems));
                    mfModel=sysArchApp.getArchViewsAppMgr.getModel;
                    for i=1:numel(selectedElems)
                        diagElem{i}=studioMgr.getEditorModel.findElement(selectedElems(i).uuid);
                        selectedViewElem{i}=mfModel.findElement(diagElem{i}.semanticElement);
                    end
                end
            end
        end
    end

end
