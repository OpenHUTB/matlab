function result=isValidClass(str)





    if nargin<1
        str='';
    end

    str=convertStringsToChars(str);
    result=~isempty(str)&&~isempty(meta.class.fromName(str));
end