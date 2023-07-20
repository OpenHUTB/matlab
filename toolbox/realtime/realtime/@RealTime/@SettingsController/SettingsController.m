function this=SettingsController(varargin)





    if nargin>0
        disp('ConstructorInvocationError');
    end

    this=RealTime.SettingsController;

    this.Description='Run on Hardware Dialog';


    this.loadComponentDataModel;
