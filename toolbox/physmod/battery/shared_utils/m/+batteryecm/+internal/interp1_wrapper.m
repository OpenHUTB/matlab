function y=interp1_wrapper(x_vec,y_vec,xp,interp_method,extrap_method)%#codegen




















    coder.allowpcode('plain');



    monotonic_x=all(diff(x_vec)>0)|all(diff(x_vec)<0);


    if~monotonic_x
        pm_error('physmod:simscape:compiler:patterns:checks:StrictlyAscendingOrDescendingVec','x_vec');
    end

    x_min=min(x_vec);
    x_max=max(x_vec);

    xi_idx=xp>=x_min&xp<=x_max;
    xo_idx=~xi_idx;


    if interp_method==1
        interpolation='linear';
    elseif interp_method==2
        interpolation='makima';
    else

        pm_error('physmod:battery:shared_utils:Interpolation:UnknownOption');
    end


    y=zeros(size(xp));

    if any(xi_idx)
        yi=interp1(x_vec,y_vec,xp(xi_idx),interpolation);
        y(xi_idx)=yi;
    end


    if extrap_method==1
        extrapolation='linear';

        if~isempty(xp(xo_idx))
            yo=interp1(x_vec,y_vec,xp(xo_idx),extrapolation,'extrap');
            y(xo_idx)=yo;
        end
    elseif extrap_method==2
        extrapolation='nearest';

        if~isempty(xp(xo_idx))
            yo=interp1(x_vec,y_vec,xp(xo_idx),extrapolation,'extrap');
            y(xo_idx)=yo;
        end
    elseif extrap_method==3

        if any(xo_idx)

            pm_error('physmod:battery:shared_utils:Interpolation:ExtrapolationError','xp');
            y=[];
        end
    else

        pm_error('physmod:battery:shared_utils:Interpolation:UnknownOption');
    end

end


