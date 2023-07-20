function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(~,blkObj,pathItem)




    curParentObj=blkObj.getParent;

    unknownParam=0;
    specifiedDTStr='';
    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);
    comments={};
    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';

    switch pathItem

    case 'Accumulator'
        modeStr='accumMode';
        wlStr='accumWordLength';
        flStr='accumFracLength';
    case 'Product output'
        modeStr='prodOutputMode';
        wlStr='prodOutputWordLength';
        flStr='prodOutputFracLength';
    case 'Output'
        modeStr='outputMode';
        wlStr='outputWordLength';
        flStr='outputFracLength';
    case 'FirstCoeff'
        modeStr='firstCoeffMode';
        wlStr='firstCoeffWordLength';
        flStr='firstCoeffFracLength';
    otherwise
        unknownParam=1;
    end

    if~unknownParam

        paramNames.modeStr=modeStr;
        paramNames.wlStr=wlStr;
        paramNames.flStr=flStr;

        modeValue=curParentObj.(modeStr);

        DTConInfo=SimulinkFixedPoint.DTContainerInfo(modeValue,blkObj);
        if~isInherited(DTConInfo)
            wlValueStr=curParentObj.(wlStr);
            flValueStr=curParentObj.(flStr);
            specifiedDTStr=sprintf('fixdt(1,%s,%s)',wlValueStr,flValueStr);
            DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);
        end

    end

end




