function v=validateBlock(this,hC)


    v=hdlvalidatestruct;

    slbh=hC.SimulinkHandle;
    blkObj=get_param(slbh,'Object');
    blkInfo=this.getBlockInfo(hC);

    if(~blkInfo.isDialog&&~blkInfo.isCustomHDLBlock...
        &&hC.PirInputSignals(2).Type.isArrayType)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedVectorOnShiftSignal'));
    end

    if this.isBuiltinShift(slbh)
        bsource=blkObj.BitShiftNumberSource;
        switch(bsource)
        case 'Input port'
            shiftType=hC.PirInputSignals(2).Type.getLeafType;
            if~blkInfo.isCustomHDLBlock&&any(str2double(blkObj.BinPtShiftNumber))
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedBitshiftBinPt'));
            end
            if(shiftType.isFloatType())
                if~isAllowedForFloatingPointMode()
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedBitshiftFloatingPointShift'));
                end
            end
        case 'Dialog'

            srcSignalType=hC.PirInputSignals(1).Type.getLeafType;
            if~all(arrayfun(@(x)int64(x)==x,blkInfo.shiftNumber))
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedBitshiftNonInteger'));
            end
            if(srcSignalType.isFloatType())
                if~isAllowedForFloatingPointMode()
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedBitShiftNonIntegerSignal'));
                end
            end
        otherwise
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedBitshift'));
        end
    end
end



function flag=isAllowedForFloatingPointMode()
    hDrv=hdlcurrentdriver();
    if targetcodegen.targetCodeGenerationUtils.isNFPMode()
        flag=false;
    else
        flag=isa(hDrv.getParameter('FloatingPointTargetConfiguration'),'hdlcoder.FloatingPointTargetConfig');
    end
end
