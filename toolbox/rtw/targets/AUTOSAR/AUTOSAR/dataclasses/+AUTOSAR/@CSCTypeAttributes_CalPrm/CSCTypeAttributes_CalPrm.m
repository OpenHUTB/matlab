classdef CSCTypeAttributes_CalPrm<Simulink.CustomStorageClassAttributes




    properties(PropertyType='char')
        ElementName='UNDEFINED';
        PortName='UNDEFINED';
        InterfacePath='UNDEFINED';
        CalibrationComponent='';
        ProviderPortName='';
    end

    methods
        function retVal=isAddressable(hObj,hCSCDefn,hData)%#ok



            assert(isa(hData,'Simulink.Data'));


            retVal=(numel(hData.Value)~=1)||isstruct(hData.Value);
        end

        function obj=CSCTypeAttributes_CalPrm()
            mlock;
        end
    end

end
