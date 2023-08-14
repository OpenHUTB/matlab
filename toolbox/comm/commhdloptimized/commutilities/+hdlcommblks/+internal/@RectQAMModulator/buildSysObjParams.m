function prm=buildSysObjParams(this,hC,hN,sysObjHandle)%#ok




    prm=struct;

    prm.hC=hC;
    prm.hN=hN;

    prm.M=sysObjHandle.ModulationOrder;
    prm.IntegerInput=~sysObjHandle.BitInput;

    switch lower(sysObjHandle.SymbolMapping)
    case 'binary'
        idx=0:(prm.M-1);
        symbolOrder='bin';
    case 'gray'
        idx=comm.internal.utilities.bin2gray(0:(prm.M-1),'qam',prm.M);
        symbolOrder='gray';
    otherwise
        idx=sysObjHandle.CustomSymbolMapping;
        symbolOrder='user-defined';
    end


    s=sysObjHandle.getAdaptorRunTimeData();
    RTPs=s.RTPs;
    if isfield(RTPs,'modmap')
        realData=RTPs.modmap(1:2:end);
        imagData=RTPs.modmap(2:2:end);
        prm.TableDataReal=realData(idx+1);
        prm.TableDataImag=imagData(idx+1);
    else

        if strcmpi(sysObjHandle.SymbolMapping,'custom')
            constel=(qammod(0:(prm.M-1),prm.M,idx)).*...
            exp(1j*sysObjHandle.PhaseOffset);
        else
            constel=qammod(0:(prm.M-1),prm.M,sysObjHandle.PhaseOffset,symbolOrder);
        end

        constel_fi=fi(constel,'numerictype',sysObjHandle.CustomOutputDataType);

        prm.TableDataReal=real(constel_fi);
        prm.TableDataImag=imag(constel_fi);
    end

end
