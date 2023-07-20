function namingRule=getNamingRuleFromMappingDefaults(mdlH)






    namingRule='';
    [mm,mappingType]=Simulink.CodeMapping.getCurrentMapping(mdlH);
    if isequal(mappingType,'CoderDictionary')&&...
        ~isempty(mm)&&~isempty(mm.DefaultsMapping)
        fcnClassName=mm.DefaultsMapping.getDataRefDerivedName('Execution','FunctionClass');
        if~isequal(fcnClassName,...
            DAStudio.message('coderdictionary:mapping:MappingFunctionDefault'))
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            dd=hlp.openDD(mdlH);
            fc=hlp.findEntry(dd,'FunctionClass',fcnClassName);
            if~isempty(fc)
                namingRule=hlp.getProp(fc,'NamingRule');
            end
        end
    end

end
