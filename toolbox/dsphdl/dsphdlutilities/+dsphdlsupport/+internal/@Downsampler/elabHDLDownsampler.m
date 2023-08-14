function elabHDLDownsampler(this,hTopN,blockInfo,slRate)





    for loop=1:numel(hTopN.PirOutputSignals)
        hTopN.PirOutputSignals(loop).SimulinkRate=slRate;
    end
    for loop=1:numel(hTopN.PirInputSignals)
        hTopN.PirInputSignals(loop).SimulinkRate=slRate;
    end

    hTopNinSigs=hTopN.PirInputSignals;
    hTopNoutSigs=hTopN.PirOutputSignals;


    dataIn=hTopNinSigs(1);
    validIn=hTopNinSigs(2);
    validIn.SimulinkRate=slRate;


    dataOut=hTopNoutSigs(1);
    validOut=hTopNoutSigs(2);



    if~blockInfo.inResetSS&&blockInfo.inMode(2)
        softReset=hTopNinSigs(3);
        softReset.SimulinkRate=slRate;
    else
        softReset=hTopN.addSignal2('Type',pir_boolean_t,'Name','softReset');
        softReset.SimulinkRate=slRate;
        if blockInfo.inResetSS

            softReset.setSynthResetInsideResetSS;

            blockInfo.inMode(2)=true;
        else


            pirelab.getConstComp(hTopN,softReset,false);
        end
    end


    dataInreg=hTopN.addSignal(dataIn.Type,'dataInreg');
    dataInreg.SimulinkRate=slRate;
    validInreg=hTopN.addSignal(hTopNoutSigs(2).Type,'validInreg');
    pirelab.getIntDelayEnabledResettableComp(hTopN,dataIn,dataInreg,1,softReset,1);
    pirelab.getIntDelayEnabledResettableComp(hTopN,validIn,validInreg,1,softReset,1);

    internalReset=hTopN.addSignal2('Type',pir_boolean_t,'Name','internalReset');
    pirelab.getWireComp(hTopN,softReset,internalReset);

    inS=blockInfo.issigned;
    inWL=blockInfo.dlen;
    inFL=blockInfo.flen;
    PVType=pir_fixpt_t(inS,inWL,inFL);

    if blockInfo.vecsize<=blockInfo.DownsampleFactor


        dsOut_re=hTopN.addSignal(PVType,'dsOut_re');
        dsOut_re.SimulinkRate=slRate;
        dsOut_im=hTopN.addSignal(PVType,'dsOut_im');
        dsOut_im.SimulinkRate=slRate;
    else


        pVType1=pirelab.getPirVectorType(PVType,blockInfo.numinputs);
        dsOut_re=hTopN.addSignal(pVType1,'dsOut_re');
        dsOut_re.SimulinkRate=slRate;
        dsOut_im=hTopN.addSignal(pVType1,'dsOut_im');
        dsOut_im.SimulinkRate=slRate;
    end


    ds_vout=hTopN.addSignal(hTopNoutSigs(2).Type,'ds_vout');
    ds_vout.SimulinkRate=slRate;
    ds_rstout=hTopN.addSignal(hTopNoutSigs(2).Type,'ds_rstout');
    ds_rstout.SimulinkRate=slRate;

    dataOutTmp=hTopN.addSignal(dataOut.Type,'dataOutTmp');
    dataOutTmp.SimulinkRate=slRate;

    if blockInfo.DownsampleFactor==1
        pirelab.getWireComp(hTopN,dataInreg,dataOutTmp);
        pirelab.getWireComp(hTopN,validInreg,ds_vout);
    else
        if blockInfo.vecsize==1

            dsSection=this.elabDownsampler(hTopN,blockInfo,slRate,dataInreg,validInreg,...
            internalReset,dsOut_re,dsOut_im,ds_vout);
            pirelab.instantiateNetwork(hTopN,dsSection,[dataInreg,validInreg,...
            internalReset],[dsOut_re,dsOut_im,ds_vout],'dsSection');
        else

            dsSection=this.elabVectDownsampler(hTopN,blockInfo,slRate,dataInreg,validInreg,...
            internalReset,dsOut_re,dsOut_im,ds_vout);
            pirelab.instantiateNetwork(hTopN,dsSection,[dataInreg,validInreg,...
            internalReset],[dsOut_re,dsOut_im,ds_vout],'dsSection');
        end
    end

    if blockInfo.InputDataIsReal
        pirelab.getWireComp(hTopN,dsOut_re,dataOutTmp);
    else
        pirelab.getRealImag2Complex(hTopN,[dsOut_re,dsOut_im],dataOutTmp);
    end


    invalidOut=hTopN.addSignal(dataOut.Type,'invalidOut');
    invalidOut.SimulinkRate=slRate;
    pirelab.getConstComp(hTopN,invalidOut,0,'invalidOut');
    pirelab.getWireComp(hTopN,ds_vout,validOut);
    pirelab.getSwitchComp(hTopN,[dataOutTmp,invalidOut],dataOut,validOut,'','==',1);
end