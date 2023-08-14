function tf=hasStereotypeInParentHirarchy(elem,psu)







    stereoToFind=psu.propertySet.prototype;
    tf=false;
    for stereo=elem.getPrototype
        if stereo.hasMissingParent(true)
            tf=false;
            break;
        end
        if stereo.isParentPrototype(stereoToFind)
            tf=true;
            break
        end
    end

end