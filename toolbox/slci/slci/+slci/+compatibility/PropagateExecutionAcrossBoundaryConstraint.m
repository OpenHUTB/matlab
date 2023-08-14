


classdef PropagateExecutionAcrossBoundaryConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='Propagate exection accrpss boundary should be turned off.';
        end

        function obj=PropagateExecutionAcrossBoundaryConstraint(varargin)
            obj.setEnum('PropagateExecutionAcrossBoundary');
            obj.setCompileNeeded(1);
            obj.setFatal(0);
        end

        function out=check(aObj)
            out=[];

            blkSID=aObj.getSID();

            obj=get_param(blkSID,'Object');
            ssType=slci.internal.getSubsystemType(obj);


            if strcmpi(ssType,'Enable')||...
                strcmpi(ssType,'Function-call')||...
                strcmpi(ssType,'Trigger')||...
                strcmpi(ssType,'Action')

                propExec=get_param(blkSID,...
                'PropExecContextOutsideSubsystem');

                if strcmpi(propExec,'on')...
                    &&aObj.directlyConnectedInputOutput()
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'PropagateExecutionAcrossBoundary',...
                    aObj.ParentBlock().getName());
                end
            end
        end

        function out=directlyConnectedInputOutput(aObj)
            out=false;
            blkH=get_param(aObj.getSID(),'Handle');
            outBlks=find_system(blkH,'SearchDepth',1,'BlockType','Outport');
            inPorts=find_system(blkH,'SearchDepth',1,'BlockType','Inport');
            for i=1:numel(outBlks)
                if directlyInputConnected(outBlks(i),inPorts)
                    out=true;
                    return;
                end
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=...
            getSpecificMAStrings(aObj,status,varargin)%#ok
            RecAction=DAStudio.message(...
            'Slci:compatibility:PropagateExecutionAcrossBoundaryConstraintRecAction');
            SubTitle=DAStudio.message(...
            'Slci:compatibility:PropagateExecutionAcrossBoundaryConstraintSubTitle');
            Information=DAStudio.message(...
            'Slci:compatibility:PropagateExecutionAcrossBoundaryConstraintInfo');
            if status
                StatusText=DAStudio.message(...
                'Slci:compatibility:PropagateExecutionAcrossBoundaryConstraintPass');
            else
                StatusText=DAStudio.message(...
                'Slci:compatibility:PropagateExecutionAcrossBoundaryConstraintWarn');
            end
        end

    end
end

function out=directlyInputConnected(outH,inPorts)
    out=false;
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    uddobj=get_param(outH,'UDDObject');
    srcBlk=uddobj.getActualSrc;
    for i=1:size(srcBlk,1)
        currSrc=srcBlk(i,1);
        parentBlk=get_param(currSrc,'ParentHandle');

        parentBlkType=get_param(parentBlk,'BlockType');


        if strcmpi(parentBlkType,'Inport')&&any(inPorts==parentBlk)
            out=true;
        end
    end
end
