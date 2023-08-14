function check=getCheckDetails
    check.IDs={'.*','CheckSelectorGUI'};
    check.Names={DAStudio.message('ModelAdvisor:engine:ExclusionAllChecks'),...
    DAStudio.message('ModelAdvisor:engine:CheckSelector')};
end