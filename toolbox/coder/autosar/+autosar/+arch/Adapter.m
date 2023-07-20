classdef(Hidden,Sealed)Adapter<autosar.arch.ArchElement&matlab.mixin.CustomDisplay




    properties(Dependent=true,SetAccess=private)
Ports
    end

    methods(Hidden,Access=protected)
        function propgrp=getPropertyGroups(~)

            proplist={'Name','SimulinkHandle','Parent','Ports'};
            propgrp=matlab.mixin.util.PropertyGroup(proplist);
        end
    end

    methods(Hidden,Static)
        function this=create(slHandle)

            this=autosar.arch.Adapter(slHandle);
        end
    end

    methods(Hidden,Access=private)
        function this=Adapter(comp)
            this@autosar.arch.ArchElement(comp);
        end
    end

    methods
        function ports=get.Ports(this)
            this.checkValidSimulinkHandle();
            sysH=autosar.arch.Finder.find(this.SimulinkHandle,'Port');
            ports=autosar.arch.CompPort.empty();
            if~isempty(sysH)
                ports=arrayfun(@(x)autosar.arch.CompPort.create(x),sysH);
            end
        end
    end

    methods(Access=protected)
        function name=getName(this)

            name=this.getNameDefaultImpl();
        end

        function setName(this,newName)

            this.setNameDefaultImpl(newName);
        end

        function p=getParent(this)

            p=this.getParentDefaultImpl();
        end

        function destroyImpl(this)

            this.destroyDefaultImpl();
        end
    end
end
