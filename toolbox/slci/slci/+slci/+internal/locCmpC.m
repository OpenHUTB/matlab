





function ret=locCmpC(actualC,blC,readFile)
    rplPattern={
    'replace','//[^\n]*\n|/\*(.|[\r\n])*?\*/','';
    'replace','\s\s+','\n';
    'replace','\s*(\+|-|\*|\/|%|>=|<=|!=|=|\=\=|>>|<<|&|\||&&|\|\||\?|:|\(|>|<|\)|\(|!|\[|\])\s*','$1';
    'replace','^(?:[\t ]*(?:\r?\n|\r))+','';
    };

    if(readFile)

        try
            actualC=fileread(actualC);
        catch
            ret=2;
            return;
        end

        try
            blC=fileread(blC);
        catch
            ret=2;
            return
        end
    end

    for i=1:size(rplPattern,1)
        switch rplPattern{i,1}
        case 'replace'
            actualC=regexprep(actualC,rplPattern{i,2:end});
            blC=regexprep(blC,rplPattern{i,2:end});
        otherwise

        end
    end

    if strcmp(actualC,blC)
        ret=0;
    else
        ret=1;
    end
