function tableOut=getDDROffsetTable(hAddrMap,verbose)







    if verbose==1

        address_names={...
        'InputDataOffset',...
        'OutputResultOffset',...
        'SchedulerDataOffset',...
        'SystemBufferOffset',...
        'InstructionDataOffset',...
        'ConvWeightDataOffset',...
        'FCWeightDataOffset',...
        'EndOffset',...
        };
    elseif verbose>1

        address_names=hAddrMap.keys;
    else
        tableOut=[];
        return;
    end



    for i=length(address_names):-1:1
        if(~isKey(hAddrMap,address_names{i}))
            address_names(i)=[];
        end
    end


    addresses=zeros(1,length(address_names));
    for i=1:length(addresses)
        addresses(i)=hAddrMap(address_names{i});
    end
    [sorted_addresses,ind]=sort(addresses);


    T=table('Size',[length(addresses),3],'VariableTypes',...
    {'string','string','double'},'VariableNames',...
    {'offset_name','offset_address','allocated_space'});


    for i=1:length(addresses)-1
        T.offset_name(i)=address_names{ind(i)};
        T.offset_address(i)=dnnfpga.hwutils.numTo8Hex(sorted_addresses(i));
        T.allocated_space(i)=sorted_addresses(i+1)-sorted_addresses(i);
    end
    T.offset_name(i+1)=address_names{ind(i+1)};
    T.offset_address(i+1)=dnnfpga.hwutils.numTo8Hex(sorted_addresses(i+1));

    T.allocated_space(i+1)=hAddrMap('EndOffset')-sorted_addresses(i+1)+sorted_addresses(1);

    tableOut=T;

end


