function cgirComp=getLookupNDComp(hN,hInSignals,hOutSignals,...
    table_data,powerof2,bpType,oType,fType,interpVal,bp_data,compName,...
    slbh,dims,rndMode,satMode,diagnostics,extrap,mapToRAM)

















    if(nargin<18)
        mapToRAM=true;
    end

    if(nargin<17)
        extrap='Clip';
    end


    if(nargin<16)
        diagnostics='None';
    end


    if(nargin<15)
        satMode='Wrap';
    end

    if(nargin<14)
        rndMode='Floor';
    end

    if(nargin<13)
        dims=1;
    end

    if(nargin<12||isempty(slbh))
        slbh=-1;
    end

    if(nargin<11)
        compName='LUTnD';
    end

    cgirComp=hN.addComponent2(...
    'kind','lookuptable_comp',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'SLBlockHandle',slbh,...
    'BpData',bp_data,...
    'TableData',table_data,...
    'BpType',bpType,...
    'OutType',oType,...
    'PowerOf2',powerof2,...
    'FractionType',fType,...
    'InterpVal',interpVal,...
    'NumDimensions',dims,...
    'RoundingMode',rndMode,...
    'OverflowMode',satMode,...
    'Diagnostics',diagnostics,...
    'MapToRAM',mapToRAM,...
    'Extrapolation',extrap);

end
