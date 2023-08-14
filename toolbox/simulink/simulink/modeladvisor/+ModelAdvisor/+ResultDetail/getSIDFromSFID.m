function sid=getSIDFromSFID(sfid)




    if~isnumeric(sfid)
        error(message('ModelAdvisor:engine:InvalidSFID'));
    end

    sid=Simulink.ID.getSID(idToHandle(sfroot,double(sfid)));
end
