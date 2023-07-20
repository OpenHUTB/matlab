function busNames=getAllBuses(obj,archName)%#ok<INUSL>





    mws=get_param(archName,'ModelWorkspace');

    allVars=mws.whos;
    busVars=arrayfun(@(var)extractBusVars(var),allVars,'UniformOutput',false);

    busNames=busVars';

    function busVar=extractBusVars(var)
        if strcmp(var.class,'Simulink.Bus')
            busVar=var.name;
        end
    end

end

