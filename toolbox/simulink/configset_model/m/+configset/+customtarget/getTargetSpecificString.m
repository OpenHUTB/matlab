function str=getTargetSpecificString(h,type)



    format=getStringFormat(h);
    str='';

    if~isempty(format)&&isstruct(format)&&isfield(format,'make_var_name')&&...
        isfield(format,'tlc_option_name')&&isfield(format,'prop_name')

        switch type
        case 'make_options'
            for i=1:length(format)
                item=format(i);
                if~isempty(item.prop_name)&&isprop(h,item.prop_name)&&ischar(item.prop_name)...
                    &&~isempty(item.make_var_name)&&ischar(item.make_var_name)
                    prop=findprop(h,item.prop_name);
                    type=findtype(prop.DataType);


                    val=[];

                    try
                        val=h.(item.prop_name);
                    catch
                    end

                    if isnumeric(val)||islogical(val)
                        val=num2str(val);
                    elseif strcmp(type.Name,'on/off')||strcmp(type.Name,'slbool')
                        if strcmp(val,'on')
                            val='1';
                        else
                            val='0';
                        end
                    elseif~isempty(findprop(type,'Strings'))...
                        &&~isempty(findprop(type,'Values'))



                        if isfield(item,'make_enum_in_num')&&~isempty(item.make_enum_in_num)...
                            &&islogical(item.make_enum_in_num)&&item.make_enum_in_num
                            for j=1:length(type.Strings)
                                if ischar(type.Strings{j})&&strcmp(type.Strings{j},val)
                                    val=num2str(type.Values(j));
                                    break;
                                end
                            end
                        else
                            val=['"',val,'"'];
                        end

                    else
                        val=['"',val,'"'];
                    end

                    if~isempty(str)
                        str=[str,' '];
                    end

                    str=[str,item.make_var_name,'=',val];
                end
            end

        case 'tlc_options'
            for i=1:length(format)
                item=format(i);
                if~isempty(item.prop_name)&&isprop(h,item.prop_name)&&ischar(item.prop_name)...
                    &&~isempty(item.tlc_option_name)&&ischar(item.tlc_option_name)
                    prop=findprop(h,item.prop_name);
                    type=findtype(prop.DataType);


                    val=[];

                    try
                        val=h.(item.prop_name);
                    catch
                    end

                    if isnumeric(val)||islogical(val)
                        val=num2str(val);
                    elseif strcmp(type.Name,'on/off')||strcmp(type.Name,'slbool')
                        if strcmp(val,'on')
                            val='1';
                        else
                            val='0';
                        end
                    elseif~isempty(findprop(type,'Strings'))...
                        &&~isempty(findprop(type,'Values'))



                        if isfield(item,'tlc_enum_in_num')&&~isempty(item.tlc_enum_in_num)...
                            &&islogical(item.tlc_enum_in_num)&&item.tlc_enum_in_num
                            for j=1:length(type.Strings)
                                if ischar(type.Strings{j})&&strcmp(type.Strings{j},val)
                                    val=num2str(type.Values(j));
                                    break;
                                end
                            end
                        else
                            val=['"',val,'"'];
                        end

                    else
                        val=['"',val,'"'];
                    end

                    if~isempty(str)
                        str=[str,' '];
                    end



                    if~isempty(findstr(val,' '))
                        str=[str,'''-a',item.tlc_option_name,'=',val,''''];
                    else
                        str=[str,'-a',item.tlc_option_name,'=',val];
                    end
                end
            end

        otherwise

        end
    end

