function str=dispFpgaMsg(message,indentLevel)












    narginchk(1,2);

    if nargin<2
        indentLevel=1;
    end

    str=sprintf('### %s%s\n',blanks((indentLevel-1)*3),message);

    if nargout<1
        fprintf('%s',str);
    end
