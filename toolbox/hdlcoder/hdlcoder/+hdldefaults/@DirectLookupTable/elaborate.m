function hNewC=elaborate(this,hN,hC)



    slbh=hC.SimulinkHandle;
    table_rawdata=get_param(slbh,'mxTable');
    table_data=slResolve(table_rawdata,getfullname(slbh));

    dims=slResolve(get_param(slbh,'NumberOfTableDimensions'),getfullname(slbh));
    inputsSelectThisObjectFromTable=get_param(slbh,'InputsSelectThisObjectFromTable');
    diagnostics=get_param(slbh,'DiagnosticForOutOfRangeInput');
    tableDataType=get_param(slbh,'TableDataTypeStr');
    mapToRAMStr=getImplParams(this,'MapToRAM');
    if isempty(mapToRAMStr)
        hDriver=hdlcurrentdriver;
        mapToRAM=hDriver.getParameter('LUTMapToRAM');
    elseif strcmpi(mapToRAMStr,'on')
        mapToRAM=1;
    else
        mapToRAM=0;
    end



    if targetcodegen.targetCodeGenerationUtils.isNFPMode()&&(size(table_data,1)<=2)...
        &&(strcmp(tableDataType,'single')||strcmp(tableDataType,'double'))
    end

    useSLHandle=false;

    hNewC=pirelab.getDirectLookupComp(hN,hC.SLInputSignals,hC.SLOutputSignals,table_data,hC.Name,-1,...
    dims,inputsSelectThisObjectFromTable,diagnostics,tableDataType,mapToRAM);

    if(strcmpi(class(hNewC),'hdlcoder.directlookuptable_comp'))
        hNewC.setUseSLHandle(useSLHandle);
    end

end
