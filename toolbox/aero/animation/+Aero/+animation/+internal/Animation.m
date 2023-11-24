classdef(CompatibleInexactProperties=true,Abstract)Animation...
    <matlab.mixin.SetGet&matlab.mixin.Copyable
    properties(SetAccess=protected,Transient,SetObservable,Hidden)
        AnimationTimer=[];
    end

    properties(Transient,SetObservable)
        TimeScaling{validateattributes(TimeScaling,{'numeric'},{'scalar'},'','TimeScaling')}=1;
        FramesPerSecond{validateattributes(FramesPerSecond,{'numeric'},{'scalar','nonnegative',...
        'nonzero','finite'},'','FramesPerSecond')}=12;
        TStart{validateattributes(TStart,{'numeric'},{'scalar'},'','TStart')}=NaN;
        TFinal{validateattributes(TFinal,{'numeric'},{'scalar'},'','TFinal')}=NaN;
    end

    methods
        function wait(obj)
            if isa(obj.AnimationTimer,"timer")&&isvalid(obj.AnimationTimer)


                try wait(obj.AnimationTimer)%#ok<TRYNC> 
                end
            end
        end
    end

    methods(Abstract)
play
    end

    methods
        function set.TimeScaling(obj,val)



            if isfinite(val)&&(val>0)
                data=val;
            else
                warning(message('aero:Animation:invalidTimeScaling'));
                data=1;
            end

            obj.TimeScaling=data;
        end
    end

    methods(Hidden)
        function validateStartTimeLessThanFinalTime(h)

            if(h.TStart>h.TFinal)
                error(message('aero:Animation:noInvertedTime'));
            end
        end



        function validateTimeBounds(h,minStart,maxFinal)
            if(h.TStart<minStart)
                error(message('aero:Animation:startTimeBeforeData'));
            end


            if(h.TFinal>maxFinal)
                error(message('aero:Animation:finalTimeAfterData'));
            end
        end
    end
end