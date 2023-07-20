


classdef MergeSrcPortConstraint<slci.compatibility.Constraint









    methods

        function out=getDescription(aObj)%#ok

            out='The sources of a Merge block should not output a virtual bus';
        end

        function obj=MergeSrcPortConstraint()

            obj.setEnum('MergeSrcPort');
            obj.setCompileNeeded(1);
            obj.setFatal(true);
        end

        function out=check(aObj)

            out=[];

            if slcifeature('VirtualBusSupport')==0
                return;
            end

            if aObj.isSrcPortVirtualBusType
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum(),...
                aObj.ParentBlock().getName());
            end
        end

    end
    methods(Access=private)


        function out=isSrcPortVirtualBusType(aObj)
            out=false;


            pH=aObj.ParentBlock().getParam('PortHandles');

            for pIdx=1:numel(pH.Inport)

                pObj=get_param(pH.Inport(pIdx),'Object');
                pSrc=pObj.getCondSrc;
                for srcIdx=1:size(pSrc,1)
                    srcPortObj=pSrc(srcIdx,1);
                    compiledBusType=get_param(srcPortObj,'CompiledBusType');
                    if(strcmp(compiledBusType,'VIRTUAL_BUS'))
                        out=true;
                        return;
                    end
                end
            end
        end

    end
end
