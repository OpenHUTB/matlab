function out=generateParameters(obj,cc,indent,saveToBridge)


    cs=cc.getConfigSet;
    str={};
    props=cc.getProp;
    orderedProps=configset.internal.util.sortByDependency([],props,obj.adp);

    comments=strcmp(obj.config.comments,'on');
    adp=obj.adp;

    varName=obj.config.varname;

    for i=1:length(orderedProps)
        name=orderedProps{i};


        if ismember(name,{'Name','Description',...
            'SystemTargetFile','HardwareBoard',...
            'TargetLang','CodeInterfacePackaging','GenerateAllocFcn',...
            'Solver'})
            continue;
        end

        pdata=adp.getParamData(name);
        if~isempty(pdata)&&~pdata.Hidden||...
            ismember(name,{...
            'TargetExtensionData',...
            'TargetExtensionPlatform',...
            'CoderTargetData'})

            if obj.isParamSaved(cs,pdata)||...
                ismember(name,{...
                'ExtModeMexFile'})

                try
                    val=cc.get_param(name);
                catch
                    continue;
                end

                valstr=configset.internal.util.toMScript(val);


                comment_str='';
                if comments
                    prompt=pdata.getDescription;
                    if~isempty(prompt)
                        if prompt(end)==':'

                            prompt=prompt(1:end-1);
                        end
                        comment_str=sprintf('   %% %s',prompt);
                    end
                end
                str{end+1}=sprintf('%s%s.set_param(''%s'', %s);%s',...
                indent,varName,name,valstr,comment_str);%#ok

                if saveToBridge&&...
                    ~ismember(name,{'TargetExtensionData',...
                    'TargetExtensionPlatform',...
                    'TargetHardwareResources',...
                    'CoderTargetData'})

                    r=[];
                    r.param=name;
                    r.value=val;
                    obj.result{end+1}=r;
                end
            end
        end
    end

    out=strjoin(str,'\n');
