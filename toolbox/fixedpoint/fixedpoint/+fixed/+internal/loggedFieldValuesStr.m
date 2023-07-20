function decimalNumberVectorStr=loggedFieldValuesStr(v,doLog2Display,isbool,doBoldYes,doBoldNo)



    if nargin<2,doLog2Display=false;end
    if nargin<3,isbool=false;end
    if nargin<4,doBoldYes=false;end
    if nargin<5,doBoldNo=false;end
    if doLog2Display
        formatFunction=@log2ToStr;
    elseif isbool
        formatFunction=@bool2str;
    else
        formatFunction=@fixed.internal.compactButAccurateNum2Str;
    end
    if isempty(v)

        decimalNumberVectorStr='';
        return
    end
    if iscell(v)

        allEmpty=true;
        for i=1:length(v)
            if~isempty(v{i})
                allEmpty=false;
                break
            end
        end
        if allEmpty
            decimalNumberVectorStr='';
            return
        end
    end
    if length(v)==1
        if iscell(v)
            val=v{1};
        else
            val=v;
        end
        decimalNumberVectorStr=formatFunction(val);
    else
        if iscell(v)
            val=v{1};
        else
            val=v(1);
        end
        if isempty(val)
            decimalNumberVectorStr='-';
        else
            decimalNumberVectorStr=formatFunction(val);
        end
        for i=2:length(v)
            if iscell(v)
                val=v{i};
            else
                val=v(i);
            end
            if isempty(val)
                decimalNumberVectorStr=[decimalNumberVectorStr,'<br />-'];%#ok<AGROW>
            else
                decimalNumberVectorStr=[decimalNumberVectorStr,'<br />',formatFunction(val)];%#ok<AGROW>
            end
        end
    end

    function str=log2ToStr(val)
        if isempty(val)
            str='-';
        elseif isequal(val,0)
            str='0';
        else







            [f,e]=log2(val);
            str=sprintf('%-+7.4f * 2^%d',f,e);
        end
    end

    function str=bool2str(val)

        bold_format='<b>%s</b>';
        if isempty(val)
            str='-';
        elseif isequal(val,0)
            str='No';
            if doBoldNo

                str=sprintf(bold_format,str);
            end
        else
            str='Yes';
            if doBoldYes

                str=sprintf(bold_format,str);
            end
        end
    end
end

