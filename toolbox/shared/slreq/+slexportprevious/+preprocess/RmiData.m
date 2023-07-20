function RmiData(saveasObj)









    if Simulink.harness.isHarnessBD(char(saveasObj.modelName))

        return;
    end

    origModelH=get_param(saveasObj.origModelName,'Handle');

    if rmidata.bdHasExternalData(origModelH,true)

        if isR2012aOrEarlier(saveasObj.ver)

            warnAboutExternalLinksMF0(saveasObj.useGUI);
            return;
        end

        if isR2017aOrEarlier(saveasObj.ver)


            writeToDotReq(saveasObj);













        else

            linkSet=slreq.data.ReqData.getInstance.getLinkSet(saveasObj.origModelName);

            if~rmipref('StoreDataExternally')&&slreq.utils.isEmbeddedLinkSet(linkSet.filepath)&&~isMdlFile(saveasObj.modelName)










                newLinksetFile=getEmbeddedStorageLocation(saveasObj);

                asVersion=saveasObj.ver.release;
                newModelName=saveasObj.modelName;
                newModelPath=get_param(newModelName,'filename');
                linkSet.save(newLinksetFile,asVersion,newModelPath);
                slreq.utils.setPackageDirty(newModelName);























                slreq.data.ReqData.getInstance.loadLinkSet(newModelPath,newLinksetFile);

            else


                duplicateLinkSetFile(linkSet,saveasObj);

            end

        end

    end
end

function writeToDotReq(obj)


    origFile=get_param(obj.origModelName,'FileName');
    slreq.utils.writeToDotReq(origFile,obj.modelName);

    rmimap.RMIRepository.clear();
end

function duplicateLinkSetFile(linkSet,saveasObj)
    newModelPath=get_param(saveasObj.modelName,'FileName');
    [newLocation,newName]=fileparts(newModelPath);
    newLinkSetPath=fullfile(newLocation,[newName,'.slmx']);
    asVersion=saveasObj.ver.release;
    linkSet.save(newLinkSetPath,asVersion,newModelPath);
end

function embeddedLocation=getEmbeddedStorageLocation(saveasObj)
    tempLocation=get_param(saveasObj.modelName,'UnpackedLocation');
    [~,slxPartName]=slreq.utils.getEmbeddedLinksetName();
    embeddedLocation=fullfile(tempLocation,slxPartName);
end

function warnAboutExternalLinksMF0(isGUI)
    if isGUI
        uiwait(warndlg({...
        getString(message('Slvnv:slreq:NoExportToOldRelease')),...
        '',...
        getString(message('Slvnv:slreq:NoExportWorkaround'))},...
        getString(message('Slvnv:rmidata:duplicate:ExternalDataProblem'))));
    else
        MSLDiagnostic('Slvnv:slreq:NoExportToOldRelease').reportAsWarning;
    end
end

function tf=isMdlFile(mdlName)
    [~,~,fExt]=fileparts(get_param(mdlName,'FileName'));
    tf=strcmp(fExt,'.mdl');
end
