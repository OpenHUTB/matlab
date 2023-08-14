function str=indent(level)





    if nargin==0
        level=1;
    end

    indentstr='  ';
    str=repmat(indentstr,1,level);
