function enum_member=checkenum(h,prop_name,input_str,...
    enum_list,varargin)





    narginchk(4,5)
    input_str=convertStringsToChars(input_str);
    enum_selections=strncmpi(input_str,enum_list,length(input_str));
    num_matches=sum(enum_selections);
    if num_matches==1
        enum_member=enum_list{enum_selections};
        if nargin==5
            alias_list=varargin{1};
            enum_alias_logical=strcmpi(enum_member,alias_list);

            enum_alias_chosen=[enum_alias_logical(2:end),false];
            if any(enum_alias_chosen)
                enum_member=alias_list{enum_alias_chosen};
            end
        end
    else
        if isempty(h.Block)
            rferrhole=h.Name;
        else
            rferrhole=upper(class(h));
        end
        choices=[sprintf('''%s'', ',enum_list{1:end-1}),'or '''...
        ,enum_list{end},''''];
        if num_matches>1
            error(message('rf:rfbase:rfbase:checkenum:Ambiguous',...
            rferrhole,prop_name,choices));
        else
            error(message('rf:rfbase:rfbase:checkenum:InvalidParameterValue',...
            rferrhole,prop_name,choices));
        end
    end