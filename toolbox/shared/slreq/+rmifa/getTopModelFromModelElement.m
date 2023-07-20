function topMdlH=getTopModelFromModelElement(elem)



    elemH=get_param(elem,'handle');
    if strcmp(get_param(elemH,'type'),'block_diagram')



        mdl=get_param(elemH,'name');
        blks=get_param(elemH,'blocks');
        elemH=get_param([mdl,'/',blks{1}],'handle');
    end
    entityStruct=Simulink.FaultedEntity(elemH).FaultedEntityStruct;
    topMdl=entityStruct.TopModel;
    topMdlH=get_param(topMdl,'handle');
end