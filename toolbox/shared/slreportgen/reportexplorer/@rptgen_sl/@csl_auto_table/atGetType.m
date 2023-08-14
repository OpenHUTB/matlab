function[oType,oTypeDisplay]=atGetType(this,propsrc,obj)




    oType=propsrc.getObjectType(obj);

    if strcmpi(oType,'block')
        oTypeDisplay=get_param(obj,'MaskType');
        if isempty(oTypeDisplay)
            oTypeDisplay=get_param(obj,'BlockType');
        end
    elseif strcmpi(oType,'system')
        oTypeDisplay=get_param(obj,'MaskType');
        if isempty(oTypeDisplay)
            oTypeDisplay=oType;
        end
    elseif strcmpi(oType,'model')
        oTypeDisplay=rptgen.capitalizeFirst(get_param(obj,'BlockDiagramType'));
    else
        oTypeDisplay=oType;
    end
