function outStruct=getRequirementInfoForWeb(bdH,uuid,isViews)





    outStruct=struct.empty;





    app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(get_param(bdH,'handle'));
    if(isViews)
        syntax=app.getArchViewsAppMgr.getSyntax;
    else
        syntax=app.getSyntax;
    end


    synModel=syntax.getModel();
    synElem=synModel.findElement(uuid);



    if~isempty(synElem)
        if(isViews)
            mdl=app.getArchViewsAppMgr.getModel;
            semElem=mdl.findElement(synElem.semanticElement);

            semElem=sysarch.getLinkableObjectFromViewObject(semElem);
            if~isempty(semElem)
                if sysarch.isLinkableCompositionElement(semElem)
                    slHandle=systemcomposer.utils.getSimulinkPeer(semElem);
                    dlgInfo=slreq.gui.LinkDetails.getDialogSchema(slHandle,'standalone');
                    reqInfo=processInfo(slreq.gui.LinkDetails.getLinkInfo(slHandle));
                    outStruct=struct('content',dlgInfo.Items{1}.HTML,'reqInfo',reqInfo);
                    return;
                elseif sysarch.isLinkableViewElement(semElem)
                    dlgInfo=slreq.gui.LinkDetails.getDialogSchema(semElem,'standalone');
                    reqInfo=processInfo(slreq.gui.LinkDetails.getLinkInfo(semElem));
                    outStruct=struct('content',dlgInfo.Items{1}.HTML,'reqInfo',reqInfo);
                    return;
                end
            end
        else

            cM=app.getCompositionArchitectureModel();
            semElem=cM.findElement(synElem.semanticElement);
        end
    else

        intfModel=app.getInterfaceEditorViewModel();
        viewElem=intfModel.findElement(uuid);

        if isempty(viewElem)
            return;
        end

        semElem=this.findSemanticElement(viewElem.SemanticElementId);

    end
    dlgInfo=slreq.gui.LinkDetails.getDialogSchema(semElem,'standalone');
    reqInfo=processInfo(slreq.gui.LinkDetails.getLinkInfo(semElem));
    outStruct=struct('content',dlgInfo.Items{1}.HTML,'reqInfo',reqInfo);

end

function out=processInfo(linkInfo)

    out=[];
    for i=1:numel(linkInfo)
        info=linkInfo(i);
        startParen=strfind(info.functionName,'(');
        endParen=strfind(info.functionName,')');
        fcnName=info.functionName(1:startParen-1);
        argsList=strsplit(info.functionName(startParen+1:endParen-1),',');


        for m=1:numel(argsList)
            argsList{m}=eval(argsList{m});
        end
        out(i).functionName=fcnName;
        out(i).argList=argsList;
        out(i).resource=info.resource;
        out(i).linkedID=info.linkedID;
        out(i).linkUUID=info.linkUUID;
    end
end

function isLinkableViewElement(elem)
end
