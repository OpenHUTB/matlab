function val=isPausedInDebugLoop(cbinfo)




    val=slInternal('sldebug',cbinfo.model.name,'SldbgIsPausedInDebugLoop');
end

