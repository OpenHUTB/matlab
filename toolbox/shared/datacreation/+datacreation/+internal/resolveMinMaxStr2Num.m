function resolvedValue=resolveMinMaxStr2Num(inVal,dataType)




    if ischar(inVal)&&~strcmpi(inVal,'inf')&&(str2num(inVal)==Inf...
        ||single(str2num(inVal))==realmax('single'))

        if strcmpi(dataType,'single')
            resolvedValue=double(realmax('single'));
            return;
        end


        resolvedValue=realmax('double');
        return;
    end


    if ischar(inVal)&&(~strcmpi(inVal,'inf')&&(str2num(inVal)==Inf||...
        (~strcmpi(inVal,'-inf')&&str2num(inVal)==-Inf)...
        ||single(str2num(inVal))==realmax('single')*-1))


        if strcmpi(dataType,'single')
            resolvedValue=double(realmax('single')*-1);
            return
        end


        resolvedValue=realmax('double')*-1;
        return;
    end


    resolvedValue=str2num(inVal);%#ok<ST2NM>
