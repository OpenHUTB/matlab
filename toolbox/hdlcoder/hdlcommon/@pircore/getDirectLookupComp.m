function cgirComp=getDirectLookupComp(hN,hInSignals,hOutSignals,table_data,compName,slbh,...
    dims,inputsSelectThisObjectFromTable,diagnostics,tableDataType,mapToRAM)













    if nargin<11
        mapToRAM=true;
    end

    if nargin<10
        tableDataType='Inherit: Inherit from ''Table data''';
    end

    if nargin<9
        diagnostics='None';
    end

    if nargin<8
        inputsSelectThisObjectFromTable='Element';
    end

    if nargin<7
        dims=1;
    end

    if(nargin<5)
        compName='DirectLookupTable';
    end

    cgirComp=hN.addComponent2(...
    'kind','directlookuptable_comp',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'SLBlockHandle',slbh,...
    'TableData',table_data,...
    'NumDimensions',dims,...
    'InputsSelectThisObjectFromTable',inputsSelectThisObjectFromTable,...
    'Diagnostics',diagnostics,...
    'MapToRAM',mapToRAM,...
    'TableDataType',tableDataType);
end
