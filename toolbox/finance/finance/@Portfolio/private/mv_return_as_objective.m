function[fobj,df]=mv_return_as_objective(z,f,objScalingFactor)
























    fobj=-f'*z;

    if nargin==3
        fobj=objScalingFactor*fobj;
    end


    if nargout>1
        df=-f;
        if nargin==3
            df=objScalingFactor*df;
        end
    end

end