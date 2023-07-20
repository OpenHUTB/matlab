function varargout=dir(h)

















    narginchk(1,1);
    nargoutchk(0,1);

    ideDirectory=cd(h(1));
    if(nargout==0)
        dir(ideDirectory);
    else
        varargout{1}=dir(ideDirectory);
    end


