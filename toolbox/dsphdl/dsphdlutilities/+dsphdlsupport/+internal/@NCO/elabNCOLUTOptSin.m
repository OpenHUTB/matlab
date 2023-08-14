function lutNetSin=elabNCOLUTOptSin(~,topNet,blockInfo,dataRate)




    Fsat=fimath('RoundMode','Convergent',...
    'OverflowMode','Saturate');

    outMode=blockInfo.outMode;
    outcase=outMode(1)+2*outMode(2)+4*outMode(3);
    if blockInfo.PhaseQuantization
        quantWL=blockInfo.PhaseBits;

    else
        quantWL=blockInfo.AccuWL;
    end

    if outcase>=3&&~(blockInfo.LUTCompress)
        addrWL=quantWL-3;
        lutaddrType=pir_ufixpt_t(addrWL,0);
        outType=pir_sfixpt_t(blockInfo.outWL,-blockInfo.outFL);

        inportnames={'lutaddr'};
        inporttypes=lutaddrType;
        inportrates=dataRate;
        outportnames={'lutSine'};
        outporttypes=outType;


        lutNetSin=pirelab.createNewNetwork(...
        'Network',topNet,...
        'Name','SinLookUpTableGen',...
        'InportNames',inportnames,...
        'InportTypes',inporttypes,...
        'InportRates',inportrates,...
        'OutportNames',outportnames,...
        'OutportTypes',outporttypes...
        );

        tlutaddr=lutNetSin.PirInputSignals(1);
        lutSineoutreg=lutNetSin.PirOutputSignals(1);


        lutaddr=addSignal(lutNetSin,lutaddrType,'lutaddrInReg');
        lutaddr.SimulinkRate=blockInfo.SimulinkRate;
        comp=pirelab.getUnitDelayComp(lutNetSin,tlutaddr,lutaddr,'LUTaddrRegister',0,1);
        comp.addComment('Look up table address input register');

        if(~blockInfo.LUTCompress)

            lutSineout=addSignal(lutNetSin,outType,'lutSineout');
            lutSineout.SimulinkRate=blockInfo.SimulinkRate;

            lutSineoutreg1=addSignal(lutNetSin,outType,'lutSineoutreg1');
            lutSineoutreg1.SimulinkRate=blockInfo.SimulinkRate;


            [tabledata,~,~,~,~]=ComputeLUT(blockInfo,quantWL);


            comp=pirelab.getDirectLookupComp(lutNetSin,lutaddr,lutSineout,tabledata(1:2^addrWL));
            comp.addComment('Octant Sine wave table');


            regcomp=pirelab.getUnitDelayComp(lutNetSin,lutSineout,lutSineoutreg1,'LUTSineoutResetRegister',0,1);
            regcomp.addComment('Sin lookup table output register');

            pirelab.getIntDelayComp(lutNetSin,lutSineoutreg1,lutSineoutreg,1,'LUTSineoutRegister',0);


























































































































































        end
    end
end


function[table1,idx1,bpType1,oType,fType,table2,idx2,bpType2,oType2,shiftbits]=ComputeLUT(blockInfo,quantWL)





    outWL=blockInfo.outWL;
    outFL=blockInfo.outFL;


    Fsat=fimath('RoundMode','Nearest',...
    'OverflowMode','Saturate',...
    'SumMode','KeepLSB',...
    'SumWordLength',outWL,...
    'SumFractionLength',outFL,...
    'CastBeforeSum',true);


    oType=fi(0,1,outWL,outFL);
    fType=fi(0,0,32,31);


    if(~blockInfo.LUTCompress)
        dataIn=0:2^(quantWL-2)-1;
        quarterSine=sin(pi/2*dataIn/2^(quantWL-2));

        bpType1=fi(0,0,quantWL-2,0);
        idx1={fi(dataIn,bpType1.numerictype)};
        table1=fi(quarterSine,oType.numerictype,Fsat);


    else

        WL_lut=quantWL-2;
        bs=ceil(WL_lut/3);
        A=2*pi*2^-(bs+2);
        B=2*pi*2^-bs*2^-(bs+2);
        Cbs=WL_lut-2*bs;
        C=2*pi*2^-(2*bs)*2^-(Cbs+2);


        tb1WL=2*bs;
        index1=fi((0:2^tb1WL-1)',0,tb1WL,0);
        Ak1=bitshift(index1,-bs);
        Bk=index1;
        Bk.bin(:,1:bs)='0';
        quarterSine_p1=sin(A*double(Ak1)+B*double(Bk));


        tb2WL=bs+Cbs;
        index2=fi((0:2^tb2WL-1)',0,tb2WL,0);
        Ak2=bitshift(index2,-Cbs);
        Ck=index2;
        Ck.bin(:,1:bs)='0';
        quarterSine_p2=cos(A*double(Ak2)).*sin(C*double(Ck));

        table1=fi(quarterSine_p1,oType.numerictype,Fsat);
        dataIn1=0:2^(2*bs)-1;
        bpType1=fi(0,0,2*bs,0);
        idx1={fi(dataIn1,bpType1.numerictype)};

        shiftbits=floor(log2(0.75/max(quarterSine_p2)));
        outWL_LUT2=ceil(outWL/4);
        oType2=fi(0,0,outWL_LUT2,outWL_LUT2);

        temp_p2=fi(quarterSine_p2*2^shiftbits,oType2.numerictype,Fsat);
        table2=temp_p2;
        dataIn2=0:2^(bs+Cbs)-1;
        bpType2=fi(0,0,(bs+Cbs),0);
        idx2={fi(dataIn2,bpType2.numerictype)};



    end
end
