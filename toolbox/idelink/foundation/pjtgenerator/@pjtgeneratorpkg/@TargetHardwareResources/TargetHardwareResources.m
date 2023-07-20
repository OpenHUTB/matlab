function this=TargetHardwareResources(varargin)





    if nargin>0
        disp('ConstructorInvocationError');
    end

    this=pjtgeneratorpkg.TargetHardwareResources;

    this.Description='Target Hardware Resources Component';


    this.loadComponentDataModel;
