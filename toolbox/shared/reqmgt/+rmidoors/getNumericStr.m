function numberString=getNumericStr(objId,moduleIdStr)



    if ischar(objId)
        if objId(1)=='#'
            numberString=objId(2:end);
        else
            numberString=objId;
        end

        prefix=rmidoors.getModulePrefix(moduleIdStr);
        if isempty(prefix)
            prefix='<empty>';
        else
            prefixLength=length(prefix);
            if length(numberString)>prefixLength&&strcmp(prefix,numberString(1:prefixLength))
                numberString=numberString(prefixLength+1:end);
            end
        end
        if hasNonDigits(numberString)



            fprintf(1,'%s\n',getString(message('Slvnv:reqmgt:doors_obj_open:UnmatchedPrefix',objId,prefix)));
            numberString=getNumericSuffix(numberString);
        end
    else
        numberString=num2str(objId);
    end
end

function yesno=hasNonDigits(str)
    yesno=any(str<48|str>57);
end

function out=getNumericSuffix(in)
    toks=regexp(in,'(\d+)$','tokens');
    out=toks{1}{1};
end
