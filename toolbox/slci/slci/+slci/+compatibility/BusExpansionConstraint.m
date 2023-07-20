



classdef BusExpansionConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Nonvirtual blocks may not operate on a virtual bus';
        end

        function obj=BusExpansionConstraint()
            obj.setEnum('BusExpansion');
            obj.setCompileNeeded(1);
            obj.addPreRequisiteConstraint(...
            slci.compatibility.StrictBusMsgConstraint);
        end

        function out=check(aObj)
            out=[];
            allBlocks=aObj.ParentModel().getBlocks();
            blksWithViolations={};
            blksWithViolationsStr='';
            for idx=1:numel(allBlocks)
                blockObj=allBlocks{idx};
                blkHdl=blockObj.getParam('Handle');
                expSS=slInternal('busDiagnostics','handleToExpandedSubsystem',blkHdl);

                if isempty(expSS)
                    continue
                end


                if strcmp(blockObj.getParam('BlockType'),'BusAssignment')
                    ph=blockObj.getParam('PortHandles');
                    if strcmpi(get_param(ph.Inport(1),'CompiledBusType'),'VIRTUAL_BUS')
                        continue
                    end
                end


                if slcifeature('VirtualBusSupport')==1&&...
                    ~isa(blockObj,'slci.simulink.MergeBlock')
                    continue;
                else
                    blksWithViolations{end+1}=blockObj.getSID;%#ok
                    if~isempty(blksWithViolationsStr)
                        blksWithViolationsStr=[blksWithViolationsStr,', '];%#ok
                    end
                    blksWithViolationsStr=...
                    [blksWithViolationsStr...
                    ,slci.compatibility.getFullBlockName(blockObj.getParam('Handle'))];%#ok
                end
            end
            if~isempty(blksWithViolations)
                out=[out,slci.compatibility.Incompatibility(...
                aObj,...
                'BusExpansion',...
                blksWithViolationsStr)];
                out.setObjectsInvolved(blksWithViolations);
            end
        end

    end
end


