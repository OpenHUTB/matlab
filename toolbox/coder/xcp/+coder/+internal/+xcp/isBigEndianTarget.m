function ret=isBigEndianTarget(modelName,cs,isHostBased)



    isPWS=strcmp(get_param(cs,'PortableWordSizes'),'on');
    targetEndianess=get_param(cs,'TargetEndianess');

    coder.internal.xcp.validateEndianess(modelName,...
    targetEndianess,isHostBased,isPWS);





    isBigEndian=strcmp(targetEndianess,'BigEndian');
    ret=isBigEndian&&~(isHostBased&&isPWS);
end
