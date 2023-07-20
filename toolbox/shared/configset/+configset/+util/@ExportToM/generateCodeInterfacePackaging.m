function generateCodeInterfacePackaging(obj)





    cs=obj.cs;
    varName=obj.config.varname;
    paramNames={'TargetLang','CodeInterfacePackaging','GenerateAllocFcn'};

    for i=1:length(paramNames)
        name=paramNames{i};
        val=cs.get_param(name);

        comments=strcmp(obj.config.comments,'on');
        comment_str='';
        if comments
            mcs=configset.internal.getConfigSetStaticData;
            p=mcs.getParam(name);
            prompt=p.getDescription;
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
    end
