


function islicensed=codersLicensed()
    islicensed=true;

    if~ecoderinstalled()
        islicensed=false;
        return;
    end

    licenses={'RTW_Embedded_Coder','Matlab_Coder','real-time_workshop'};
    for cellitem=licenses
        lic=cellitem{1};
        [tf,errmsg]=license('checkout',lic);%#ok<ASGLU> keep second return argument for quite mode
        if tf==0
            islicensed=false;
        end
    end
end
