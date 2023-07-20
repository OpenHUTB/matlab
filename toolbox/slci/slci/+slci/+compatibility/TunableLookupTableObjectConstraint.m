



classdef TunableLookupTableObjectConstraint<slci.compatibility.Constraint

    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'TunableLookupTableObject',...
            aObj.ParentBlock().getName());
        end

    end

    methods

        function obj=TunableLookupTableObjectConstraint()
            obj.setEnum('TunableLookupTableObject');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            thisBlock=aObj.ParentBlock;
            assert(isa(thisBlock,'slci.simulink.Lookup_n_DBlock'));
            aBlk=thisBlock.getParam('Object');
            if slci.internal.hasTunableLUTObject(aBlk)&&...
                ~slcifeature('VLUTObject')
                out=aObj.getIncompatibility();
            end
        end
    end
end
