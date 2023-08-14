function fixOutputSaveNameForVariants(harnessBDHandle)







    set_param(0,'CurrentSystem',harnessBDHandle)
    saveFormat=get_param(harnessBDHandle,'SaveFormat');
    if saveFormat=="Dataset"
        set_param(harnessBDHandle,'OutputSaveName','yout')
    else


        numOutports=length(...
        find_system(harnessBDHandle,'SearchDepth',1,'BlockType','Outport'));
        slprivate('variantfixes','InlineVariantExtOutputNotSupported',...
        'specify_csv_list',numOutports);
    end
end
