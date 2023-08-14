

function y=isNormalModeModelRef(so)

    if strcmp(so.BlockType,'ModelReference')
        simMode=so.SimulationMode;
        if strcmp(simMode,'Normal')
            y=true;
            return;
        end
    end

    y=false;

end