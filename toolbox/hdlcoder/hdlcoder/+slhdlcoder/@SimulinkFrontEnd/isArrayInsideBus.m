
function isBusElementIsArray=isArrayInsideBus(busSigHier,slbh)




    isBusElementIsArray=false;

    if isempty(busSigHier.BusObject)
        return;
    end
    busObj=slhdlcoder.SimulinkFrontEnd.getSlResolvedBusObject(busSigHier.BusObject,slbh);

    for ii=1:length(busSigHier.Children)
        child=busSigHier.Children(ii);
        elemt=busObj.Elements(ii);
        dims=elemt.Dimensions;
        if~slhdlcoder.SimulinkFrontEnd.isascalartype(dims)
            isBusElementIsArray=true;
            return;
        end
        if~isempty(child.Children)
            isBusElementIsArray=slhdlcoder.SimulinkFrontEnd.isArrayInsideBus(child,slbh);
            if isBusElementIsArray
                return;
            end
        end
    end

end
