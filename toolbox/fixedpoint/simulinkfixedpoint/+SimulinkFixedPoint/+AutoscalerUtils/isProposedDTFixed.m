function[isFixed,proposedDTContainerInfo]=isProposedDTFixed(result)

    proposedDTContainerInfo=[];
    isFixed=false;


    if result.hasProposedDT

        proposedDTContainerInfo=SimulinkFixedPoint.DTContainerInfo(result.getProposedDT,[]);


        isFixed=proposedDTContainerInfo.containerType==SimulinkFixedPoint.AutoscalerDataTypes.FixedPoint;
    end

end