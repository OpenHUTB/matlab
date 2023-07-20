function[success,message]=slciRunMatlabCheck_pre(sys)




    try
        initModel(bdroot(sys));
        getSLCIModelObj(sys);
        success=true;
        message='';
    catch ME
        message=ME.message;
        success=false;
    end

end
