






function ret=getWidgetBindingType(blockHandle)










    if strcmpi(get_param(blockHandle,'isCoreWebBlock'),'on')
        try
            ret=get_param(blockHandle,'BindingType');
        catch me %#ok<NASGU>
            ret='Standalone';
        end
    else

        ret='unknown';
    end
end
