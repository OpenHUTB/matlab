function hNewC=elaborate(this,hN,hC)




    slbh=hC.SimulinkHandle;


    bitoplibblk_mode='';
    expConst=0;
    if this.isBuiltinShift(slbh)

        bsource=get_param(slbh,'BitShiftNumberSource');
        if strcmpi(bsource,'Input port')
            arch_choice=false;
            if(arch_choice)
                hNewC=this.elaborateBarrelShifter(hN,hC);
            else
                hNewC=this.elaborateDynamicShifter(hN,hC);
            end
            return;
        end

        blkInfo=getBlockInfo(this,hC);
        shiftLength=blkInfo.shiftNumber;
        shiftBinPtLength=blkInfo.shiftBinaryPt;

        shiftMode='sra';
        expConst=shiftBinPtLength-shiftLength;

        if shiftLength<0
            shiftLength=-shiftLength;
            shiftMode='sll';
        end
    else


        bitoplibblk_mode=get_param(slbh,'mode');
        switch lower(bitoplibblk_mode)
        case 'shift left logical'
            shiftMode='sll';
        case 'shift right logical'
            shiftMode='srl';
        case 'shift right arithmetic'
            shiftMode='sra';
        end

        shiftLength=hdlslResolve('N',slbh);
        shiftBinPtLength=0;
    end

    hInSignals=hC.SLInputSignals;
    [~,outType]=pirelab.getVectorTypeInfo(hInSignals);
    outType=outType.getLeafType;

    if outType.isWordType
        if all(shiftLength==0)&&all(shiftBinPtLength==0)

            hNewC=pirelab.getWireComp(hN,hInSignals,hC.SLOutputSignals,hC.Name);
        else
            wordlen=outType.WordLength;


            if wordlen==1&&shiftLength==0
                hNewC=pirelab.getDTCComp(hN,hInSignals,hC.SLOutputSignals,'Floor','Wrap','SI',hC.Name,'');
                return;
            end

            if shiftLength>=wordlen
                if strcmp(shiftMode,'sll')||~outType.Signed



                    hNewC=pirelab.getConstComp(hN,hC.SLOutputSignals,0,hC.Name);
                    hNewC.setShouldDraw(true);
                    hN.removeComponent(hC);
                    return;
                else
                    shiftLength=wordlen-1;
                end
            end


            if isempty(bitoplibblk_mode)
                hNewC=pirelab.getBitShiftComp(hN,hInSignals,hC.SLOutputSignals,shiftMode,shiftLength,shiftBinPtLength,hC.Name);
            else
                hNewC=pirelab.getLibBitShiftComp(hN,hInSignals,hC.SLOutputSignals,bitoplibblk_mode,shiftLength,hC.Name);
            end
        end
    else
        if shiftLength==0
            hNewC=pirelab.getWireComp(hN,hInSignals,hC.SLOutputSignals,hC.Name);
        else
            constVal=2.^(expConst);
            hNewC=pirelab.getGainComp(hN,hInSignals,hC.SLOutputSignals,constVal);
        end
    end

end
