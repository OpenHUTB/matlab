function topNet=elaborateColorSpaceConverter(this,topNet,blockInfo,insignals,outsignals)






    pixelIn=insignals(1);
    hStartIn=insignals(2);
    hEndIn=insignals(3);
    vStartIn=insignals(4);
    vEndIn=insignals(5);
    validIn=insignals(6);
    inRate=insignals(1).SimulinkRate;


    ctlType=pir_boolean_t();
    dataType=pixelIn.type.basetype;

    pixelInReg=topNet.addSignal(pixelIn.Type,'pixelInReg');
    hStartInReg=topNet.addSignal(ctlType,'hStartInReg');
    hEndInReg=topNet.addSignal(ctlType,'hEndInReg');
    vStartInReg=topNet.addSignal(ctlType,'vStartInReg');
    vEndInReg=topNet.addSignal(ctlType,'vEndInReg');
    validInReg=topNet.addSignal(ctlType,'validInReg');

    pirelab.getUnitDelayComp(topNet,pixelIn,pixelInReg);
    pirelab.getUnitDelayComp(topNet,hStartIn,hStartInReg);
    pirelab.getUnitDelayComp(topNet,hEndIn,hEndInReg);
    pirelab.getUnitDelayComp(topNet,vStartIn,vStartInReg);
    pirelab.getUnitDelayComp(topNet,vEndIn,vEndInReg);
    pirelab.getUnitDelayComp(topNet,validIn,validInReg);


    inDim=length(pixelIn.Type.Dimensions);
    signalType=pirelab.createPirArrayType(pixelIn.Type.BaseType,[1,3]);

    if inDim>1
        for ii=1:pixelIn.Type.Dimensions(1)
            signal(ii)=newDataSignal(topNet,sprintf('signal%d',ii),signalType,inRate);%#ok<AGROW> 
            pirelab.getSelectorComp(topNet,pixelInReg,signal(ii),'One-based',{'Index vector (dialog)','Select all'},{ii},{'Inherit from "Index"'},'2',sprintf('Selector%d',ii));
        end
    end

    if inDim==1
        [In1,In2,In3]=split(pixelInReg);
    end


    if strcmp(blockInfo.Conversion,'RGB to intensity')
        if inDim>1
            for ii=1:pixelIn.Type.Dimensions(1)
                Out(ii)=newDataSignal(topNet,sprintf('Out%d',ii),dataType,inRate);%#ok<AGROW> 
            end
        else
            intenOut=topNet.addSignal(In1.Type,'intenOut');
            intenOut.SimulinkRate=inRate;
            intenOut=outsignals(1);
        end
    else
        if inDim==1
            Out1=newDataSignal(topNet,sprintf('Out1'),In1.Type,inRate);
            Out2=newDataSignal(topNet,sprintf('Out2'),In2.Type,inRate);
            Out3=newDataSignal(topNet,sprintf('Out3'),In3.Type,inRate);
            pirelab.getMuxComp(topNet,[Out1,Out2,Out3],outsignals(1));
        end
    end
    hStartOut=outsignals(2);
    hEndOut=outsignals(3);
    vStartOut=outsignals(4);
    vEndOut=outsignals(5);
    validOut=outsignals(6);


    blockInfo.MinMaxLuma=fi(blockInfo.MinMaxLuma,false,dataType.WordLength,dataType.FractionLength);
    blockInfo.MinMaxChroma=fi(blockInfo.MinMaxChroma,false,dataType.WordLength,dataType.FractionLength);

    if dataType.WordLength>8
        blockInfo.b=fi(2^(dataType.WordLength-8),0,dataType.WordLength-7,0)*blockInfo.b;
        blockInfo.MinMaxLuma=fi(2^(dataType.WordLength-8),0,dataType.WordLength-7,0)*blockInfo.MinMaxLuma;
        blockInfo.MinMaxChroma=fi(2^(dataType.WordLength-8),0,dataType.WordLength-7,0)*blockInfo.MinMaxChroma;
    end

    switch blockInfo.Conversion
    case 'RGB to YCbCr'
        if inDim>1
            for ii=1:pixelIn.Type.Dimensions(1)
                [signal_1,signal_2,signal_3]=split(signal(ii));
                Out1(ii)=newDataSignal(topNet,sprintf('Out1%d',ii),signal_1.Type,inRate);
                Out2(ii)=newDataSignal(topNet,sprintf('Out2%d',ii),signal_2.Type,inRate);
                Out3(ii)=newDataSignal(topNet,sprintf('Out3%d',ii),signal_3.Type,inRate);
                Out(ii)=newDataSignal(topNet,sprintf('Out%d',ii),signalType,inRate);

                rgb2ycbcrNet=this.elabRGB2YCBCR(topNet,blockInfo,inRate);
                rgb2ycbcrNet.addComment('RGB to YCbCr Converter');
                pirelab.instantiateNetwork(topNet,rgb2ycbcrNet,[signal_1,signal_2,signal_3,hStartInReg,hEndInReg,vStartInReg,vEndInReg,validInReg],...
                [Out1(ii),Out2(ii),Out3(ii),hStartOut,hEndOut,vStartOut,vEndOut,validOut],sprintf('rgb2ycbcrNet_inst%d',ii));

                pirelab.getMuxComp(topNet,[Out1(ii),Out2(ii),Out3(ii)],Out(ii));
            end

        else
            rgb2ycbcrNet=this.elabRGB2YCBCR(topNet,blockInfo,inRate);
            rgb2ycbcrNet.addComment('RGB to YCbCr Converter');
            pirelab.instantiateNetwork(topNet,rgb2ycbcrNet,[In1,In2,In3,hStartInReg,hEndInReg,vStartInReg,vEndInReg,validInReg],...
            [Out1,Out2,Out3,hStartOut,hEndOut,vStartOut,vEndOut,validOut],'rgb2ycbcrNet_inst');
        end

    case 'YCbCr to RGB'
        if inDim>1
            for ii=1:pixelIn.Type.Dimensions(1)
                [signal_1,signal_2,signal_3]=split(signal(ii));
                Out1(ii)=newDataSignal(topNet,sprintf('Out1%d',ii),dataType,inRate);
                Out2(ii)=newDataSignal(topNet,sprintf('Out2%d',ii),dataType,inRate);
                Out3(ii)=newDataSignal(topNet,sprintf('Out3%d',ii),dataType,inRate);
                Out(ii)=newDataSignal(topNet,sprintf('Out%d',ii),signalType,inRate);

                ycbcr2rgbNet=this.elabYCBCR2RGB(topNet,blockInfo,inRate);
                ycbcr2rgbNet.addComment('YCbCr to RGB Converter');
                pirelab.instantiateNetwork(topNet,ycbcr2rgbNet,[signal_1,signal_2,signal_3,hStartInReg,hEndInReg,vStartInReg,vEndInReg,validInReg],...
                [Out1(ii),Out2(ii),Out3(ii),hStartOut,hEndOut,vStartOut,vEndOut,validOut],sprintf('ycbcr2rgbNet_inst%d',ii));

                pirelab.getMuxComp(topNet,[Out1(ii),Out2(ii),Out3(ii)],Out(ii));
            end
        else
            ycbcr2rgbNet=this.elabYCBCR2RGB(topNet,blockInfo,inRate);
            ycbcr2rgbNet.addComment('YCbCr to RGB Converter');
            pirelab.instantiateNetwork(topNet,ycbcr2rgbNet,[In1,In2,In3,hStartInReg,hEndInReg,vStartInReg,vEndInReg,validInReg],...
            [Out1,Out2,Out3,hStartOut,hEndOut,vStartOut,vEndOut,validOut],'ycbcr2rgbNet_inst');
        end

    otherwise
        if inDim>1
            for ii=1:pixelIn.Type.Dimensions(1)
                [signal_1,signal_2,signal_3]=split(signal(ii));
                rgb2intensityNet=this.elabRGB2INTENSITY(topNet,blockInfo,inRate);
                rgb2intensityNet.addComment('RGB to Intensity Converter');
                pirelab.instantiateNetwork(topNet,rgb2intensityNet,[signal_1,signal_2,signal_3,hStartInReg,hEndInReg,vStartInReg,vEndInReg,validInReg],...
                [Out(ii),hStartOut,hEndOut,vStartOut,vEndOut,validOut],sprintf('rgb2intensityNet_inst%d',ii));
            end
        else
            rgb2intensityNet=this.elabRGB2INTENSITY(topNet,blockInfo,inRate);
            rgb2intensityNet.addComment('RGB to Intensity Converter');
            pirelab.instantiateNetwork(topNet,rgb2intensityNet,[In1,In2,In3,hStartInReg,hEndInReg,vStartInReg,vEndInReg,validInReg],...
            [intenOut,hStartOut,hEndOut,vStartOut,vEndOut,validOut],'rgb2intensityNet_inst');
        end

    end

    if inDim>1
        pirelab.getConcatenateComp(topNet,[Out(1:pixelIn.Type.Dimensions(1))],outsignals(1),'Multidimensional array','1');
    end
end


function signal=newDataSignal(topNet,name,inType,rate)
    signal=topNet.addSignal(inType,name);
    signal.SimulinkRate=rate;
end

function[signal1,signal2,signal3]=split(signal)
    signalSplit=signal.split;
    signal1=signalSplit.PirOutputSignals(1);
    signal2=signalSplit.PirOutputSignals(2);
    signal3=signalSplit.PirOutputSignals(3);
end



