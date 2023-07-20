




classdef UniqueGraphicalFunctionNameConstraint<slci.compatibility.Constraint

    methods
        function out=getDescription(aObj)%#ok
            out='Non-inlined Graphical Functions must have a unique function name.';
        end

        function obj=UniqueGraphicalFunctionNameConstraint
            obj.setEnum('UniqueGraphicalFunctionName');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];



            if(aObj.getOwner().isInlined())
                return;
            end


            graphicalFunctionName=aObj.getOwner().getName();

            modelObj=aObj.ParentModel().getUDDObject();




            graphicalFunction=modelObj.find('-isa','Stateflow.Function',...
            'Name',graphicalFunctionName);
            if numel(graphicalFunction)>1
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'UniqueGraphicalFunctionName',...
                aObj.ParentBlock().getName());
                return;
            end
        end

    end
end

