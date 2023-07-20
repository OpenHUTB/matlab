function addData(obj,time,voltage,current)
































    if~isequal(size(time),size(voltage),size(current))
        error(getString(message('autoblks:autoblkErrorMsg:errSizeTVI')));
    end


    validateattributes(time,{'numeric'},{'nonnegative','finite','nonnan','increasing'})
    validateattributes(voltage,{'numeric'},{'nonnegative','finite','nonnan'})
    validateattributes(current,{'numeric'},{'finite','nonnan'})


    charge=nan(size(current));
    soc=charge;


    obj.Data=[time,voltage,current,charge,soc];


    obj.calculateChargeData();
