function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(~,blkObj,~)

    comments={};

    paramNames.modeStr='outDType';
    paramNames.wlStr='outWordLen';
    paramNames.flStr='outFracLen';

    blkDlgDTChoice=blkObj.outDtype;
    specifiedDTStr=blkDlgDTChoice;

    if any(strcmp(blkDlgDTChoice,{'Fixed-point','User-defined'}))

        outWL=blkObj.outWordLen;
        outFL=blkObj.outFracLen;

        if strcmp(blkObj.outFracLenMode,'Best precision')
            specifiedDTStr=['fixdt(1',',',outWL,')'];
        else
            specifiedDTStr=['fixdt(1',',',outWL,',',outFL,')'];
        end
    end
    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

end






