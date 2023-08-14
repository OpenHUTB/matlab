classdef SignalUIProperties<starepository.ioitemproperty.ItemUIProperties



    properties(Constant,Hidden)
        NormalIcon='signal.gif';
        ErrorIcon=fullfile(matlabroot,'toolbox','simulink',...
        'simulink','+starepository','+ioitemproperty','icons','SignalError.png');

        WarningIcon=fullfile(matlabroot,'toolbox','simulink',...
        'simulink','+starepository','+ioitemproperty','icons','SignalWarning.png');
    end

    methods
        function obj=SignalUIProperties
            obj=obj@starepository.ioitemproperty.ItemUIProperties;
        end

    end

end

