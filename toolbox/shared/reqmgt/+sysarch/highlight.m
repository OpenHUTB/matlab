function highlight(iZCIdentifier,mdlName)


    if sysarch.isZCElement(iZCIdentifier)
        bdH=sysarch.getBDHandle(mdlName);
        if~isempty(bdH)
            sysarchApp=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
            appMgr=sysarchApp.getArchViewsAppMgr;
            zcModel=appMgr.getZCModel;
            activeView=zcModel.getActiveView;
            elem=sysarch.resolveZCElement(iZCIdentifier,mdlName);
            if~isempty(elem)&&elem.isInView(activeView)

                diagElem=sysarch.getDiagramItemInView(mdlName,elem,activeView);
                if~isempty(diagElem)
                    stdMgr=appMgr.getStudioMgr;
                    stdMgr.highlightElement(diagElem.UUID);
                end
            else

                views=elem.getViews;

                activeView=views(1);
                diagElem=sysarch.getDiagramItemInView(mdlName,elem,activeView);
                if~isempty(diagElem)
                    stdMgr=appMgr.getStudioMgr;
                    stdMgr.highlightElement(diagElem.UUID);
                end
            end
        end

    end
end
