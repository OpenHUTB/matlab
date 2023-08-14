function unmask(blockName)

    if~strcmp('library',get_param(bdroot(blockName),'BlockDiagramType'))

        set_param(blockName,'OpenFcn','');

        set_param(blockName,'Mask','off');

        open_system(blockName);
    else
        if strcmp('on',get_param(blockName,'Mask'))
            open_system(blockName,'mask');
        else
            open_system(blockName,'force');
        end
    end

end

