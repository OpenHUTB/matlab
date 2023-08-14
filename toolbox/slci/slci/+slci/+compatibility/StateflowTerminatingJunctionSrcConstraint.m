

classdef StateflowTerminatingJunctionSrcConstraint<slci.compatibility.Constraint

    properties(Access=private)
        visitedTransitionIds=[];
    end

    methods(Access=private)
        function out=isVisitedTransition(aObj,aTransitionId)
            out=any(aObj.visitedTransitionIds==aTransitionId);
        end

        function out=isTransitionSrcState(aObj,aSfObjUDD)
            if isa(aSfObjUDD,'Stateflow.State')
                out=true;
            else
                transUDDH=slci.internal.getSFActiveObjs(...
                aSfObjUDD.sinkedTransitions);
                if isempty(transUDDH)
                    out=false;
                else

                    out=aObj.CheckIncomingTransitionSrc(transUDDH);
                end
            end
        end

        function out=CheckIncomingTransitionSrc(aObj,aTransitionUDD)
            out=false;
            for i=1:numel(aTransitionUDD)
                if~aObj.isVisitedTransition(aTransitionUDD(i).Id)
                    aObj.visitedTransitionIds=[aObj.visitedTransitionIds,aTransitionUDD(i).Id];
                    if~isempty(aTransitionUDD(i).source)
                        out=aObj.isTransitionSrcState(aTransitionUDD(i).source);
                        if out
                            break;
                        end
                    end
                end
            end
        end

        function out=isJunctionSourceState(aObj,aJunction)


            out=false;
            junctionUDDH=idToHandle(sfroot,aJunction.getSfId());
            incoming=slci.internal.getSFActiveObjs(...
            junctionUDDH.sinkedTransitions);
            for transUDDH=incoming(:)'
                out=aObj.CheckIncomingTransitionSrc(transUDDH);
                if out
                    break;
                end
            end
        end
    end

    methods

        function out=getDescription(aObj)%#ok
            out='A terminating junction should not trace back to a state.';
        end

        function obj=StateflowTerminatingJunctionSrcConstraint
            obj.setEnum('StateflowTerminatingJunctionSrc');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            junction=aObj.ParentJunction();




            if isempty(junction.getOutgoingTransitions())&&...
                aObj.isJunctionSourceState(junction)&&~aObj.ParentJunction().getExitOrEntryPort()
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'StateflowTerminatingJunctionSrc',...
                aObj.ParentBlock().getName());
                return;
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

    end
end
