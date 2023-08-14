function[innerArch,outerElem]=resolveZCObj(zcObj)






    innerArch=[];
    outerElem=[];

    if sysarch.isSysArchObject(zcObj)
        if isa(zcObj,'systemcomposer.architecture.model.design.Port')
            outerElem=zcObj;

            compPort=outerElem;
            if outerElem.isArchitecturePort
                compPort=outerElem.getParentComponentPort;
            end
            outerElem=compPort;








        else
            outerElem=zcObj;
            innerArch=zcObj;
        end

    end


end
