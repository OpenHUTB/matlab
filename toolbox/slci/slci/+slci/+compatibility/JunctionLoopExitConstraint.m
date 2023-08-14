



classdef JunctionLoopExitConstraint<slci.compatibility.Constraint
    methods

        function out=getDescription(aObj)%#ok
            out=['Check junction outgoing transition , if junction '...
            ,' is within a loop cycle, outgoing junction cannot '...
            ,' be outside the loop cycle'];
        end


        function obj=JunctionLoopExitConstraint
            obj.setEnum('JunctionLoopExit');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];

            owner=aObj.getOwner;
            assert(isa(owner,'slci.stateflow.Junction'));
            if owner.isLoopHeader()...
                ||aObj.getOwner().isSupportedLoop()

                return;
            end

            chart=owner.ParentChart;
            if chart.hasCycles()
                cycles=chart.getCycles();
                cycle=aObj.getCycleWithId(cycles,owner.getSfId);
                if~isempty(cycle)

                    outgoing=owner.getOutgoingTransitions;
                    for i=1:numel(outgoing)
                        if(outgoing(i).IsTrivial()...
                            &&(numel(outgoing)==1))
                            continue;
                        else
                            dstJnId=outgoing(i).getDstId();
                            insideLoop=aObj.isNodeInsideLoop(cycles,dstJnId);
                            if~insideLoop
                                out=slci.compatibility.Incompatibility(...
                                aObj,...
                                aObj.getEnum(),...
                                aObj.ParentBlock().getName(),...
                                owner.getClassNames());
                            end
                        end
                    end
                end
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=...
            getSpecificMAStrings(aObj,status,varargin)
            if status
                status='Pass';
            else
                status='Warn';
            end
            enum=aObj.getEnum();
            classnames=aObj.getOwner.getClassNames;
            Information=DAStudio.message(...
            ['Slci:compatibility:',enum,'ConstraintInfo']);
            SubTitle=DAStudio.message(...
            ['Slci:compatibility:',enum,'ConstraintSubTitle']);
            RecAction=DAStudio.message(...
            ['Slci:compatibility:',enum,'ConstraintRecAction'],classnames);
            StatusText=DAStudio.message(...
            ['Slci:compatibility:',enum,'Constraint',status],classnames);
        end

    end

    methods(Access=private)

        function out=getCycleWithId(~,cycles,id)
            out={};
            for i=1:numel(cycles)
                cycle=cycles{i};
                for j=1:numel(cycle)
                    node_id=str2double(cycle{j});
                    if node_id==id
                        out{end+1}=cycle;%#ok
                    end
                end
            end
        end


        function out=isNodeInsideLoop(~,cycles,id)
            out=false;
            for i=1:numel(cycles)
                cycle=cycles{i};
                for j=1:numel(cycle)
                    node_id=str2double(cycle{j});
                    if node_id==id
                        out=true;
                        return;
                    end
                end
            end
        end
    end
end