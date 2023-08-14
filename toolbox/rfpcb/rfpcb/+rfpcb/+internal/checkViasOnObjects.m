function checkViasOnObjects(obj1,obj2)

    via1=obj1.ViaDiameter;
    via2=obj2.ViaDiameter;
    isVia1=~isempty(obj1.ViaLocations);
    isVia2=~isempty(obj2.ViaLocations);
    if isVia1&&isVia2
        if~isequal(via1,via2)
            error(message('rfpcb:rfpcberrors:DifferingViaDiameters'));
        end
    end