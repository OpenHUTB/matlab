


classdef MisraXorConstraint<slci.compatibility.Constraint


    methods(Access=protected)

        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'MisraXor',...
            aObj.ParentBlock().getName());
        end

    end

    methods


        function out=getDescription(aObj)%#ok
            out='Xor operator of boolean operands is incompatible with CastingMode Standards';
        end


        function obj=MisraXorConstraint()
            obj.setEnum('MisraXor');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end






        function out=check(aObj)
            out=[];

            casting_mode=...
            get_param(aObj.ParentModel.getName(),'CastingMode');

            if strcmpi(casting_mode,'Standards')
                parent_blk=aObj.ParentBlock();
                compiledPortDataTypes=parent_blk.getParam('CompiledPortDataTypes');
                if isempty(compiledPortDataTypes)
                    numIn=0;
                else
                    numIn=numel(compiledPortDataTypes.Inport);
                end
                if numIn>1
                    for i=1:numIn
                        signalDataType=compiledPortDataTypes.Inport(1);
                        if~strcmpi(signalDataType,'boolean')
                            out=aObj.getIncompatibility();
                            return
                        end
                    end
                end
            end
        end
    end
end
