function[status,errMsg]=preApplyCallback(this,hDialog)




    status=1;
    errMsg='';
    i_setModelArgValues(this,hDialog);

end


function i_setModelArgValues(hObj,hDialog)

    lXrelModelArgNames=rtw.pil.SILPILBlock.getModelArgNames(hObj.Block);
    lTagPrefix='tag_';
    nModelArgs=numel(lXrelModelArgNames);
    for kArg=1:nModelArgs
        lTag=[lTagPrefix,lXrelModelArgNames{kArg}];
        lValue=hDialog.getWidgetValue(lTag);
        set_param(hObj,lXrelModelArgNames{kArg},lValue);
    end
end



