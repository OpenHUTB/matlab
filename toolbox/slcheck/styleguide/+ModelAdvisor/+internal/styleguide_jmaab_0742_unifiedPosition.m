

function result=styleguide_jmaab_0742_unifiedPosition(str)
    result=true;
    if isempty(str)
        return;
    end

    if iscell(str)
        str=str{1};
    end

    if~isempty(regexp(str,'\n\s*(&&|\|\|)','once'))&&...
        ~isempty(regexp(str,'(&&|\|\|)(\s*\.{3}\n|\s*\n)','once'))

        result=false;
    end
end