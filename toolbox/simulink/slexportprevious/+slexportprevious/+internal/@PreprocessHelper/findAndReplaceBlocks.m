function findAndReplaceBlocks(obj,blks,tempSys,blockType)


    for j=1:length(blks)
        block=blks{j};
        ports=get_param(block,'Ports');
        pos=get_param(block,'Position');
        orient=get_param(block,'Orientation');
        name=get_param(block,'Name');


        name=regexprep(name,'([^/])/([^/])','$1//$2');


        portNum=-1;
        if strcmp(blockType,'InportShadow')
            portNum=get_param(block,'Port');
        end

        parent=get_param(block,'Parent');
        destBlock=[parent,'/',name];
        replacementBlock=obj.createEmptySubsystem(tempSys,...
        obj.getBlockTypeForDisplay(block),ports);
        delete_block(block);
        add_block(replacementBlock,destBlock,...
        'Position',pos,...
        'Orientation',orient);



        if strcmp(blockType,'InportShadow')
            set_param(destBlock,'MaskDisplay',['disp(''Replaced: InportShadow\n',...
            'Port number: ',num2str(portNum),''')']);
        end

    end

end
