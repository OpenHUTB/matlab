function cgirComp=getLookupNDComp(hN,hInSignals,hOutSignals,...
    table_data,powerof2,bpType,oType,fType,interpVal,bp_data,compName)

















    if(nargin<10)
        compName='LUTnD';
    end

    emlParams={table_data,powerof2,oType,fType,interpVal};

    emlParams=[emlParams(:)',bp_data(:)'];
    emlParams=[emlParams(:)',bpType(:)'];

    emlScript='hdleml_lookupnd';

    cgirComp=pireml.getLookupComp(hN,hInSignals,hOutSignals,compName,emlScript,emlParams);
end


