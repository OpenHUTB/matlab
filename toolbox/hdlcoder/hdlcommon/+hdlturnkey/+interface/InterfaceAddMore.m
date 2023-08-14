


classdef InterfaceAddMore<hdlturnkey.interface.InterfaceBase


    properties(Constant)
        DefaultInterfaceID='Add more...';
    end

    properties

    end

    methods

        function obj=InterfaceAddMore(interfaceID)

            obj=obj@hdlturnkey.interface.InterfaceBase(interfaceID);

        end

        function isa=isInterfaceAddMore(obj)%#ok<MANU>
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
