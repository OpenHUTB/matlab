function calculateChargeData(obj,varargin)




































    p=inputParser;
    p.addParameter('IntegrationMethod','backwardeuler',@(x)validateattributes(x,{'char'},{}));
    p.parse(varargin{:});


    IntegrationMethod=p.Results.IntegrationMethod;




    switch IntegrationMethod

    case 'trapezoidal'
        charge=cumtrapz(obj.Time,-obj.Current);

    case 'forwardeuler'
        charge=cumsum(-obj.Current.*[1;diff(obj.Time)]);

    case 'backwardeuler'
        charge=cumsum(obj.Current.*[diff(obj.Time);1],'reverse');
        charge=charge-charge(1);

    otherwise
        error(getString(message('autoblks:autoblkErrorMsg:errIntMethod',IntegrationMethod)));
    end



    capacity=abs(max(charge)-min(charge));





    obj.Data(:,4)=charge;


    obj.Capacity=capacity;





    obj.calculateSocData();
