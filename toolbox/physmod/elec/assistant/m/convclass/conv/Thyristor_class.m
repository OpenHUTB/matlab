classdef Thyristor_class<ConvClass&handle



    properties

        OldParam=struct(...
        'Ron',[],...
        'Lon',[],...
        'Vf',[],...
        'IC',[],...
        'Rs',[],...
        'Cs',[]...
        )


        OldDropdown=struct(...
        'Measurements',[]...
        )


        NewDirectParam=struct(...
        )


        NewDerivedParam=struct(...
        'Vf',[],...
        'Ron',[],...
        'Goff',[]...
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
        OldPath='powerlib/Power Electronics/Thyristor'
        NewPath='elec_conv_Thyristor/Thyristor'
    end

    methods
        function obj=objParamMappingDirect(obj)
        end


        function obj=Thyristor_class(Ron,Rs,Cs,Vf)
            if nargin>0
                obj.OldParam.Ron=Ron;
                obj.OldParam.Rs=Rs;
                obj.OldParam.Cs=Cs;
                obj.OldParam.Vf=Vf;
            end
        end

        function obj=objParamMappingDerived(obj)

            obj.NewDerivedParam.Ron=max(obj.OldParam.Ron,1e-6);
            obj.NewDerivedParam.Vf=max(obj.OldParam.Vf,1e-6);

            if obj.OldParam.Rs==inf||obj.OldParam.Cs==0
                obj.NewDerivedParam.Goff=1e-6;
            elseif obj.OldParam.Cs==inf
                obj.NewDerivedParam.Goff=max(1/obj.OldParam.Rs,1e-6);
            else
                obj.NewDerivedParam.Goff=1e-6;
            end

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();

            logObj.addMessage(obj,'CustomMessage','Inductance Lon (H) not imported');
            logObj.addMessage(obj,'CustomMessage','Initial current Ic (A) not imported');

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
