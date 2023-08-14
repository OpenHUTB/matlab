function fbBus=createFBBus(varList)




    fbBus=Simulink.Bus;

    if~isempty(varList)
        elems=[];
        for varCount=1:numel(varList)
            var=varList(varCount);
            if ismember(var.Scope,{'InOut','External'})


                continue
            end
            elem=createBusElement(var);
            if varCount==1
                elems=elem;
            else
                elems(end+1)=elem;%#ok<AGROW>
            end
        end
        fbBus.Elements=elems;
    end
end

function elem=createBusElement(var)
    elem=Simulink.BusElement;
    elem.Name=var.Name;
    elem.Dimensions=var.Size;
    elem.DimensionsMode='Fixed';
    elem.DataType=var.DataType;
    elem.SampleTime=-1;
    elem.Complexity='real';
end


