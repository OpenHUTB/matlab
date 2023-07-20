function initializeData(hObj,info)





    parameters=[info.parameters1,info.parameters2,info.parameters3...
    ,info.parameters4];
    set_param(hObj,'TargetExtensionData','');
    for i=1:numel(parameters)
        ParameterDetail=parameters{i};
        for j=1:numel(ParameterDetail)
            WidgetHint=ParameterDetail{j};
            if~isfield(WidgetHint,'DoNotStore')||~WidgetHint.DoNotStore
                tagprefix='Tag_ConfigSet_RTT_Settings_';
                fieldName=strrep(WidgetHint.Tag,tagprefix,'');
                a=get_param(hObj,'TargetExtensionData');
                a.(fieldName)=WidgetHint.Value;
                set_param(hObj,'TargetExtensionData',a);
            end
        end
    end
end
