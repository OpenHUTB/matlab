




function path=SID2Path(sid)

    h=Simulink.ID.getHandle(sid);

    if isnumeric(h)

        path=Simulink.ID.getFullName(sid);
    elseif strncmp(class(h),'Stateflow',9)
        path=h.getFullName();
    else
        path=Simulink.ID.getFullName(sid);
    end
end