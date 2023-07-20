
function[success,message]=slciModel_pre(system)



    try
        getSLCIModelObj(system,'init');
        success=true;
        message='';
    catch ME
        message=ME.message;
        success=false;
    end

end
