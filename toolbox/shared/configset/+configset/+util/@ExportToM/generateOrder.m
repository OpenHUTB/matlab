function generateOrder(obj)


    str=sprintf('%% %s',DAStudio.message('Simulink:tools:MFileOrder1'));

    cs=obj.cs;
    name=cs.get_param('Name');
    dscr=cs.get_param('Description');

    varname=obj.config.varname;
    comments=strcmp(obj.config.comments,'on');
    if comments
        mcs=configset.internal.getConfigSetStaticData;
        name_comment=['% ',mcs.getParam('Name').getDescription];
        dscr_comment=['% ',mcs.getParam('Description').getDescription];
    else
        name_comment='';
        dscr_comment='';
    end

    str=sprintf('%s\n%s.set_param(''Name'', ''%s''); %s',str,varname,name,name_comment);
    obj.result{end+1}=struct('param','Name','value',name);


    dscr_print=configset.internal.util.toMScript(dscr);
    str=sprintf('%s\n%s.set_param(''Description'', %s); %s',str,varname,dscr_print,dscr_comment);

    obj.result{end+1}=struct('param','Description','value',dscr);

    obj.buffer{end+1}=str;

