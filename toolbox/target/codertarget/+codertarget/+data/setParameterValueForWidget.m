function setParameterValueForWidget(hSrc,WidgetHint)





    if~isfield(WidgetHint,'DoNotStore')||~WidgetHint.DoNotStore
        hCS=hSrc.getConfigSet();



        hObj=hCS.getComponent('Coder Target');%#ok<NASGU>
        tagprefix='Tag_ConfigSet_CoderTarget_';
        if~isempty(WidgetHint.Storage)
            fieldName=WidgetHint.Storage;
        else
            fieldName=strrep(WidgetHint.Tag,tagprefix,'');
        end
        if isequal(WidgetHint.ValueType,'callback')
            value=eval(WidgetHint.Value);
        else
            value=WidgetHint.Value;
        end
        codertarget.data.setParameterValue(hCS,fieldName,value);
    end
end
