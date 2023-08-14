


function turnOn(obj)

    for i=1:numel(obj.fComponents)
        comp=obj.fComponents{i};
        result=comp.turnOn();
        if~result
            comp.turnOff();
        end
    end
