function optimizeSettings(userdata,cbinfo)


    modelH=cbinfo.model.Handle;

    switch(userdata)
    case 'all'
        set_param(modelH,'SimCompilerOptimization','on');
        set_param(modelH,'SimCtrlC','off');
        set_param(modelH,'IntegerOverflowMsg','none');
        set_param(modelH,'IntegerSaturationMsg','none');
    case 'compilerOpt'
        set_param(modelH,'SimCompilerOptimization','on');
    case 'ctrlC'
        set_param(modelH,'SimCtrlC','off');
    case 'overflow'
        set_param(modelH,'IntegerOverflowMsg','none');
    case 'saturate'
        set_param(modelH,'IntegerSaturationMsg','none');
    end

end
