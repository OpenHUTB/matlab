function result=modelref_ReplacementTypes(csTop,csChild,varargin)
















    topEnableUserReplacementTypes=csTop.get_param('EnableUserReplacementTypes');
    childEnableUserReplacementTypes=csChild.get_param('EnableUserReplacementTypes');

    result=false;
    if strcmp(topEnableUserReplacementTypes,'off')&&...
        strcmp(childEnableUserReplacementTypes,'off')
        return;
    end



    topReplacementTypes=csTop.get_param('ReplacementTypes');
    childReplacementTypes=csChild.get_param('ReplacementTypes');
    result=~isequal(topReplacementTypes,childReplacementTypes);
end
