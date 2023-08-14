
function updateArtifacts(obj)
    as=alm.internal.ArtifactService.get(obj.ProjectPath);
    l=addlistener(as,'UserNotificationEvent',...
    obj.getUserMessageHandler());%#ok<NASGU>
    as.updateArtifacts();
end