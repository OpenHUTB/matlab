function port=utilUpdateInport(blk,AvailableBlocks,type_in_mask,type_in_block,index,name,port)














    StaticName=horzcat('ground ',name);
    StaticBlockType='built-in/Ground';
    PortName=name;
    isNewPort=type_in_mask(index);
    isExistPort=type_in_block(index);
    sys=getfullname(blk);

    inportblk=horzcat(sys,'/',name);
    groundblk=horzcat(sys,'/',StaticName);


    if isNewPort
        if~isExistPort
            position=get_param(groundblk,'position');
            delete_block(groundblk);
            add_block('built-in/Inport',inportblk);
            set_param(inportblk,'position',position,'port',num2str(port),'SampleTime','TsExperiment');
        end
        port=port+1;
    else
        if isExistPort
            if ismember(PortName,AvailableBlocks)
                position=get_param(inportblk,'position');
                delete_block(inportblk);
                add_block(StaticBlockType,groundblk,'Position',position);
            end
        end
    end