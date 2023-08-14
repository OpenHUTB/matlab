function[bool]=isTimeExpression(aVar)















    if nargin>0
        aVar=convertStringsToChars(aVar);
    end

    bool=false;

    if isstring(aVar)&&isscalar(aVar)
        aVar=char(aVar);
    end

    if ischar(aVar)&&isvector(aVar)

        if(~isempty(strfind(aVar,','))&&strcmp('[',aVar(1))&&...
            strcmp(']',aVar(end)))&&...
            ~isempty(strfind(aVar,'t'))||(...
            ~isempty(strfind(aVar,'t'))&&isempty(strfind(aVar,',')))
            bool=true;
        end

    end

end
