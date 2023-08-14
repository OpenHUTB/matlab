classdef MultirateStage








    methods(Abstract)
        s=str(obj);
        b=isTrivial(obj);
    end

    methods
        function obj=MultirateStage()
        end

        function disp(obj)
            disp(str(obj))
        end

        function b=isFilter(obj)
            b=isa(obj,'dsp.internal.MultirateAnalysis.FilterChain');
        end

        function b=isUpDown(obj)
            b=isa(obj,'dsp.internal.MultirateAnalysis.UpDownStage');
        end

        function b=isUp(obj)
            b=isUpDown(obj)&&obj.n>0;
        end

        function b=isDown(obj)
            b=isUpDown(obj)&&obj.n<0;
        end

    end
end