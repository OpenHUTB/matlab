function[row,col,value,cls]=remoteEval(expression,numberOfOutputs)


    if nargin==1
        outputs=0;
    else
        outputs=str2double(numberOfOutputs);
    end
    if(outputs>0)

        value=evalin('base',expression);
        cls=class(value);
        [row,col]=size(value);
    else
        value=[];
        disp(['evalin(''base'',',expression,')']);
        evalin('base',expression);
        cls=[];
        row=0;
        col=0;
    end
end


