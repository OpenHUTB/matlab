function valid=isvalidobj(dest)






    valid=~(isempty(dest)||dest(1)=='/'||dest(end)=='/'...
    ||~isempty(strfind(dest,'//')));

end

