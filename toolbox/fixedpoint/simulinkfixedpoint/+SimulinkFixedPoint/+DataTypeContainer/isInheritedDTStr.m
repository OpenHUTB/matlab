function flag=isInheritedDTStr(DTString)






    flag=~isempty(regexp(DTString,'^(Inherit: |Inherit |Same as)','ONCE'))...
    ||strcmp(DTString,'auto');
end
