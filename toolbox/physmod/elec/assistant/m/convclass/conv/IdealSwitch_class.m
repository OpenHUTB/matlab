classdef IdealSwitch_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Ron',[],...
        'Lon',[],...
        'IC',[],...
        'Rs',[],...
        'Cs',[]...
        )


        OldDropdown=struct(...
        'Measurements',[]...
        )


        NewDirectParam=struct(...
        'Threshold',[]...
        )


        NewDerivedParam=struct(...
        'G_open',[],...
        'R_closed',[]...
        )


        NewDropdown=struct(...
        )


        BlockOption={...
        {'Measurements','on'},'m0';...
        {'Measurements','off'},'0';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Power Electronics/Ideal Switch'
        NewPath='elec_conv_IdealSwitch/IdealSwitch'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end


        function obj=IdealSwitch_class(Ron,Rs,Cs)
            if nargin>0
                obj.OldParam.Ron=Ron;
                obj.OldParam.Rs=Rs;
                obj.OldParam.Cs=Cs;
            end
        end

        function obj=objParamMappingDerived(obj)

            obj.NewDerivedParam.R_closed=max(obj.OldParam.Ron,1e-6);

            if obj.OldParam.Rs==inf||obj.OldParam.Cs==0
                obj.NewDerivedParam.G_open=1e-6;
            elseif obj.OldParam.Cs==inf
                obj.NewDerivedParam.G_open=max(1/obj.OldParam.Rs,1e-6);
            else
                obj.NewDerivedParam.G_open=1e-6;
            end

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();

            logObj.addMessage(obj,'CustomMessage','Initial state not imported');

            if ischar(obj.OldParam.Rs)
                obj.OldParam.Rs=evalin('base',obj.OldParam.Rs);
            end

            if ischar(obj.OldParam.Cs)
                obj.OldParam.Cs=evalin('base',obj.OldParam.Cs);
            end

            if obj.OldParam.Rs==inf||obj.OldParam.Cs==0
                logObj.addMessage(obj,'CustomMessage','The case of no snubber is not supported. Off-state conductance of device is set to be 1e-6.');
            elseif obj.OldParam.Cs==inf

            else
                logObj.addMessage(obj,'CustomMessage','The case of RC snubber is not supported. Off-state conductance of device is set to be 1e-6.');
            end

        end
    end

end
