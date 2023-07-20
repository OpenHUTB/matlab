function generateVersion(obj)


    cs=obj.cs;
    var=obj.config.varname;

    v_orig=cs.get_param('Version');
    line1=['% ',DAStudio.message('Simulink:tools:MFileOriginalConfigSetVersion'),': ',v_orig];
    line2=['if ',var,'.versionCompare(''',v_orig,''') < 0'];
    errorMsg=DAStudio.message('Simulink:tools:MFileVersionViolation');
    line3=sprintf('    error(''Simulink:MFileVersionViolation'', ''%s'');',errorMsg);
    line4='end';

    obj.buffer{end+1}=sprintf('%s\n%s\n%s\n%s',line1,line2,line3,line4);

