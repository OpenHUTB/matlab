




function isF2FEnabled=isFixedPointConversionEnabled(cfg)
    if coderapp.internal.globalconfig('JavaFreePrjParser')
        if strcmp(cfg.getParam('param.fixptconv.enum.needfixedpoint'),'option.fixptconv.enum.needfixedpoint.yes')...
            ||~strcmp(cfg.getParam('param.FixedPointMode'),'option.FixedPointMode.None')
            isF2FEnabled=true;
        else
            isF2FEnabled=false;
        end
    else
        javaAdapter=com.mathworks.toolbox.coder.fixedpoint.FixedPointDataAdapterFactory.create(cfg);
        isF2FEnabled=strcmpi(char(javaAdapter.getNumericConversionMode().name()),'fixed_point');
    end
end