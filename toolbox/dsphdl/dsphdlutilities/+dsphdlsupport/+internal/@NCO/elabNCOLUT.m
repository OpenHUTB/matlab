function lutNet=elabNCOLUT(~,topNet,blockInfo,dataRate)





    if blockInfo.PhaseQuantization
        quantWL=blockInfo.PhaseBits;

    else
        quantWL=blockInfo.AccuWL;

    end

    lutaddrType=pir_ufixpt_t(quantWL-2,0);
    outType=pir_sfixpt_t(blockInfo.outWL,-blockInfo.outFL);
    outAddType=pir_sfixpt_t(blockInfo.outWL+1,-blockInfo.outFL);





    inportnames={'lutaddr'};
    inporttypes=lutaddrType;
    inportrates=dataRate;
    outportnames={'lutoutput'};
    outporttypes=outType;


    lutNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','LookUpTableGen',...
    'InportNames',inportnames,...
    'InportTypes',inporttypes,...
    'InportRates',inportrates,...
    'OutportNames',outportnames,...
    'OutportTypes',outporttypes...
    );

    tlutaddr=lutNet.PirInputSignals(1);
    lutoutreg=lutNet.PirOutputSignals(1);




    lutaddr=addSignal(lutNet,lutaddrType,'lutaddrInReg');
    lutaddr.SimulinkRate=blockInfo.SimulinkRate;
    comp=pirelab.getUnitDelayComp(lutNet,tlutaddr,lutaddr,'LUTaddrRegister',0,1);
    comp.addComment('Look up table address input register');

    if(~blockInfo.LUTCompress)

        lutout=addSignal(lutNet,outType,'lutout');
        lutout.SimulinkRate=blockInfo.SimulinkRate;

        lutoutreg1=addSignal(lutNet,outType,'lutout_reg');
        lutoutreg1.SimulinkRate=blockInfo.SimulinkRate;

        [tabledata,tableidx,bpType,oType,fType]=ComputeLUT(blockInfo,quantWL);
        comp=pirelab.getLookupNDComp(lutNet,lutaddr,lutout,...
        tabledata,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
        comp.addComment(' Quarter sine wave table');


        regcomp=pirelab.getUnitDelayComp(lutNet,lutout,lutoutreg1,'LUToutResetRegister',0,1);
        regcomp.addComment('Lookup table output register');


        pirelab.getIntDelayComp(lutNet,lutoutreg1,lutoutreg,1,'LUToutRegister',0);



    else

        lutWL=quantWL-2;
        bs=ceil(lutWL/3);
        Cbs=lutWL-2*bs;

        addr1Type=pir_ufixpt_t(2*bs,0);
        addr2Type=pir_ufixpt_t(bs+Cbs,0);

        lut1addr=addSignal(lutNet,addr1Type,'lut1addr');
        lut1addr.SimulinkRate=blockInfo.SimulinkRate;
        lut2addr=addSignal(lutNet,addr2Type,'lut2addr');
        lut2addr.SimulinkRate=blockInfo.SimulinkRate;

        lut2addrp1=addSignal(lutNet,pir_ufixpt_t(bs,0),'lut2addrp1');
        lut2addrp1.SimulinkRate=blockInfo.SimulinkRate;
        lut2addrp2=addSignal(lutNet,pir_ufixpt_t(Cbs,0),'lut2addrp2');
        lut2addrp2.SimulinkRate=blockInfo.SimulinkRate;

        comp=pirelab.getBitSliceComp(lutNet,lutaddr,lut1addr,lutWL-1,Cbs);
        comp.addComment('Lookup table 1 address');

        pirelab.getBitSliceComp(lutNet,lutaddr,lut2addrp1,lutWL-1,bs+Cbs);
        pirelab.getBitSliceComp(lutNet,lutaddr,lut2addrp2,Cbs-1,0);

        comp=pirelab.getBitConcatComp(lutNet,[lut2addrp1,lut2addrp2],lut2addr);
        comp.addComment('Lookup table 2 address');

        [table1,idx1,bpType1,oType1,fType,table2,idx2,bpType2,oType2,shiftbits]=ComputeLUT(blockInfo,quantWL);

        lut1out=addSignal(lutNet,outType,'lut1out');
        lut1out.SimulinkRate=blockInfo.SimulinkRate;
        lut1outreg=addSignal(lutNet,outType,'lut1outreg');
        lut1outreg.SimulinkRate=blockInfo.SimulinkRate;
        lut2out_extend=addSignal(lutNet,outType,'lut2out_extend');
        lut2out_extend.SimulinkRate=blockInfo.SimulinkRate;
        lut2out_sf=addSignal(lutNet,outType,'lut2out_sf');
        lut2out_sf.SimulinkRate=blockInfo.SimulinkRate;
        lut2outType=pir_ufixpt_t(table2.WordLength,-table2.FractionLength);
        lut2out=addSignal(lutNet,lut2outType,'lut2out');
        lut2out.SimulinkRate=blockInfo.SimulinkRate;
        lut2outreg=addSignal(lutNet,lut2outType,'lut2outreg');
        lut2outreg.SimulinkRate=blockInfo.SimulinkRate;


        comp=pirelab.getLookupNDComp(lutNet,lut1addr,lut1out,...
        table1,0,bpType1,oType1,fType,0,idx1,'Lookup Table1',-1);
        comp.addComment(' Quarter sine wave table-Part1');

        lut1outreg1=addSignal(lutNet,outType,'lut1out_reg');
        lut1outreg1.SimulinkRate=blockInfo.SimulinkRate;


        regcomp=pirelab.getUnitDelayComp(lutNet,lut1out,lut1outreg1,'LUT1outRegister',0,1);
        regcomp.addComment('Lookup table1 output register');


        pirelab.getWireComp(lutNet,lut1outreg1,lut1outreg);


        comp=pirelab.getLookupNDComp(lutNet,lut2addr,lut2out,...
        table2,0,bpType2,oType2,fType,0,idx2,'Lookup Table2',-1);
        comp.addComment(' Quarter Sine Wave Table-Part2');

        lut2outreg1=addSignal(lutNet,lut2outType,'lut2out_reg');
        lut2outreg1.SimulinkRate=blockInfo.SimulinkRate;


        regcomp=pirelab.getUnitDelayComp(lutNet,lut2out,lut2outreg1,'LUT2outRegister',0,1);
        regcomp.addComment('Lookup table2 output register');


        pirelab.getWireComp(lutNet,lut2outreg1,lut2outreg);


        pirelab.getDTCComp(lutNet,lut2outreg,lut2out_extend,'Nearest','Saturate');

        comp=pirelab.getBitShiftComp(lutNet,lut2out_extend,lut2out_sf,'srl',shiftbits);
        comp.addComment(' Shift look up table 2 outputs');

...
...
...
...
...
...
...
...
...
...


        addlutouts=addSignal(lutNet,outAddType,'addlutouts');
        addlutouts.SimulinkRate=blockInfo.SimulinkRate;

        comp=pirelab.getAddComp(lutNet,[lut1outreg,lut2out_sf],addlutouts);
        comp.addComment('Compute look up table output');

        addlutoutreg=addSignal(lutNet,outAddType,'addlutoutreg');
        addlutoutreg.SimulinkRate=blockInfo.SimulinkRate;



        regcomp=pirelab.getUnitDelayComp(lutNet,addlutouts,addlutoutreg,'LUTAddoutRegister',0,true);


        regcomp.addComment('Look up table output register');


        pirelab.getDTCComp(lutNet,addlutoutreg,lutoutreg,'Nearest','Saturate');
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
