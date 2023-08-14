function script=getSFScript(sid)

    sfObj=Simulink.ID.getHandle(sid);

    if isnumeric(sfObj)
        tempVar=sfprivate('block2chart',sfObj);
        sfObj=idToHandle(sfroot,tempVar);
    end

    script=sfObj.Script;
end

