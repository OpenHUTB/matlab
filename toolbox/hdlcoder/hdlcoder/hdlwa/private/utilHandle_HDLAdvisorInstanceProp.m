function utilHandle_HDLAdvisorInstanceProp(action,mdl_o)












    FPA_tag='_FPAdv';
    accuracy=40;

    switch action
    case 'synchToInstanceProperty'


        blks_with_data=find(mdl_o,'-property','RTWData','-not','RTWData',[]);

        for i=1:length(blks_with_data)
            blk_o=blks_with_data(i);

            field_names=fieldnames(blk_o.RTWdata);
            prop_names={};
            for j=1:length(field_names)
                if~isempty(findstr(field_names{j},FPA_tag))
                    prop_names{end+1}=regexprep(field_names{j},FPA_tag,'');
                else


                end
            end

            was_read_only=false;
            for j=1:length(prop_names)
                if isprop(blk_o,prop_names{j})

                    pp=findprop(blk_o,prop_names{j});

                    if strcmp(pp.AccessFlags.PublicSet,'off')
                        was_read_only=true;
                        pp.AccessFlags.PublicSet='on';
                    end


                    if ischar(blk_o.(prop_names{j}))
                        blk_o.(prop_names{j})=blk_o.RTWdata.([prop_names{j},FPA_tag]);
                    else
                        blk_o.(prop_names{j})=str2num(blk_o.RTWdata.([prop_names{j},FPA_tag]));
                    end
                    if was_read_only

                        pp.AccessFlags.PublicSet='off';
                        was_read_only=false;
                    end

                else

                    MSLDiagnostic('SimulinkFixedPoint:fpca:FPCAErrPropSyncProblem',prop_names{j},blk_o.getFullName).reportAsWarning;
                end

            end
        end

    case 'synchFromInstanceProperty'





        inst_prop_names={'min','max',...
        'OutMin','OutMax'};

        inst_prop_init={-inf,inf,...
        '[]','[]'};

        blks_with_data=find(mdl_o,'-property','min','-and','-property','max','-property','OutMin','-and','-property','OutMax');

        for i=1:length(blks_with_data)
            block_obj=blks_with_data(i);


            if isa(block_obj,'Stateflow.Data')
                continue;
            end

            for j=1:length(inst_prop_names)
                value=blks_with_data(i).(inst_prop_names{j});




                if(~strcmp(inst_prop_names{j},'min')&&~strcmp(inst_prop_names{j},'max'))...
                    ||~isempty(value)

                    if isnumeric(value)&&...
                        (max(value==inst_prop_init{j})||(~isempty(find(isnan(value),1))&&...
                        ~isempty(find(isnan(inst_prop_init{j}),1))))
                        continue
                    end
                    if ischar(value)&&(isempty(value)||isempty(slResolve(value,blks_with_data(i).getFullName)))
                        continue
                    end
                end
                if isprop(blks_with_data(i),'RTWdata')
                    if~isempty(blks_with_data(i).RTWdata)
                        if~isstruct(blks_with_data(i).RTWdata)

                            continue;
                        end
                    end

                    FPAdvisorData=blks_with_data(i).RTWdata;
                    FPAdvisorData.([inst_prop_names{j},FPA_tag])=num2str(value,accuracy);
                    blks_with_data(i).RTWdata=FPAdvisorData;

                end
            end
        end

    end

