function str=newline(level)





    if nargin==0
        level=1;
    end

    indentstr=char(10);
    str=repmat(indentstr,1,level);
