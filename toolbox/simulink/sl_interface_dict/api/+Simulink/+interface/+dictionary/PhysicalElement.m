classdef(Hidden)PhysicalElement<Simulink.interface.dictionary.InterfaceElement&matlab.mixin.CustomDisplay




    properties(Dependent=true)
Type
    end

    methods(Hidden,Access=protected)
        function propgrp=getPropertyGroups(~)

            proplist={'Name','Type'};
            propgrp=matlab.mixin.util.PropertyGroup(proplist);
        end
    end

    methods(Hidden)
        function this=PhysicalElement(zcImpl,dictImpl,interface)
            this@Simulink.interface.dictionary.InterfaceElement(zcImpl,dictImpl,interface);
        end
    end

    methods

        function domainName=get.Type(this)
            domainName='';
            domainType=this.getZCWrapper().Type;
            if~isempty(domainType)
                domainName=domainType.Domain;
            end
        end

        function set.Type(this,domainName)
            this.getZCWrapper().Type=domainName;
        end
    end

end
