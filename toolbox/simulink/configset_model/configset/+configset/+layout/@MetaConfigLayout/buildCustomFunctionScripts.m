function buildCustomFunctionScripts(layout,mcc,target,dirName)










    lines={};
    name=['get_',strrep(mcc.Class,'.','_'),'_data'];
    disp(['  building ',mcc.Name,' web dialog script']);

    lines{end+1}='% DO NOT MODIFY THIS FILE.  IT IS AUTO-GENERATED USING THE COMMAND configset.rehash.';
    lines{end+1}=sprintf('function [params, groups, FC] = %s(cs)\n',name);



    if isempty(mcc.Dependency)
        lines{end+1}='compStatus = 0;';
    else
        lines{end+1}='mcs = configset.internal.getConfigSetStaticData;';
        lines{end+1}=sprintf('mcc = mcs.getComponent(''%s'');',mcc.Class);
        lines{end+1}='if isempty(mcc); compStatus = 3; elseif isempty(mcc.Dependency); compStatus = 0; else; compStatus = mcc.Dependency.getStatus(cs, ''''); end';
    end

    if strcmp(mcc.Type,'Target')&&...
        ~strcmp(mcc.Class,'Simulink.CPPComponent')
        paramList=[target.ParamList,mcc.ParamList];
    else
        paramList=mcc.ParamList;
    end
    n=length(paramList);
    lines{end+1}=sprintf('params = {};\n');

    for i=1:n
        p=paramList{i};
        plines=loc_genParam(p,i);
        lines=[lines,plines,{newline}];%#ok<*AGROW>
    end
    lines=[lines,loc_genGroups(mcc,layout)];
    script=strjoin(lines,'\n');


    file=fullfile(dirName,[name,'.m']);
    fid=fopen(file,'w');
    fprintf(fid,'%s',script);
    fclose(fid);


    function lines=loc_genGroups(mcc,layout)
        lines={sprintf('groups = {};\n')};
        if~isempty(layout)
            groups=layout.GroupObjectMap.values;
            for i=1:length(groups)
                node=groups{i};
                for j=1:length(node)
                    if ismember(mcc.Name,node(j).Components)
                        lines=[lines,loc_genGroup(node(j))];
                    end
                end
            end
        end

        function out=loc_genGroup(node)
            name=node.Name;
            out={sprintf('%% group - %s',name)};
            vars={};
            assert(isa(node,'configset.layout.CategoryUIGroup'));

            fn=node.KeyFunction;
            if~isempty(fn)
                field='disp';
                var=['g_',field];
                out{end+1}=sprintf('%s = %s(cs);',var,fn);
                vars{end+1}={field,var};
            end

            toggle=node.EnableTriggerType;
            if strncmp(toggle,'toggle',6)
                fn=toggle(8:end);
                if~isempty(fn)
                    field='expand';
                    var=['g_',field];
                    out{end+1}=sprintf('%s = %s(cs, ''%s'');',var,fn,name);
                    vars{end+1}={field,var};
                end
            end

            fn=node.DialogSchemaFunction;
            if~isempty(fn)
                field='schema';
                var=['g_',field];
                out{end+1}=sprintf('%s = %s(cs, ''web'');',var,fn);
                vars{end+1}={field,var};
            end

            if~isempty(vars)
                n=length(vars);
                lines=cell(1,n);
                for i=1:n
                    var=vars{i};
                    lines{i}=['{''',var{1},''', ',var{2},'}'];
                end
                str=strjoin(lines,', ');
                out{end+1}=sprintf('groups{end + 1} = {''%s'', %s};',name,str);
            end
            out{end+1}=newline;



            function out=loc_genParam(p,index)
                out={};
                vars={};

                name=p.Name;
                out{end+1}=['% ',p.UniqueName];

                if~p.DependencyOverride
                    out{end+1}='if compStatus < 3';
                end

                fn=p.WidgetValuesFcn;
                if~isempty(fn)
                    field='value';
                    var=['p_',field];
                    out{end+1}=sprintf('p_WidgetValues = %s(cs, ''%s'', 0);',fn,name);
                    if isempty(p.WidgetList)
                        out{end+1}=sprintf('%s = p_WidgetValues{1};',var);
                        vars{end+1}={field,var};
                    end
                end

                [cout,cvars]=loc_getParamWidget(p,'p');
                out=[out,cout];
                vars=[vars,cvars];


                ws=p.WidgetList;
                if~isempty(ws)
                    field='widgets';
                    var=['p_',field];
                    n=length(ws);
                    out{end+1}=sprintf('p_widgets = cell(1, %d);',n);
                    for i=1:n
                        w=ws{i};
                        wlines=loc_genWidget(p,w,i);
                        out=[out,wlines];
                    end
                    vars{end+1}={field,var};
                end


                if~isempty(vars)
                    n=length(vars);
                    lines=cell(1,n);
                    for i=1:n
                        var=vars{i};
                        lines{i}=['{''',var{1},''', ',var{2},'}'];
                    end
                    str=strjoin(lines,', ');
                    str=[num2str(index-1),', ',str];
                    out{end+1}=['params{end + 1} = {',str,'};'];
                end

                if~p.DependencyOverride
                    out{end+1}='end';
                end


                function out=loc_genWidget(p,w,index)

                    out={};
                    vars={};

                    out{end+1}=['  % ',p.UniqueName,' - ',w.Name];
                    if~isempty(p.WidgetValuesFcn)
                        field='value';
                        var=['w_',field];
                        out{end+1}=sprintf('  %s = p_WidgetValues{%d};',var,index);
                        vars{end+1}={field,var};
                    end

                    [cout,cvars]=loc_getParamWidget(w,'  w');
                    out=[out,cout];
                    vars=[vars,cvars];


                    n=length(vars);
                    lines=cell(1,n);
                    for i=1:n
                        var=vars{i};
                        lines{i}=['{''',var{1},''', ',var{2},'}'];
                    end
                    str=strjoin(lines,', ');
                    out{end+1}=sprintf('  p_widgets{%d} = {%s};',index,str);

                    function[out,vars]=loc_getParamWidget(p,prefix)

                        out={};
                        vars={};

                        name=p.Name;


                        if~isempty(p.UI)
                            fn=p.UI.f_prompt;
                            if~isempty(fn)
                                field='disp';
                                var=[prefix,'_',field];
                                out{end+1}=sprintf('%s = %s(cs, ''%s'');',var,fn,name);
                                vars{end+1}={'disp',var};
                                vars{end+1}={'prompt',var};
                            end

                            fn=p.UI.f_tooltip;
                            if~isempty(fn)
                                field='tooltip';
                                var=[prefix,'_',field];
                                out{end+1}=sprintf('%s = %s(cs, ''%s'');',var,fn,name);
                                vars{end+1}={field,var};
                            end
                        end


                        fn=p.f_AvailableValues;
                        if~isempty(fn)
                            if isa(p,'configset.internal.data.WidgetStaticData')&&strcmp(p.WidgetType,'table')
                                field='tableData';
                                var=[prefix,'_',field];
                                out{end+1}=sprintf('%s = %s(cs, ''%s'');',var,fn,name);
                            else
                                field='options';
                                var=[prefix,'_',field];
                                out{end+1}=sprintf('%s = configset.internal.util.convertToOptions(%s(cs, ''%s''));',var,fn,name);
                            end
                            vars{end+1}={field,var};
                        end


                        dp=p.Dependency;
                        if~isempty(dp)
                            cdl=dp.CustomDepList;
                            if~isempty(cdl)
                                field='st';
                                var=[prefix,'_',field];
                                n=length(cdl);

                                strs=cell(1,n);
                                for i=1:length(cdl)
                                    fn=func2str(cdl{i}.getStatusFcn);
                                    strs{i}=sprintf('%s(cs, ''%s'')',fn,name);
                                end
                                str=strjoin(strs,', ');

                                if n>1
                                    out{end+1}=sprintf('%s = max([%s]);',var,str);
                                else
                                    out{end+1}=sprintf('%s = %s;',var,str);
                                end
                                vars{end+1}={field,var};
                            end
                        end


