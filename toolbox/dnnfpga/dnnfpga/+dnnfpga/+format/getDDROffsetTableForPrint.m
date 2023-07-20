function tableOut=getDDROffsetTableForPrint(hDDROffsetMap,verbose)





    if verbose<1

        tableOut=[];
        return;
    end


    rawTable=dnnfpga.format.getDDROffsetTable(hDDROffsetMap,verbose);

    printTable=table('Size',size(rawTable),'VariableTypes',...
    {'string','string','string'},'VariableNames',...
    {'offset_name','offset_address','allocated_space'});


    for ii=1:size(printTable,1)
        addressName=rawTable.offset_name(ii);
        printTable.offset_name(ii)=addressName;
        addressValue=rawTable.offset_address(ii);
        printTable.offset_address(ii)=sprintf('0x%s',addressValue);


        if strcmpi(addressName,'EndOffset')
            printTable.allocated_space(ii)=sprintf('Total: %0.1f MB',hex2dec(addressValue)/1024/1024);
        else
            allocated_size=rawTable.allocated_space(ii)/1024/1024;
            printTable.allocated_space(ii)=sprintf('%0.1f MB',allocated_size);
        end
    end

    tableOut=printTable;

end


