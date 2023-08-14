function debugDisplay(element,preface,isDebug)
    if~exist('isDebug','var')||~isDebug
        return;
    end
    disp([preface,'   ',datestr(now,'HH:MM:SS.FFF')]);
    disp(element.getObjectID);
    disp(element.getDiagramElementUUID);
end
