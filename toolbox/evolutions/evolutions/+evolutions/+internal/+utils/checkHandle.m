function tf=checkHandle(handle)




    if nargin<1
        tf=false;
    else
        tf=~isempty(handle)&&isvalid(handle);
    end
