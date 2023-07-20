function varargout=SwitchedReluctanceMotorInit(block,varargin)










    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    [WantBlockChoice,Ts]=SetInternalModels('get',block,'Switched Reluctance Motor',PowerguiInfo,varargin{1:2});


    SM=SwitchedReluctanceMotorParam(block,varargin{4:end});

    powerlibroot=which('powersysdomain');
    SM.SPSroot=powerlibroot(1:end-16);


    SwitchedReluctanceMotorCback(block,0);


    psbloadfunction(block,'gotofrom','Initialize');


    [WantBlockChoice,SM]=SPSrl('userblock','SwitchedReluctanceMotor',bdroot(block),WantBlockChoice,SM);
    power_initmask();


    varargout={Ts,SM,WantBlockChoice};
