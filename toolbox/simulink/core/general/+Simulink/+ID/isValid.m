function b=isValid(sid)




    narginchk(1,1);
    err=lasterror;%#ok<*LERR>
    h=[];
    try
        h=Simulink.ID.getHandle(sid);
    catch
        lasterror(err);
    end
    b=~isempty(h);
