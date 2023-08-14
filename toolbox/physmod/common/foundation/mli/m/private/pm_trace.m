function pm_trace(prfx,varargin)





    offset=2;

    [stack,where]=dbstack;
    where=where+offset;
    indicator=char('|'*ones([1,(length(stack)-offset)]));
    fprintf(1,'  %s+-[%s%s:%i]>',indicator,prfx,stack(where).file,stack(where).line);

    num=length(varargin);
    for j=1:num
        thisParameter=inputname(j);
        if~isempty(thisParameter)
            fprintf(1,'  %s: ',thisParameter);
        end
        theValue=varargin{j};
        if any(strcmp(class(theValue),{'double','logical'}))
            theValue=num2str(theValue);
        else
            theValue=char(theValue);
        end
        fprintf(1,'%s ',theValue);
    end
    fprintf(1,'\n');



