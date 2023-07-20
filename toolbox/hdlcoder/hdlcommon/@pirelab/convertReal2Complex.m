function comp=convertReal2Complex(hN,hSig,isSigInput,compName)








    if nargin<4
        compName=hSig.Name;
    end

    if isSigInput

        inType=hSig.Type;
        outType=hdlcoder.tp_complex(inType);
    else


        inType=hSig.Type.BaseType;
        outType=hSig.Type;
    end

    constSig=hN.addSignal(inType,[compName,'_im']);
    constSig.SimulinkRate=hSig.SimulinkRate;
    if isSigInput
        realimag_in=hSig;
        realimag_in.Name=[compName,'_re'];

        realimag_out=hN.addSignal(outType,compName);
        realimag_out.SimulinkRate=hSig.SimulinkRate;
    else
        realimag_in=hN.addSignal(inType,[compName,'_re']);
        realimag_in.SimulinkRate=hSig.SimulinkRate;

        realimag_out=hSig;

        realimag_in.acquireDrivers(hSig);
    end


    pirelab.getConstComp(hN,constSig,0);


    comp=pirelab.getRealImag2Complex(hN,[realimag_in,constSig],...
    realimag_out);
end

