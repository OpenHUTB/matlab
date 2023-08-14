function mdlName=getReferenceName(hdl)






    blockType=get_param(hdl,'BlockType');
    switch blockType
    case 'ModelReference'
        mdlName=get_param(hdl,'ModelNameInternal');
    case 'SubSystem'
        mdlName=get_param(hdl,'ReferencedSubsystem');
    otherwise
        mdlName='';
    end
end
