function r=enableLinkWithSafetyManager()
    r=struct('name',getString(message('Slvnv:slreq:LinkWithSelectedSafetyManagerObj')),...
    'tag','','callback','','accel','','enabled',false,'visible',true,'me',[]);

    if~rmism.isSafetyManagerLinkingEnabled()
        return;
    end

    r.enabled=rmism.isSafetyManagerSelectionValid();
end
