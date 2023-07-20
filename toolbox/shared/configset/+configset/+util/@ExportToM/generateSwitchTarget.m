function generateSwitchTarget(obj)


    cs=obj.cs;
    varname=obj.config.varname;
    target=cs.getProp('SystemTargetFile');

    comment=['% Original configuration set target is ',target];

    if strcmp(target,'grt.tlc')||strcmp(target,'ert.tlc')
        code=[obj.config.varname,'.switchTarget(''',target,''','''');'];
    else
        code=sprintf('try\n    %s.switchTarget(''%s'', '''');',varname,target);
        code=sprintf('%s\ncatch ME\n    disp(ME.message);',code);
        backup='ert.tlc';
        msg=message('Simulink:tools:MFileDefaultToERT').getString;
        code=sprintf('%s\n    disp(''%s'');',code,msg);
        code=sprintf('%s\n    %s.switchTarget(''%s'', '''');\nend',code,varname,backup);
    end

    obj.buffer{end+1}=sprintf('%s\n%s',comment,code);
    obj.result{end+1}=struct('param','SystemTargetFile','value',target);
