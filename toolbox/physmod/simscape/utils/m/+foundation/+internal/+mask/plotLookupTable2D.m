function plotLookupTable2D(hBlock)






    params=foundation.internal.mask.getEvaluatedBlockParameters(hBlock);
    x1=params{'x1','Value'}{1};
    x2=params{'x2','Value'}{1};
    f=params{'f','Value'}{1};
    interp_method=params{'interp_method','Value'}{1};
    extrap_method=params{'extrap_method','Value'}{1};
    x1=x1(:);
    x2=x2(:);


    fileID='physmod:simscape:library:comments:physical_signal:lookup_tables:two_dimensional:';
    x1_str=string(message([fileID,'x1']));
    x2_str=string(message([fileID,'x2']));
    f_str=string(message([fileID,'f']));
    if interp_method==1
        assert(length(x1)>=2,...
        message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',x1_str,'2'))
        assert(length(x2)>=2,...
        message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',x2_str,'2'))
    else
        assert(length(x1)>=3,...
        message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',x1_str,'3'))
        assert(length(x2)>=3,...
        message('physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual',x2_str,'3'))
    end
    assert(all(size(f)==[length(x1),length(x2)]),...
    message('physmod:simscape:compiler:patterns:checks:Size2DEqual',f_str,x1_str,x2_str))
    assert(all(diff(x1)>0)||all(diff(x1)<0),...
    message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingOrDescendingVec',x1_str))
    assert(all(diff(x2)>0)||all(diff(x2)<0),...
    message('physmod:simscape:compiler:patterns:checks:StrictlyAscendingOrDescendingVec',x2_str))


    if all(diff(x1)<0)&&all(diff(x2)<0)
        x1_int=flip(x1);
        x2_int=flip(x2);
        f_int=rot90(f,2);
    elseif all(diff(x1)<0)
        x1_int=flip(x1);
        x2_int=x2;
        f_int=flipud(f);
    elseif all(diff(x2)<0)
        x1_int=x1;
        x2_int=flip(x2);
        f_int=fliplr(f);
    else
        x1_int=x1;
        x2_int=x2;
        f_int=f;
    end



    x1_min=min(x1);
    x1_max=max(x1);
    x2_min=min(x2);
    x2_max=max(x2);
    if extrap_method==3
        delta_x1=0;
        delta_x2=0;
    else
        delta_x1=x1_max-x1_min;
        delta_x2=x2_max-x2_min;
    end
    x1_range=[x1_min-delta_x1/10,x1_max+delta_x1/10];
    x2_range=[x2_min-delta_x2/10,x2_max+delta_x2/10];


    if interp_method==1
        if extrap_method==1
            interp=griddedInterpolant({x1_int,x2_int},f_int,'linear','linear');
            fcn=@(x1_plot,x2_plot)interp(x1_plot',x2_plot')';
        else
            interp=griddedInterpolant({x1_int,x2_int},f_int,'linear','linear');
            fcn=@(x1_plot,x2_plot)interp(min(max(x1_plot',x1_min),x1_max),min(max(x2_plot',x2_min),x2_max))';%#ok<UDIM>
        end
    else
        if extrap_method==1
            interp=akima2d(x1_int,x2_int,f_int);
            fcn=@(x1_plot,x2_plot)interp(x1_plot,x2_plot,'linear');
        else
            interp=akima2d(x1_int,x2_int,f_int);
            fcn=@(x1_plot,x2_plot)interp(x1_plot,x2_plot,'nearest');
        end
    end


    figure('Name',get_param(hBlock,'Name'));
    fsurf(fcn,[x1_range,x2_range],'EdgeColor',[0.5,0.5,0.5])
    hold on
    [x1_grid,x2_grid]=ndgrid(x1,x2);
    plot3(x1_grid(:),x2_grid(:),f(:),'o','MarkerEdgeColor',[0.5,0.5,0.5],'MarkerFaceColor',[0.5,0.5,0.5])
    hold off
    grid on
    xlabel('x1')
    ylabel('x2')
    zlabel('f')

end