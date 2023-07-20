classdef InterfaceNotOnPathMessage<hdlturnkey.interface.InterfaceBase


    properties
        message=[];
    end

    methods
        function obj=InterfaceNotOnPathMessage(id,msg)
            obj=obj@hdlturnkey.interface.InterfaceBase(id);
            obj.message=msg;
        end

        function validatePortForInterface(obj,~,~)
            error(obj.message);
        end


        function elaborate(~,~,~)

        end
    end

end

