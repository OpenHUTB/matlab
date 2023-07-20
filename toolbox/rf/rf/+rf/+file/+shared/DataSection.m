classdef DataSection<handle



    properties(SetAccess=protected)
SmallSignal
Noise
    end

    methods
        function obj=DataSection(newSmallSignal,newNoise)
            narginchk(2,2)
            obj.SmallSignal=newSmallSignal;
            obj.Noise=newNoise;
        end
    end

    methods
        function set.SmallSignal(obj,newSmallSignal)
            obj.validatesmallsignalobj(newSmallSignal)
            obj.SmallSignal=newSmallSignal;
        end

        function set.Noise(obj,newNoise)
            if~isa(newNoise,obj.getvalidnoiseclass)||(numel(newNoise)>1)
                error(message('rf:rffile:shared:BadInputArg','Noise',class(obj),obj.getvalidnoiseclass))
            end
            obj.Noise=newNoise;
        end
    end

    methods(Abstract)
        out=convertto3ddata(obj);
    end

    methods
        function out=smallsignalfreqsinhz(obj)
            funit=obj.SmallSignal.FrequencyUnit;
            fdata=obj.SmallSignal.Data(:,1);
            out=rf.file.shared.getfreqinhz(funit,fdata);
        end
    end

    methods(Static,Abstract,Access=protected,Hidden)
        validatesmallsignalobj(newSmallSignal)
        out=getvalidnoiseclass;
    end

    methods
        function out=hasnoise(obj)
            out=~isempty(obj.Noise);
        end
    end
end