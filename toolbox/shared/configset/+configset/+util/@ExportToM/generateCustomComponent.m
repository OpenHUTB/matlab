function generateCustomComponent(obj,cc)





    className=class(cc);
    varName=obj.config.varname;

    str={};
    str{end+1}=sprintf('%% %s\ntry',cc.Name);
    str{end+1}=sprintf('  %s_componentCC = %s;',varName,className);
    str{end+1}=sprintf('  %s.attachComponent(%s_componentCC);',varName,varName);
    str{end+1}=obj.generateParameters(cc,'  ',false);
    str{end+1}=sprintf('catch ME\n  warning(''Simulink:ConfigSet:AttachComponentError'', ''%%s'', ME.message);\nend');

    obj.buffer{end+1}=strjoin(str,'\n');
