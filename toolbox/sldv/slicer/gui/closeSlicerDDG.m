function closeSlicerDDG(studio)



    compId='MdlSlicer';
    try
        comp=studio.getComponent('GLUE2:DDG Component',compId);
    catch Mx
        comp=[];
    end

    if~isempty(comp)
        studio.destroyComponent(comp);
    end

end

