function bool=isImplicitConnectionBlock(handle)


    blockType=get_param(handle,'BlockType');

    list={'Inport'
'Outport'
'From'
'Goto'
'StateReader'
'StateWriter'
    };

    bool=ismember(blockType,list);

end

