function cgirComp=getDirectLookupComp(hN,hInSignals,hOutSignals,table_data,compName,slbh,...
    dims,inputsSelectThisObjectFromTable,diagnostics,tableDataType,mapToRAM)














    if(nargin<5)
        compName='DirectLookupTable';
    end

    if(nargin<6||isempty(slbh))
        slbh=-1;
    end

    if nargin<7
        dims=1;
    end

    if nargin<8
        inputsSelectThisObjectFromTable='Element';
    end

    if nargin<9
        diagnostics='Error';
    end

    if nargin<10
        tableDataType='Inherit: Inherit from ''Table data''';
    end

    if nargin<11
        mapToRAM=true;
    end

    cgirComp=pircore.getDirectLookupComp(hN,hInSignals,hOutSignals,table_data,compName,slbh,dims,...
    inputsSelectThisObjectFromTable,diagnostics,tableDataType,mapToRAM);

end
