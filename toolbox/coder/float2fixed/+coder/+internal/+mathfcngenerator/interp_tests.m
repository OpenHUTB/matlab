


if(0)
    x=[1,2,3,4,5];
    y=[5,-10,5,10,5];

    xi=linspace(x(1),x(end),50);
    yi_M=interp1(x,y,xi);

    for itr=1:length(xi)
        X=xi(itr);


        if(X<x(1))
            x_bot=1;
        else
            x_bot=floor(X/1);
        end
        x_top=x_bot+1;

        if(x_top>5)
            x_top=5;
            x_bot=4;
        end

        y_top=y(x_top);
        y_bot=y(x_bot);

        x_top=x(x_top);
        x_bot=x(x_bot);

        yi_calc(itr)=coder.internal.mathfcngenerator.HDLLookupTable.interp1D(X,x_bot,x_top,y_bot,y_top);
    end

    plot(x,y,'or',xi,yi_M,'-b',xi,yi_calc,'ok')
    legend({'LUT','Interpolated'})
    pause()
end

if(0)
    clear all
    close all
    xi=linspace(-1,+1,100);
    yi=asin(xi);
    yi_M=arrayfun(@hdl_lookup_skeleton_1Dinterp_uniform_HDLAsin,xi);
    plot(xi,yi,'or',xi,yi_M,'-b')
    legend({'LUT','Interpolated'})
end

clear all
close all
xi=linspace(-10,+10,100);
yi=sinc(xi);
yi_M=arrayfun(@generate_hdlsinc,xi);
plot(xi,yi,'or',xi,yi_M,'-b')
legend({'LUT','Interpolated'})
