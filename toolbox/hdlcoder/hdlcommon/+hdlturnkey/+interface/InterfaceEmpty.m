


classdef InterfaceEmpty<hdlturnkey.interface.InterfaceBase


    properties


    end

    methods

        function obj=InterfaceEmpty(interfaceID)

            obj=obj@hdlturnkey.interface.InterfaceBase(interfaceID);

        end

        function isa=isEmptyInterface(obj)%#ok<MANU>
            isa=true;
        end

        function validatePortForInterfaceShared(obj,~,~,~)

        end

    end



    methods
        function elaborate(~,~,~)

        end
    end

end