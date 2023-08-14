function generateSolver(obj)




    name='Solver';
    cs=obj.cs;
    varName=obj.config.varname;
    val=cs.get_param(name);

    comments=strcmp(obj.config.comments,'on');
    comment_str='';
    if comments
        mcs=configset.internal.getConfigSetStaticData;
        hb=mcs.getParam(name);
        prompt=hb.getDescription;
        if~isempty(prompt)
            if prompt(end)==':'

                prompt=prompt(1:end-1);
            end
            comment_str=sprintf('   %% %s',prompt);
        end
    end
    obj.buffer{end+1}=sprintf('%s.set_param(''%s'', ''%s'');%s',...
    varName,name,val,comment_str);

    r=[];
    r.param=name;
    r.value=val;
    obj.result{end+1}=r;
