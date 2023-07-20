function port=utilUpdateOutport(blk,AvailableBlocks,type_out_mask,type_out_block,index,name,port)














    StaticName=horzcat(name,' terminator');
    StaticBlockType='built-in/Terminator';
    PortName=name;
    isNewPort=type_out_mask(index);
    isExistPort=type_out_block(index);
    sys=getfullname(blk);

    outportblk=horzcat(sys,'/',name);
    termblk=horzcat(sys,'/',StaticName);


    if isNewPort
        if~isExistPort
            position=get_param(termblk,'position');
            delete_block(termblk);
            add_block('built-in/Outport',outportblk);
            set_param(outportblk,'position',position,'port',num2str(port));
        end
        port=port+1;
    else
        if isExistPort
            if ismember(PortName,AvailableBlocks)
                position=get_param(outportblk,'position');
                delete_block(outportblk);
                add_block(StaticBlockType,termblk,'Position',position);
            end
        end
    end