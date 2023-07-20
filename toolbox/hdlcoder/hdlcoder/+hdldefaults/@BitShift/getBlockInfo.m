function blkInfo=getBlockInfo(this,hC)%#ok<INUSL>


    slbh=hC.SimulinkHandle;
    blkObj=get_param(slbh,'Object');

    blkInfo=struct('shiftDirection','','isInputPort',false,'isDialog',false,...
    'isBinPtShift',false,'shiftNumber',0,'shiftBinaryPt',0,'isCustomHDLBlock',false);

    if isprop(hC,'BlockTag')&&~isempty(regexp(hC.BlockTag,'Bit Shift$','once'))
        bObj=get_param(hC.SimulinkHandle,'Object');
        blkInfo.shiftDirection=bObj.mode;


        blkInfo.shiftNumber=double(str2num(bObj.N));%#ok<ST2NM> since str2double fails on array value input as a string
        blkInfo.isBinPtShift=true;
        blkInfo.isCustomHDLBlock=true;
        switch(blkInfo.shiftDirection)
        case{'Shift Left Logical'}
            blkInfo.shiftDirection='left';
        case{'Shift Right Logical'}
            blkInfo.shiftDirection='right';
        case{'Shift Right Arithmetic'}
            blkInfo.shiftDirection='right_arithmetic';
        end

        if strcmp(blkInfo.shiftDirection,'left')
            blkInfo.shiftNumber=-blkInfo.shiftNumber;
        end
    else
        blkInfo.shiftDirection=blkObj.BitShiftDirection;
        blkInfo.isInputPort=strcmpi(blkObj.BitShiftNumberSource,'Input port');
        blkInfo.isDialog=strcmpi(blkObj.BitShiftNumberSource,'Dialog');
        blkInfo.isBinPtShift=~isempty(slResolve(blkObj.BinPtShiftNumber,slbh,'expression'));
    end

    if(blkInfo.isDialog)
        blkInfo.shiftNumber=slResolve(blkObj.BitShiftNumber,slbh,'expression');


        blkInfo.shiftNumber=double(blkInfo.shiftNumber);

        if isempty(blkInfo.shiftNumber)
            blkInfo.shiftNumber=0;
        end

        if~strcmp(blkInfo.shiftDirection,'Bidirectional')&&any(blkInfo.shiftNumber<0)
            blkInfo.shiftNumber(blkInfo.shiftNumber<0)=0;
        end

        if strcmp(blkInfo.shiftDirection,'Left')
            blkInfo.shiftNumber=-blkInfo.shiftNumber;
        end
    end

    if blkInfo.isBinPtShift&&isprop(blkObj,'BinPtShiftNumber')
        blkInfo.shiftBinaryPt=slResolve(blkObj.BinPtShiftNumber,slbh,'expression');
    end
end
