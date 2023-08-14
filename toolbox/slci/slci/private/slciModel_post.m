function[success,message]=slciModel_post(system)



    try
        getSLCIModelObj(system,'clear');
        success=true;
        message='';
    catch ME
        message=ME.message;
        success=false;
    end

