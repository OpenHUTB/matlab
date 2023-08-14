


classdef AcyclicControlFlowConstraint<slci.compatibility.Constraint

    methods(Access=private)


        function out=checkWithoutSfLoopSupport(aObj)
            out=[];
            cfgs=aObj.getOwner.NonEmptyCfgs();
            for cfgIdx=1:numel(cfgs)
                cfg=cfgs{cfgIdx};
                if~isempty(cfg)
                    junctions=cfg.getJunctions();
                    for i=1:numel(junctions)
                        cfg.SetFlags(0);
                        cyclic=aObj.TraverseFlow(junctions(i),junctions(i));
                        if cyclic
                            cfg.SetFlags(0);
                            out=slci.compatibility.Incompatibility(...
                            aObj,...
                            'AcyclicControlFlow',...
                            aObj.ParentBlock().getName(),...
                            aObj.getOwner().getClassNames());
                            return;
                        end
                        clear junctionMap;
                    end
                    cfg.SetFlags(0);
                end
            end
        end


        function out=checkWithSfLoopSupport(aObj)
            out=[];


            cyclic=aObj.getOwner().isJunctionStartOfCycle();
            if cyclic
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'AcyclicControlFlow',...
                aObj.ParentBlock().getName(),...
                aObj.getOwner().getClassNames());
                return;
            end
        end
    end

    methods

        function out=getDescription(aObj)%#ok
            out='Control flow cycles are not supported';
        end


        function obj=AcyclicControlFlowConstraint
            obj.setEnum('AcyclicControlFlow');
            obj.setCompileNeeded(0);
            if(slcifeature('SfLoopSupport')==0)
                obj.setFatal(true);
            else
                obj.setFatal(false);
            end
        end



        function cyclic=TraverseFlow(aObj,aStartingJunction,aJunction)
            cyclic=false;
            if aJunction.getFlag()==1
                if aJunction==aStartingJunction
                    cyclic=true;
                    return
                end
            else
                aJunction.setFlag(1);
                outgoingTransitions=aJunction.getOutgoingTransitions();
                for i=1:numel(outgoingTransitions)
                    transition=outgoingTransitions(i);
                    dstJunction=transition.getDst();
                    if~isempty(dstJunction)
                        cyclic=aObj.TraverseFlow(aStartingJunction,...
                        dstJunction);
                    end
                    if cyclic
                        return
                    end
                end
            end
        end


        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            if status
                status='Pass';
            else
                status='Warn';
            end
            enum=aObj.getEnum();
            classnames=aObj.getOwner.getClassNames;
            Information=DAStudio.message(['Slci:compatibility:',enum,'ConstraintInfo']);
            SubTitle=DAStudio.message(['Slci:compatibility:',enum,'ConstraintSubTitle']);
            RecAction=DAStudio.message(['Slci:compatibility:',enum,'ConstraintRecAction'],classnames);
            StatusText=DAStudio.message(['Slci:compatibility:',enum,'Constraint',status],classnames);
        end


        function out=check(aObj)
            out=[];%#ok
            if(slcifeature('SfLoopSupport')==0)
                out=aObj.checkWithoutSfLoopSupport();
            else
                out=aObj.checkWithSfLoopSupport();
            end
        end

    end
end
