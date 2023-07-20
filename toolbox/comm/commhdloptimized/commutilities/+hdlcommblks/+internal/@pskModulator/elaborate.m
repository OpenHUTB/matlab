function hNewC=elaborate(this,hN,hC)






    hTopNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC...
    );


    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        prm=this.buildSysObjParams(hC,sysObjHandle);
    else
        prm=this.buildBlockParams(hC);
    end

    prm.hN=hTopNet;
    prm.hC=[];
    prm.InputSignals=hTopNet.PirInputSignals;
    prm.OutputSignals=hTopNet.PirOutputSignals;




    if prm.M==2


        if(prm.InputSignals.Type.WordLength~=1)
            selType=prm.hN.getType('Boolean');
            selh=prm.hN.addSignal2('Type',selType,'Name','bpsk_sel');
            pirelab.getBitSliceComp(prm.hN,prm.InputSignals,selh,0,0,'input_slicer');
        else
            selh=prm.InputSignals;
        end


        reLut=real(prm.LUTvalues);
        imLut=imag(prm.LUTvalues);

        outsigT=prm.OutputSignals(1).Type;
        outsigBT=outsigT.BaseType;

        outre=prm.hN.addSignal2('Name','inphase','Type',outsigBT);
        outim=prm.hN.addSignal2('Name','quadrature','Type',outsigBT);
        rate=hC.PirOutputSignals(1).SimulinkRate;
        outre.SimulinkRate=rate;
        outim.SimulinkRate=rate;

        pirelab.getRealImag2Complex(prm.hN,[outre,outim],prm.OutputSignals,'real and imag');

        if reLut(1)==reLut(2)

            pirelab.getConstComp(prm.hN,outre,reLut(1));
        else

            bpsk_re0=prm.hN.addSignal2('Name','inphase_val0','Type',outsigBT);
            bpsk_re1=prm.hN.addSignal2('Name','inphase_val1','Type',outsigBT);
            bpsk_re0.SimulinkRate=rate;
            bpsk_re1.SimulinkRate=rate;

            pirelab.getConstComp(prm.hN,bpsk_re0,reLut(1));
            pirelab.getConstComp(prm.hN,bpsk_re1,reLut(2));

            pirelab.getSwitchComp(prm.hN,[bpsk_re0,bpsk_re1],outre,selh,'bpsk_muxre','==',0);

        end

        if imLut(1)==imLut(2)

            pirelab.getConstComp(prm.hN,outim,imLut(1));
        else


            reh=[bpsk_re0,bpsk_re1];
            idx=(imLut(1)==reLut);
            if~any(idx)||~exist('bpsk_re0','var')
                bpsk_im0=prm.hN.addSignal2('Name','quadrature_val0','Type',outsigBT);
                bpsk_im0.SimulinkRate=rate;
                pirelab.getConstComp(prm.hN,bpsk_im0,imLut(1));
            else
                bpsk_im0=reh(idx);
                bpsk_im0=bpsk_im0(1);

                bpsk_im0.Name=strrep(bpsk_im0.Name,'inphase','bpsk');
            end
            idx=(imLut(2)==reLut);
            if~any(idx)||~exist('bpsk_re1','var')
                bpsk_im1=prm.hN.addSignal2('Name','quadrature_val1','Type',outsigBT);
                bpsk_im1.SimulinkRate=rate;
                pirelab.getConstComp(prm.hN,bpsk_im1,imLut(2));
            else
                bpsk_im1=reh(idx);
                bpsk_im1=bpsk_im1(1);

                bpsk_im1.Name=strrep(bpsk_im1.Name,'inphase','bpsk');
            end



            pirelab.getSwitchComp(prm.hN,[bpsk_im0,bpsk_im1],outim,selh,'bpsk_muxim','==',0);

        end


    else

        addrWL=log2(prm.M);
        addrType=prm.hN.getType('FixedPoint','Signed',0,'WordLength',addrWL,'FractionLength',0);
        lutAddr=prm.hN.addSignal2('Type',addrType,'Name','constellationLUTaddress');

        if prm.IntegerInput
            pirelab.getBitSliceComp(prm.hN,prm.InputSignals,lutAddr,addrWL-1,0,'input_slicer');



        else
            pirelab.getBitConcatComp(prm.hN,prm.InputSignals,lutAddr,'input_concat');

        end


        pirelab.getDirectLookupComp(prm.hN,lutAddr,prm.OutputSignals,...
        prm.LUTvalues,'constellationLUT');

    end


    hNewC=pirelab.instantiateNetwork(hN,hTopNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

end
