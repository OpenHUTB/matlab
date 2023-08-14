function propSrc=atGetPropertySource(~,obj)




    psSL=rptgen_sl.propsrc_sl;


    if isa(obj,'Simulink.Object')
        mask=obj.Mask;
    else
        mask=rptgen.safeGet(obj,'Mask','get_param');
    end

    if strcmp(mask,'on')
        objType='Block';
    else
        objType=psSL.getObjectType(obj);
    end


    propSrc=psSL.getPropSourceObject(objType);
