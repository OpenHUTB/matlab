function idx=getSocIdxForPulses(obj,pulseList)





























    if nargin<2
        pulseList=1:obj.NumPulses;
    end




    switch obj.TestType
    case 'discharge'
        idx=obj.NumPulses+1-[pulseList(1)-1,pulseList];
    case 'charge'
        idx=[pulseList(1),pulseList+1];
    otherwise
        idx=[];


        warning(getString(message('autoblks:autoblkErrorMsg:errBattTest',obj.TestType)));
    end