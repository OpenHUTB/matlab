function dstString=HTMLencode(srcString,choice)




    if nargin~=2
usage
        return
    end;


    char_carriageReturn=sprintf('\n');




    EncodeTable=...
    {char_carriageReturn,'&!#32;';...
    '!','&!#33;';...
    '"','&!#34;';...
    '#','&!#35;';...
    '$','&!#36;';...
    '%','&!#37;';...
    '&','&!#38;';...
    '''','&!#39;';...
    '<','&!#60;';...
    '>','&!#62;';...
    ' ','&!#160;';...
    '|','&!#166;';...
    };


    dstString='';
    switch choice
    case 'encode'
        for i=1:length(srcString)
            for j=1:length(EncodeTable)
                dstSubString=strrep(srcString(i),EncodeTable(j,1),EncodeTable(j,2));
                if~strcmp(dstSubString,srcString(i))
                    break
                end
            end
            dstString=[dstString,dstSubString];
        end
    case 'decode'
        for j=1:length(EncodeTable)
            srcString=strrep(srcString,EncodeTable(j,2),EncodeTable(j,1));
        end
        dstString=srcString;
    otherwise
        usage;
        return
    end


    function usage
        disp(' dstString = HTMLencode(srcString, ''encode'')');
        disp(' dstString = HTMLencode(srcString, ''decode'')');
