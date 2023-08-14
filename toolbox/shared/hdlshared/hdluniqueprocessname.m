function uniquename=hdluniqueprocessname(indata)




    narginchk(0,1);
    persistent incrementvalue;
    if isempty(incrementvalue)
        incrementvalue=0;
    end
    prefix='temp';

    if nargin==1
        if ischar(indata)
            prefix=indata;
        else
            incrementvalue=indata;
        end
    end

    uniquename=sprintf('%s%s%d',prefix,hdlgetparameter('clock_process_label'),incrementvalue);
    incrementvalue=incrementvalue+1;
end
