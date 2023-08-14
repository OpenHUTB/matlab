function newVal=setRateTransitionBlockCode(this,val)

    newVal='Inline';



    if~isempty(this)&&...
        ~isempty(this.getConfigSet)&&...
        ~strcmp(get_param(this.getConfigSet,'MultiTaskRateTransMsg'),'error')&&...
        strcmp(val,'Function')
        DAStudio.error('RTW:configSet:configSetRateTransitionBlockCodeValidation');
    elseif~isempty(this)&&...
        ~isempty(this.getConfigSet)&&...
        strcmp(get_param(this.getConfigSet,'CodeInterfacePackaging'),'C++ class')&&...
        strcmp(val,'Function')
        DAStudio.error('RTW:configSet:configSetRateTransitionBlockCodeValidation2');
    else
        newVal=val;
    end
end
