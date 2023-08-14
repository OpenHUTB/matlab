function[f,grad_f]=cvar_feasibilityObjective(x)















    f=x(end);


    if nargout>1
        grad_f=zeros(size(x));
        grad_f(end)=1;
    end

end