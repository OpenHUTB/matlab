function goToBlockOrObject(model,blocksOrObjs)







    for idx=1:size(blocksOrObjs,1)
        switch blocksOrObjs{idx,1}
        case 'block'
            hilite_system(blocksOrObjs{idx,2});
        case 'object'
            Simulink.UnitUtils.openObjectEditor(model,blocksOrObjs{idx,2});
        otherwise

        end
    end

end
