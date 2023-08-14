classdef Customizer<Simulink.Customizer





    methods(Access=private)
        function this=Customizer()
        end
        function delete(this)%#ok<INUSD>
        end
    end

    methods(Access=public,Static,Hidden)
        function this=getInstance()
            persistent localStaticObj;
            if isempty(localStaticObj)
                localStaticObj=slreq.custom.Customizer();
            end
            this=localStaticObj;
        end
    end

    methods(Access=public,Hidden)
        function clear(~)
            slreq.custom.BaseCustomizer.getInstance.clear;
        end
    end

    methods
        function addCustomLinkType(~,typeName,superTypeName,forwardName,backwardName,description)%#ok<INUSL>
            slreq.custom.BaseCustomizer.getInstance.addCustomLinkType(typeName,superTypeName,forwardName,backwardName,description);
        end


        function addCustomRequirementType(~,name,superTypeName,description)%#ok<INUSL>
            slreq.custom.BaseCustomizer.getInstance.addCustomRequirementType(name,superTypeName,description);
        end
    end
end
