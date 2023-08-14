function out=makeSingleLineText(in,delim)































    if isempty(in)
        out='';
    else
        if nargin<2
            delim=' ';
        end

        try
            mlreportgen.utils.validators.mustBeSingleValue(delim);
            isCharOrStr=ischar(delim)||isstring(delim);

            if~isCharOrStr
                error(message("mlreportgen:utils:error:invalidDelimiter"));
            end

        catch
            error(message("mlreportgen:utils:error:invalidDelimiter"));
        end





        if iscellstr(in)
            in=in(:);
            [sp{1:size(in,1),1}]=deal(delim);
            sp{end}='';
            in=[in,sp]';
            out=[in{:}];
        elseif ischar(in)
            if size(in,1)>1


                out=mlreportgen.utils.makeSingleLineText(cellstr(in),delim);
            else
                out=in;
            end

        elseif isstring(in)
            out=mlreportgen.utils.makeSingleLineText(cellstr(in),delim);
            out=string(out);
        elseif isnumeric(in)
            out=mlreportgen.utils.makeSingleLineText(num2str(in),delim);

            out=regexprep(out," +"," ");
        else
            out="";
        end

        out=strrep(out,newline,delim);
    end
