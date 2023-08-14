



classdef StructureStorageClassConstraint<slci.compatibility.Constraint

    methods

        function obj=StructureStorageClassConstraint()
            obj.setEnum('StructureStorageClass');
            obj.setFatal(false);
            obj.setCompileNeeded(false);
        end


        function out=getDescription(aObj)%#ok
            out='Model must not have Structure Storage Classes.';
        end


        function out=check(aObj)
            out=[];
            hasStructureSC=hasGroupedArg(aObj);
            if hasStructureSC
                out=slci.compatibility.Incompatibility(...
                aObj,...
'StructureStorageClass'...
                );
            end
        end
    end


    methods(Access=private)

        function status=hasGroupedArg(aObj)
            dictBD=aObj.ParentModel().getParam('DictionarySystem');
            args=dictBD.Interface.Parameter.toArray;
            status=false;
            for i=1:numel(args)
                prm=args(i);
                if prm.Hierarchical
                    status=true;
                    break;
                end
            end
        end
    end

end