


function[bValid,val]=validateAndGetAxes(arg)



    arg=strtrim(arg);
    numarg=str2num(arg);%#ok
    bValid=true;
    if isempty(arg)
        val=[];
    elseif strcmp(arg,'[]')
        val=[];
    elseif~isempty(numarg)
        try
            validateattributes(numarg,{'numeric'},{'positive','integer',...
            'vector','<=',64})
            val=numarg;
        catch
            bValid=false;
            val='';
        end
    else
        bValid=false;
        val='';
    end
end

