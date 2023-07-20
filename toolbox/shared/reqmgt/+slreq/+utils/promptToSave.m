function response=promptToSave(artifactPath)



    if~ischar(artifactPath)

        artifactPath=get_param(artifactPath,'FileName');
    end
    [linkFilePath,~]=slreq.getLinkFilePath(artifactPath);
    displayName=strrep(linkFilePath,[matlabroot,filesep],'...');
    displayName=strrep(displayName,['...toolbox',filesep],'...');
    [~,artifactName,artifactExt]=fileparts(artifactPath);
    linkSet=slreq.utils.findLinkSet(artifactPath);
    if~isempty(linkSet)&&slreq.utils.isEmbeddedLinkSet(linkSet)
        dlgMessage={...
        getString(message('Slvnv:rmidata:RmiSlData:YouHaveModifiedExisting',[artifactName,artifactExt])),...
        getString(message('Slvnv:rmidata:RmiSlData:YouHaveModifiedEmbedded'))};
    elseif exist(linkFilePath,'file')==2
        dlgMessage=getString(message('Slvnv:rmidata:RmiSlData:YouHaveModifiedExisting',displayName));
    else
        dlgMessage={...
        getString(message('Slvnv:rmidata:RmiSlData:YouHaveModifiedFor',[artifactName,artifactExt])),...
        getString(message('Slvnv:rmidata:RmiSlData:YouHaveModifiedSave',displayName))};
    end
    reply=questdlg(dlgMessage,...
    getString(message('Slvnv:rmidata:RmiSlData:RequirementsLinksModified')),...
    getString(message('Slvnv:rmidata:RmiSlData:Save')),...
    getString(message('Slvnv:rmidata:RmiSlData:Discard')),...
    getString(message('Slvnv:rmidata:RmiSlData:Save')));
    response=(~isempty(reply)&&strcmp(reply,getString(message('Slvnv:rmidata:RmiSlData:Save'))));
end
