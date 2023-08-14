






classdef VirtualBlockOutportResolvedSignalConstraint<slci.compatibility.Constraint
    methods

        function out=getDescription(aObj)%#ok
            out='Virtual blocks cannot have resolved signal as its outport';
        end


        function obj=VirtualBlockOutportResolvedSignalConstraint(varargin)
            obj.setEnum('VirtualBlockOutportResolvedSignal');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            out=[];

            if strcmpi(aObj.ParentBlock().getParam('Virtual'),'on')

                blkObj=aObj.ParentBlock().getParam('Object');

                blkRTWName=slci.internal.getRTWName(blkObj);


                outports=blkObj.PortHandles.Outport;
                if~isempty(outports)
                    for i=1:numel(outports)
                        signalLine=get_param(outports(i),'Line');
                        if signalLine==-1
                            signalObj=[];
                        else
                            signalObj=get_param(signalLine,'Object');
                        end
                        if~isempty(signalObj)&&signalObj.isSignalLabelResolved

                            if~strcmpi(blkObj.Name,signalObj.Name)
                                out=slci.compatibility.Incompatibility(...
                                aObj,...
                                aObj.getEnum(),...
                                blkRTWName);
                            end
                        end
                    end
                end
            end
        end
    end
end
