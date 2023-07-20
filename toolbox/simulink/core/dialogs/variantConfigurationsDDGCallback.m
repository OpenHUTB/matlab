function varargout=variantConfigurationsDDGCallback(srcCache,dlg,name)




    varargout={};
    srcCache.saveCacheToVariantConfigurationCatalog();
    value=srcCache.VariantConfigurationCatalog;
    dlgSrc=dlg.getSource();
    if isa(dlgSrc,'Simulink.dd.EntryDDGSource')
        dlgSrc.setEntryValue(value);
    else
        assign(dlg.getContext,name,value);
    end
    varargout{1}=true;
    varargout{2}='';
end


function assign(context,aVariableName,aVariableValue)
    if isempty(context)

        assignin('base',aVariableName,aVariableValue);
        return;
    end

    assignin(context,aVariableName,aVariableValue);
end