function initializeUserData(vidObj)

    if isempty(vidObj.UserData)
        data.FramesPerTrigger=1;
        data.TriggerRepeat=0;
        data.IsSaved=false;
        vidObj.UserData=data;
    end
