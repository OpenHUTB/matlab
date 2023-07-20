function vals=getPropAllowedValues(~,prop)


    switch prop
    case{'ExecutionMode'}
        vals={'Auto','Off','On'};
    otherwise
        vals={};
    end


