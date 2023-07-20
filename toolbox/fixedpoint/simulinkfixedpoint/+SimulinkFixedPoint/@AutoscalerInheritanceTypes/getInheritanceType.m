function inheritanceType=getInheritanceType(dTContainerInfo)





    if~dTContainerInfo.isInherited

        inheritanceType=SimulinkFixedPoint.AutoscalerInheritanceTypes.NOTINHERITED;
    else

        stringToEncode=dTContainerInfo.origDTString;
        encodedString=SimulinkFixedPoint.AutoscalerInheritanceTypes.encoder(stringToEncode);


        acceptableTypes=SimulinkFixedPoint.AutoscalerInheritanceTypes.getAcceptableTypes();


        indexAcceptableType=false(size(acceptableTypes));
        for ii=1:numel(acceptableTypes)
            indexAcceptableType(ii)=strcmp(encodedString,acceptableTypes(ii));
        end

        if any(indexAcceptableType)

            inheritanceType=SimulinkFixedPoint.AutoscalerInheritanceTypes.(char(acceptableTypes(indexAcceptableType)));
        else

            inheritanceType=SimulinkFixedPoint.AutoscalerInheritanceTypes.UNKNOWNINHERITANCE;
        end
    end
end

