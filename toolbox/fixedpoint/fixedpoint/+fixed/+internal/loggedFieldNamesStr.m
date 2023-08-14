function logged_field_names_str=loggedFieldNamesStr(SymbolName,LoggedFieldNames)




    if isempty(LoggedFieldNames)

        logged_field_names_str='';
        return
    end
    if iscell(LoggedFieldNames)

        allEmpty=true;
        for i=1:length(LoggedFieldNames)
            if~isempty(LoggedFieldNames{i})
                allEmpty=false;
                break
            end
        end
        if allEmpty
            logged_field_names_str='';
            return
        end
    end
    if isempty(LoggedFieldNames{1})
        logged_field_names_str='-';
    else
        if isempty(SymbolName)
            logged_field_names_str=LoggedFieldNames{1};
        elseif isequal(LoggedFieldNames{1}(1),'{')

            logged_field_names_str=[SymbolName,LoggedFieldNames{1}];
        else

            logged_field_names_str=[SymbolName,'.',LoggedFieldNames{1}];
        end
    end
    for i=2:length(LoggedFieldNames)
        if isempty(LoggedFieldNames{i})
            logged_field_names_str=[logged_field_names_str,'<br />-'];%#ok<AGROW>
        else
            if isempty(SymbolName)
                logged_field_names_str=[logged_field_names_str,'<br />',LoggedFieldNames{i}];%#ok<AGROW>
            elseif isequal(LoggedFieldNames{i}(1),'{')

                logged_field_names_str=[logged_field_names_str,'<br />',SymbolName,LoggedFieldNames{i}];%#ok<AGROW>
            else

                logged_field_names_str=[logged_field_names_str,'<br />',SymbolName,'.',LoggedFieldNames{i}];%#ok<AGROW>
            end
        end
    end
end

