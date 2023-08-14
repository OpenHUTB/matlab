function cgirComp=getDirectLookupComp(hN,hInSignals,hOutSignals,table_data,compName,diagnostics)










    if(nargin<5)
        compName='DirectLookupTable';
    end

    if(nargin<6)
        diagnostics='Error';
    end

    gp=pir;
    isTB=gp.getTopPirCtx.isTestbenchCtx;
    if isTB&&hOutSignals.Type.isLogicType&&...
        (hOutSignals.Type.WordLength>1||(isfi(table_data)&&table_data.FractionLength~=0))

        table_data=reinterpretcast(table_data,...
        numerictype(0,hOutSignals.Type.WordLength,0));
    else

        table_data=pirelab.getValueWithType(table_data,hOutSignals(1).Type,false);
    end
    tblsz=size(table_data);
    numtbldims=numel(tblsz(tblsz>1));
    vectorOut=numtbldims>1;
    allowOutOfRange=~isempty(diagnostics)&&(strcmpi(diagnostics,'None')||strcmpi(diagnostics,'Warning'));

    emlParams={table_data,vectorOut,allowOutOfRange};

    emlScript='hdleml_directlookup';

    cgirComp=pireml.getLookupComp(hN,hInSignals,hOutSignals,compName,emlScript,emlParams);
end
