







function layoutReducedModel(optArgs)
    try

        for sysPath=keys(optArgs.SysPathsToLayout)
            gdir=Simulink.internal.variantlayout.LayoutManager(sysPath{1});
            gdir.layoutModel();
        end

        i_setAreaAnnotMargins(optArgs);
    catch me %#ok<NASGU>
    end
end


function i_setAreaAnnotMargins(optArgs)




    redAreaAnots=optArgs.i_getAreaAnnotMargins();

    for areaId=1:numel(redAreaAnots)


        index=[optArgs.OrigMdlAnnotationAreas.Handle]==redAreaAnots(areaId).Handle;
        marginOrigModel=optArgs.OrigMdlAnnotationAreas(index).Margins;
        redAreaAnots(areaId).setAreaPosition(marginOrigModel);
    end
end
