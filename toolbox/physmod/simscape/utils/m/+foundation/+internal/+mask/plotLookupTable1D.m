function plotLookupTable1D(hBlock)






    params=foundation.internal.mask.getEvaluatedBlockParameters(hBlock);
    x=params{'x','Value'}{1};
    f=params{'f','Value'}{1};
    interp_method=params{'interp_method','Value'}{1};
    extrap_method=params{'extrap_method','Value'}{1};
    x=x(:);
    f=f(:);


    fileID='physmod:simscape:library:comments:physical_signal:lookup_tables:one_dimensional:';
    x_str=string(message([fileID,'x']));
    f_str=string(message([fileID,'f']));
    if interp_method==1
        assert(length(x)>=2,...
        message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',x_str,'2'))
    else
        assert(length(x)>=3,...
        message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',x_str,'3'))
    end
    assert(length(f)==length(x),...
    message('physmod:simscape:compiler:patterns:checks:LengthEqualLength',f_str,x_str))
    assert(all(diff(x)>0)||all(diff(x)<0),...
    message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingOrDescendingVec',x_str))


    if all(diff(x)<0)
        x_int=flip(x);
        f_int=flip(f);
    else
        x_int=x;
        f_int=f;
    end



    x_min=min(x);
    x_max=max(x);
    if extrap_method==3
        delta_x=0;
    else
        delta_x=x_max-x_min;
    end
    x_range=[x_min-delta_x/10,x_max+delta_x/10];


    if interp_method==1
        if extrap_method==1
            interp=griddedInterpolant(x_int,f_int,'linear','linear');
            fcn=@(x_plot)interp(x_plot);
        else
            interp=griddedInterpolant(x_int,f_int,'linear','nearest');
            fcn=@(x_plot)interp(x_plot);
        end
    else
        if extrap_method==1
            interp=akima1d(x_int,f_int);
            fcn=@(x_plot)interp(x_plot,'linear');
        else
            interp=akima1d(x_int,f_int);
            fcn=@(x_plot)interp(x_plot,'nearest');
        end
    end


    figure('Name',get_param(hBlock,'Name'));
    fplot(fcn,x_range)
    hold on
    plot(x,f,'x')
    hold off
    grid on
    xlabel('x')
    ylabel('f')

end