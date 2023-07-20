function result=enableRoundedCorners(enable)





    result=builtin('_simscape_enable_rounded_corners',enable);
    if simscape.internal.stylerInitialized()
        simscape.internal.updateStyles();
    end

end