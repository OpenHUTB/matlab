


classdef SystemObjectBased<hdlturnkey.swinterface.SoftwareInterfaceBase


    properties
        SystemObject='';
    end

    methods

        function obj=SystemObjectBased(interfaceID)


            obj=obj@hdlturnkey.swinterface.SoftwareInterfaceBase(interfaceID);
        end

    end



    methods
        function generateModelDriver(~,~)
        end
    end

end