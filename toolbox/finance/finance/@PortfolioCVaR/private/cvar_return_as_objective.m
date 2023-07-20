function[fobj,df]=cvar_return_as_objective(x,f,objScalingFactor)























    fobj=-objScalingFactor*(f'*x);


    if nargout>1
        df=-objScalingFactor*f;
    end

end