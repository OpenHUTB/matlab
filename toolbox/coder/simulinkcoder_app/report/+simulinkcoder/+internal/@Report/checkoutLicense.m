function out=checkoutLicense(obj)


    lics={'Matlab_Coder','Real-Time_Workshop','RTW_Embedded_Coder'};
    for i=1:length(lics)
        lic=lics{i};
        if~builtin('license','checkout',lic)
            out=false;
            return;
        end
    end

    out=true;

