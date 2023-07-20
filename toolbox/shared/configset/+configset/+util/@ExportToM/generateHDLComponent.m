function generateHDLComponent(obj,cc)





    cli=cc.getCLI;
    if isempty(cli)
        return;
    end

    varName=obj.config.varname;
    comments=strcmp(obj.config.comments,'on');
    adp=obj.adp;

    str={};
    tab='\t';
    str{end+1}=sprintf(['%% HDL Coder',newline,...
    'try ',newline,...
    tab,'%s_componentCC = hdlcoderui.hdlcc;',newline,...
    tab,'%s_componentCC.createCLI();',newline,...
    tab,'%s.attachComponent(%s_componentCC);'],...
    varName,varName,varName,varName);

    props=cli.getNonDefaultHDLCoderProps;

    for i=1:length(props)
        name=props{i};

        if strcmp(name,'HDLSubsystem')
            continue;
        end

        val=cli.(name);
        valstr=configset.internal.util.toMScript(val);


        comment_str='';
        if comments
            pdata=adp.getParamData(name);
            if~isempty(pdata)
                prompt=pdata.getDescription;
                if~isempty(prompt)
                    if prompt(end)==':'

                        prompt=prompt(1:end-1);
                    end
                    comment_str=sprintf('   %% %s',prompt);
                end
            end
        end

        str{end+1}=sprintf([tab,'%s_componentCC.set_param(''%s'',%s);%s'],...
        varName,name,valstr,comment_str);%#ok
    end

    str{end+1}=sprintf(['catch ME',newline,...
    tab,'warning(''Simulink:ConfigSet:AttachComponentError'', ''%%s'', ME.message);',newline,...
    'end']);
    obj.buffer{end+1}=strjoin(str,'\n');
