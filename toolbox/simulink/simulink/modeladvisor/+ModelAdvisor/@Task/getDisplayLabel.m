function val=getDisplayLabel(this)




    prefix='';
    if isa(this.Check,'ModelAdvisor.Check')
        if this.MAObj.IsLibrary&&~this.Check.SupportLibrary&&~modeladvisorprivate('modeladvisorutil2','FeatureControl','ForceRunOnLibrary')
            prefix=DAStudio.message('ModelAdvisor:engine:PrefixForNSupportLibCheck');
        elseif any(strcmp(this.Check.CallbackContext,{'SLDV','CGIR'}))
            prefix=DAStudio.message('ModelAdvisor:engine:PrefixForExtensiveCheck');
        elseif~strcmp(this.Check.CallbackContext,'None')
            prefix=DAStudio.message('Simulink:tools:PrefixForCompileCheck');
        else
            prefix='';
        end
    end

    val=[prefix,this.DisplayName];
end
