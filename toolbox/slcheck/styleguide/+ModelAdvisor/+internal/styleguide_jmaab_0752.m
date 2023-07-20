function hasViolation=styleguide_jmaab_0752(strToCheck)

    hasViolation=false;
    if isempty(strToCheck)
        return;
    end





    if~contains(strToCheck,'{')&&~contains(strToCheck,'}')
        return;
    end





    str=regexprep(strToCheck,'[\n\r]+','#\n');


    str=regexprep(str,'\s+','');


    if contains(str,'{#')&&contains(str,'#}')&&...
...
...
        (contains(str,'#{')||~isempty(regexp(str,'^{','once')))&&...
...
        (contains(str,'}#')||~isempty(regexp(str,'}$','once')))
        return;
    end

    hasViolation=true;
end