
function[indirect_tab,indirect_fields_tab,indirect_indices_tab]=...
    buildIndirectTable(vars,vars_tab,params_tab)
























    vars_indirect_tab=containers.Map;
    vars_indirect_fields_tab=containers.Map;
    vars_indices_tab=containers.Map;
    for i=1:numel(vars)
        key=[vars(i).Source,':',vars(i).Name];
        buildIndirectTab(key,vars(i),vars_tab,vars_indirect_tab,...
        vars_indirect_fields_tab,[],vars_indices_tab,params_tab,{},'');
        if(~isKey(vars_indirect_tab,key))
            vars_indirect_tab(key)={};
        end
    end

    keys=vars_indirect_tab.keys;
    vars_exclusion_tab=containers.Map;
    for i=1:numel(keys)

        buildExclusionTab(keys{i},vars_indirect_tab,vars_exclusion_tab);
    end
    indirect_struct_fields_tab=containers.Map;
    buildIndirectFieldsTable(vars_exclusion_tab,vars_indirect_fields_tab,...
    indirect_struct_fields_tab);


    indirect_tab=vars_exclusion_tab;
    indirect_fields_tab=indirect_struct_fields_tab;
    indirect_indices_tab=vars_indices_tab;
end



function buildIndirectFieldsTable(vars_exclusion_tab,...
    vars_indirect_fields_tab,fields_tab)

    keys=vars_exclusion_tab.keys;
    for i=1:numel(keys)
        if isKey(vars_indirect_fields_tab,keys{i})
            field_map=vars_indirect_fields_tab(keys{i});
            field_map_keys=field_map.keys;
            for j=1:numel(field_map_keys)
                fields_tab(field_map_keys{j})=...
                field_map(field_map_keys{j});
            end
        end
    end
end


function[fields]=buildIndirectTab(key,var,vars_tab,vars_indirect_tab,...
    vars_indirect_fields_tab,sFields,vars_indirect_indices_tab,params_tab,...
    indices_vector,root_of_struct)

    fields=[];



    if(strcmpi(var.SourceType,'mask workspace')...
        &&slci.internal.isStateflowBasedBlock(var.Source))
        return;
    end

    DirectUsageDetails=var.DirectUsageDetails;
    for i=1:numel(DirectUsageDetails)
        curr_dud=DirectUsageDetails(i);
        UsageType=curr_dud.UsageType;
        if(strcmp(UsageType,'Block'))
            Identifier=curr_dud.Identifier;


            Identifier=regexprep(Identifier,'\n',' ');


            assert(ischar(Identifier)&&~isempty(Identifier));
            Properties=curr_dud.Properties;
            if(~isempty(Properties))
                for j=1:numel(Properties)
                    curr_prop=Properties{j};
                    down_key=[Identifier,':',curr_prop];

                    expression=curr_dud.Expressions{j};


                    [root,fields_curr,index_current]=...
                    slci.internal.getRootFieldsFromStruct(expression);





                    if isempty(root_of_struct)...
                        &&~isempty(root)
                        root_of_struct=root;
                    end



                    if~isempty(index_current)...
                        &&isempty(indices_vector)
                        indices_vector=index_current;
                    end
                    [fields]=appendFieldsFromExpression(...
                    sFields,fields_curr);

                    if(isKey(vars_tab,down_key))

                        indirect_var=vars_tab(down_key);
                        assert(strcmpi(down_key,[indirect_var.Source,':',indirect_var.Name]));




                        if(var~=indirect_var)

                            buildIndirectTab(...
                            key,indirect_var,vars_tab,...
                            vars_indirect_tab,vars_indirect_fields_tab,...
                            fields,vars_indirect_indices_tab,params_tab,...
                            indices_vector,root_of_struct);
                        end

                        if(isKey(vars_indirect_tab,key))
                            vars_indirect_tab(key)=[vars_indirect_tab(key),down_key];
                        else
                            vars_indirect_tab(key)={down_key};
                        end
                    end

                    if~isempty(fields)
                        if(isKey(vars_indirect_fields_tab,key))
                            vars_indirect=vars_indirect_fields_tab(key);
                        else
                            vars_indirect=containers.Map;
                        end

                        blk_obj=get_param(Identifier,'Object');
                        blkH=blk_obj.Handle;
                        paramsTabKey=...
                        slci.internal.constructKeyForParamsTable(blkH);

                        curr_prop_cell={curr_prop};
                        if(isKey(params_tab,paramsTabKey))
                            ptable=params_tab(paramsTabKey);

                            curr_prop_cell=getArgNames(ptable,expression);
                        end


                        for pIdx=1:numel(curr_prop_cell)
                            propertyInside=curr_prop_cell{pIdx};
                            field_tab_key=slci.internal.constructKeyForStructFieldsTable(...
                            blk_obj,propertyInside);

                            if~isKey(vars_indirect,field_tab_key)
                                vars_indirect(field_tab_key)=fields;
                                vars_indirect_fields_tab(key)=vars_indirect;


                                if~isempty(indices_vector)



                                    sid=Simulink.ID.getSID(blk_obj);
                                    [succeeded_dims,rows,cols]=getDimsFromVar(...
                                    root_of_struct,fields,sid);
                                    if succeeded_dims

                                        [succ_index,start_index,end_index]=resolveIndex(indices_vector,...
                                        rows,cols);
                                        if succ_index


                                            vars_indirect_indices_tab(field_tab_key)=...
                                            [start_index,end_index];
                                        end
                                    end



                                    indices_vector={};
                                end
                            end
                        end

                    end
                end
            end
        end


    end
end


function out=getArgNames(paramsTable,pValue)
    keys=paramsTable.keys;
    out={};
    for i=1:numel(keys)
        if strcmp(pValue,paramsTable(keys{i}))
            out{end+1}=keys{i};%#ok
        end
    end
    assert(~isempty(out),'There should be a parameter name mapping to the value');
end


function buildExclusionTab(key,vars_indirect_tab,vars_exclusion_tab)
    assert(isKey(vars_indirect_tab,key));
    keys=vars_indirect_tab.keys;
    for i=1:numel(keys)
        indirects=vars_indirect_tab(keys{i});
        if(any(strcmp(indirects,key)))
            return;
        end
    end
    vars_exclusion_tab(key)=vars_indirect_tab(key);%#ok
end


function[fields]=appendFieldsFromExpression(oldFields,...
    fieldsFromExpression)

    if isempty(oldFields)
        fields=fieldsFromExpression;
    else

        fields=[oldFields,fieldsFromExpression];
    end

end


function[succeeded,rows,cols]=getDimsFromVar(root,fields,sid)

    succeeded=false;
    rows=0;
    cols=0;

    expression=root;
    for i=1:numel(fields)
        expression=strcat(expression,'.',fields{i});
    end
    try
        val=slResolve(expression,sid);
        [rows,cols]=size(val);
        succeeded=true;
    catch

    end

end




function[succ,start_idx,end_idx]=resolveIndex(indices,rows,cols)

    start_idx=0;
    end_idx=0;
    num_indices=numel(indices);
    assert((num_indices==1)||(num_indices==2),...
    'scalar indexing only supported');
    try
        switch num_indices
        case 1

            index=indices{1};
            if strcmpi(index,'end')
                dims=rows*cols;
                start_idx=dims;
                end_idx=dims;
            else
                start_idx=str2double(index);
                end_idx=str2double(index);
            end
            succ=true;
        case 2
            row_index=indices{1};
            if strcmpi(row_index,'end')
                row_index=rows;
            else
                row_index=str2double(row_index);
            end
            col_index=indices{2};
            if strcmpi(col_index,'end')
                col_index=cols;
            else
                col_index=str2double(col_index);
            end

            index=sub2ind([rows,cols],row_index,col_index);

            start_idx=index;
            end_idx=index;
            succ=true;
        otherwise
            succ=false;

            assert(true,'code should not reach here');
        end
    catch
        succ=false;
    end
end
