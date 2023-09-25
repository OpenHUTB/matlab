classdef UnitRadarDelay<...
        matlabshared.tracking.internal.SimulinkBusUtilities
    %#codegen

    properties(Nontunable)
        NumUnitDelay(1,1){mustBeNonnegative,mustBeReal,mustBeFinite,mustBeInteger}=1
    end

    properties(Constant,Access=protected)
        pBusPrefix='BusUnitDelay';
    end

    properties(Access=private)
        pLastVal
        pCntSteps
        pLastTime=0
    end

    methods(Access=protected)

        function y=sendToBus(~,x,varargin)
            y=x;
        end


        function[out,argsToBus]=defaultOutput(obj)
            out=struct.empty();
            argsToBus={};

            busIn=propagatedInputBus(obj,1);
            if isempty(busIn)
                return
            end

            st=obj.bus2struct(busIn);

            obj.pLastVal=st;

            out=st;
        end
    end


    methods(Access=private)
        function y=push(obj,x)
            if obj.NumUnitDelay>0
                y=obj.pLastVal(end);
                for m=obj.NumUnitDelay:-1:2
                    obj.pLastVal(m)=obj.pLastVal(m-1);
                end
                obj.pLastVal(1)=x;
            else
                y=x;
            end
        end
    end

    methods(Access=protected)
        function y=stepImpl(obj,x)
            y=push(obj,x);

            sts=getSampleTime(obj);
            currTime=obj.pLastTime+cast(sts.SampleTime,'like',obj.pLastTime);
            for m=1:y.NumDetections
                y.Detections(m).Time(:)=currTime;
            end

            cnt=obj.pCntSteps;
            if cnt<obj.NumUnitDelay

                y.NumDetections(:)=0;
                y.IsValidTime(:)=0;
            end
            cnt=cnt+1;
            obj.pCntSteps=cnt;

            obj.pLastTime=currTime;
        end


        function setupImpl(obj,x)
            if obj.NumUnitDelay>0
                obj.pLastVal=repmat(nullify(x),obj.NumUnitDelay,1);
            end
        end

        function resetImpl(obj)

            obj.pCntSteps=0;
            sts=getSampleTime(obj);
            obj.pLastTime=cast(-sts.SampleTime,'like',obj.pLastTime);
        end

        function loadObjectImpl(obj,s,wasLocked)
            if wasLocked
                obj.pLastVal=s.pLastVal;
                obj.pCntSteps=s.pCntSteps;
                obj.pLastTime=s.pLastTime;
            end

            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end


        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.System(obj);

            if isLocked(obj)
                s.pLastVal=obj.pLastVal;
                s.pCntSteps=obj.pCntSteps;
                s.pLastTime=obj.pLastTime;
            end
        end


        function icon=getIconImpl(obj)
            icon=sprintf('Delay %i\nunit steps',obj.NumUnitDelay);
        end
    end


    methods(Static,Access=protected)
    end


    methods(Static,Access=protected)

        function out=isOutputFixedSizeImpl(~)
            out=true;
        end

        function sz=getOutputSizeImpl(~)
            sz=[1,1];
        end

        function cp=isOutputComplexImpl(~)
            cp=false;
        end


        function header=getHeaderImpl

            header=matlab.system.display.Header(mfilename("class"));
            header.Text=sprintf(['This class is for internal use and may be removed or modified in the future.\n',...
                '\n',...
                'Delay the detections on the input by the specified number of unit delays. The time ',...
                'stamps of the delayed output are updated to the current simulation time.\n',...
                '\n',...
                'This is an internal class, no error checking is performed']);
        end

        function group=getPropertyGroupsImpl
            group=matlab.system.display.Section(mfilename("class"));
        end
    end
end


function out=nullify(in)
    out=in;
    flds=fieldnames(in);
    for m=1:numel(flds)
        thisFld=flds{m};
        for n=1:numel(in)
            thisVal=in(n).(thisFld);
            if isstruct(thisVal)
                nullVal=nullify(thisVal);
            else
                if isenum(thisVal)
                    nullVal=thisVal;
                else
                    nullVal=zeros(size(thisVal),'like',thisVal);
                end
            end
            out(n).(thisFld)=nullVal;
        end
    end
end
