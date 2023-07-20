classdef Supercapacitor_class<ConvClass&handle



    properties

        OldParam=struct(...
        'C',[],...
        'Rdc',[],...
        'Voltage',[],...
        'Ns',[],...
        'Np',[],...
        'Vinit',[],...
        'Temp',[],...
        'Nc',[],...
        'r',[],...
        'epsilon',[],...
        'Ich',[],...
        'Vstern',[],...
        'Ioc',[],...
        'Vself',[],...
        'I',[],...
        'Vmax',[],...
        'If',[],...
        'deltaV',[],...
        'alpha',[],...
        'sec',[]...
        )


        OldDropdown=struct(...
        'Units',[],...
        'PresetModel',[],...
        'EstParam',[],...
        'Self_dis',[],...
        'demandeplot',[]...
        )


        NewDirectParam=struct(...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        )


        BlockOption={...
        }
        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='electricdrivelib/Extra Sources/Supercapacitor'
        NewPath='elec_conv_Supercapacitor/Supercapacitor'
    end
    methods
        function obj=objParamMappingDirect(obj)
        end

        function obj=objParamMappingDerived(obj)


        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();
            logObj.addMessage(obj,'BlockNotSupported');
        end
    end

end
