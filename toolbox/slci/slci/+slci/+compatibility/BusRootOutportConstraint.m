



classdef BusRootOutportConstraint<slci.compatibility.Constraint

    methods

        function obj=BusRootOutportConstraint()
            obj.setEnum('BusRootOutport');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
            obj.addPreRequisiteConstraint(...
            slci.compatibility.StrictBusMsgConstraint);
        end

        function out=getDescription(aObj)%#ok
            out='A root outport must select its parameter ''BusOutputAsStruct''';
        end

        function out=check(aObj)
            out=[];


            if slcifeature('VirtualBusSupport')==1

                return;
            end
            mdlHdl=get_param(aObj.ParentModel().getHandle(),'Handle');
            outBlks=find_system(mdlHdl,'SearchDepth',1,'BlockType','Outport');
            set=slci.compatibility.UniqueBlockSet;
            for i=1:numel(outBlks)
                outBlk=outBlks(i);
                ph=get_param(outBlk,'PortHandles');
                outputAsStruct=get_param(outBlk,'BusOutputAsStruct');
                if~strcmpi(get_param(ph.Inport(1),'CompiledBusType'),'NOT_BUS')&&...
                    strcmpi(outputAsStruct,'off')
                    set.AddBlock(outBlk);
                end
            end

            if set.GetLength()>0
                out=[out,slci.compatibility.Incompatibility(...
                aObj,...
                'BusRootOutport',...
                set.GetBlockStr())];
                out.setObjectsInvolved(set.GetBlockCell());
            end
        end


        function out=hasAutoFix(~)
            out=true;
        end

        function out=fix(~,blk)
            out=false;
            try
                set_param(blk,'BusOutputAsStruct','on');
                out=true;
            catch
            end
        end

    end
end
