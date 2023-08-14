function prm=buildSysObjParams(this,hC,sysObjHandle)%#ok


















    if isa(sysObjHandle,'comm.BPSKModulator')
        prm.type='bpsk';
        prm.M=2;
        enc='Binary';
        prm.IntegerInput=0;
    elseif isa(sysObjHandle,'comm.QPSKModulator')
        prm.type='qpsk';
        prm.M=4;
        enc=sysObjHandle.SymbolMapping;
        prm.IntegerInput=isequal(sysObjHandle.BitInput,false);
    elseif isa(sysObjHandle,'comm.PSKModulator')
        prm.type='mpsk';
        prm.M=sysObjHandle.ModulationOrder;
        enc=sysObjHandle.SymbolMapping;
        prm.IntegerInput=isequal(sysObjHandle.BitInput,false);
    end

    size=hdlsignalsizes(hC.PirOutputSignals);
    prm.outWL=size(1);
    prm.outFL=size(2);
    prm.phaseOffset=sysObjHandle.PhaseOffset;

    if~size(1)==0

        if strcmpi(enc,'Gray')
            constel=pskmod(0:(prm.M-1),prm.M,prm.phaseOffset,enc);
        else
            if strcmpi(enc,'Custom')
                [~,mapping]=sort(sysObjHandle.CustomSymbolMapping);
                mapping=mapping-1;
            else
                mapping=0:(prm.M-1);
            end
            constel=exp(1i*(2*pi*mapping/prm.M+prm.phaseOffset));
        end
        constel_fi=fi(constel,1,prm.outWL,prm.outFL);

        prm.LUTvalues=constel_fi;
    else
        prm.LUTvalues=0;
    end


end
