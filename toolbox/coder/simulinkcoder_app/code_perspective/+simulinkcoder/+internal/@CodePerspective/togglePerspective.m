function togglePerspective(obj,studio)




    status=~obj.getStatus(studio);

    if status
        obj.turnOnPerspective(studio);
    else
        obj.turnOffPerspective(studio);
    end
