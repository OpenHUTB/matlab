function repairTimeVector(obj,varargin)


























    t=obj.Data(:,1);


    t=Battery.repairTimeVector(t,varargin{:});


    obj.Data(:,1)=t;