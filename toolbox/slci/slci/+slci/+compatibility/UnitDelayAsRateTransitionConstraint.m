


classdef UnitDelayAsRateTransitionConstraint<slci.compatibility.Constraint

    methods(Access=private)

        function out=isRateTransition(~,iSampleTime,oSampleTime)
            out=false;
            isInportAndOutportDiscrete=iSampleTime.isDiscrete()...
            &&oSampleTime.isDiscrete();


            if isInportAndOutportDiscrete&&...
                ((iSampleTime.getPeriod()~=oSampleTime.getPeriod())||...
                (iSampleTime.getOffset()~=oSampleTime.getOffset()))
                out=true;
            end
        end
    end

    methods

        function obj=UnitDelayAsRateTransitionConstraint()
            obj=obj@slci.compatibility.Constraint();
            obj.setEnum('UnitDelayAsRateTransition');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=getDescription(aObj)%#ok
            out='Unit delay blocks that are used in place of rate transition blocks are not supported.';
        end


        function out=check(aObj)
            out=[];
            ph=aObj.ParentBlock().getParam('PortHandles');
            inportH=ph.Inport;
            outportH=ph.Outport;
            inportSampleTime=get_param(inportH,'CompiledSampleTime');
            outportSampleTime=get_param(outportH,'CompiledSampleTime');
            assert(~iscell(outportSampleTime));


            s={};
            if iscell(inportSampleTime)
                for i=1:numel(inportSampleTime)
                    ts=slci.internal.SampleTime(inportSampleTime{i});
                    if ts.isDiscrete()
                        s(end+1)=inportSampleTime(i);%#ok
                    end
                end
                if isempty(s)


                    return;
                end
            else
                s={inportSampleTime};
            end



            oSampleTime=slci.internal.SampleTime(outportSampleTime);
            for i=1:numel(s)
                iSampleTime=slci.internal.SampleTime(s{i});
                if aObj.isRateTransition(iSampleTime,oSampleTime)
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'UnitDelayAsRateTransition');
                    return;
                end
            end

        end

    end
end
