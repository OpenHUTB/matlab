function semanticItem=navigate(iZCIdentifier,mdlName)






    bdH=sysarch.getBDHandle(mdlName);
    semanticItem=sysarch.resolveZCElement(iZCIdentifier,mdlName);
    if~isempty(bdH)&&~isempty(semanticItem)
        sysarchApp=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
        appMgr=sysarchApp.getArchViewsAppMgr;
        zcModel=appMgr.getZCModel;

        if isa(semanticItem,'systemcomposer.architecture.model.design.Port')
            prtHdls=sysarch.getPortHandleForMarkup(iZCIdentifier,mdlName);


            if~isempty(prtHdls)

                blk=get_param(prtHdls(1),'Parent');

                sys=get_param(blk,'Parent');
            else


                prtHdls=systemcomposer.utils.getSimulinkPeer(semanticItem);
                sys=get_param(prtHdls(1),'Parent');
                if strcmpi(get_param(sys,'Type'),'block')&&strcmpi(get_param(sys,'BlockType'),'ModelReference')
                    sys=get_param(sys,'Parent');
                end
            end
            open_system(sys,'force');


            rmiut.hiliteAndFade(prtHdls);

        else


            studioMgr=appMgr.getStudioMgr;
            if~isempty(studioMgr)
                if isa(semanticItem,'systemcomposer.architecture.model.views.View')
                    studioMgr.changeRoot(semanticItem,systemcomposer.architecture.model.design.BaseComponent.empty);
                    studioMgr.show;
                else
                    if isa(semanticItem,'systemcomposer.architecture.model.views.ElementGroup')
                        view=semanticItem.getView;
                    else
                        view=appMgr.getStudioMgr.getCurrentVisibleView;
                    end

                    if isempty(view)
                        return;
                    end


                    studioMgr.changeRoot(view,systemcomposer.architecture.model.design.BaseComponent.empty);
                    studioMgr.show;

                    diagElem=sysarch.getDiagramItemInView(mdlName,semanticItem,view);
                    if~isempty(diagElem)

                        studioMgr.getSelection().select({diagElem.UUID});
                    end
                end
            end
        end
    end

