


function turnOff(obj)

    for i=1:numel(obj.fComponents)
        comp=obj.fComponents{i};
        comp.turnOff();
    end
