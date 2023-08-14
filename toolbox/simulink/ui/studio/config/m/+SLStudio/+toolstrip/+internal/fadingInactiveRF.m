function fadingInactiveRF(cbinfo,action)




    isFadingOn=strcmpi(get_param(cbinfo.editorModel.handle,'VariantFading'),'on');
    if isFadingOn
        action.selected=true;
    else
        action.selected=false;
    end
end
