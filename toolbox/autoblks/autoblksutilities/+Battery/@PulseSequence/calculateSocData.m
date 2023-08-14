function calculateSocData(obj,InitialSOC)






























    charge=obj.Charge;
    capacity=obj.Capacity;


    if nargin<2


        soc=1+(charge-max(charge))/capacity;

    else



        validateattributes(InitialSOC,{'numeric'},{'scalar','>=',0,'<=',1})


        soc=InitialSOC+charge/capacity;

    end






    obj.Data(:,5)=soc;

