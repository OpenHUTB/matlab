classdef(Hidden)ValueDomain






    properties(SetAccess=immutable)



DataTypeStr
    end

    properties(Hidden,SetAccess=immutable)



IsBuiltIn
    end

    properties(Dependent)



Intervals
    end

    properties(Access=?matlab.unittest.TestCase)

TypedEnds
    end

    properties


        ExcludeDenormals(1,1)logical


        ExcludeNegativeZero(1,1)logical
    end

    properties(Hidden,Dependent,SetAccess=private)

EffectiveIntervals
    end

    methods

        function obj=ValueDomain(dataTypeArg,varargin)












            try
                nt=fixed.internal.type.extractNumericType(dataTypeArg);
                dtName=tostringInternalSlName(nt);
            catch ME
                throw(ME);
            end
            assert(~isscalingunspecified(nt),...
            message("fixed:valuedomain:expectedSpecifiedScaling"));
            p=inputParser;
            addParameter(p,'PreferBuiltIn',true,...
            @(x)validateattributes(x,{'logical','numeric'},{'scalar'}));
            addParameter(p,'Intervals',fixed.Interval(nt));
            addParameter(p,'ExcludeDenormals',false);
            addParameter(p,'ExcludeNegativeZero',false);
            parse(p,varargin{:});
            r=p.Results;


            obj.DataTypeStr=dtName;
            obj.IsBuiltIn=fixed.internal.type.isEquivalentToBuiltin(nt)...
            &&(isboolean(nt)||ishalf(nt)||r.PreferBuiltIn);
            obj.Intervals=r.Intervals;
            obj.ExcludeDenormals=r.ExcludeDenormals;
            obj.ExcludeNegativeZero=r.ExcludeNegativeZero;
        end


        function obj=set.Intervals(obj,val)
            if~isa(val,'fixed.Interval')
                val=fixed.Interval(val);
            end



            obj.TypedEnds=quantize(val,obj.DataTypeStr,...
            'PreferBuiltIn',obj.IsBuiltIn);
        end

        function val=get.Intervals(obj)
            val=fixed.Interval(obj.TypedEnds(:,1),obj.TypedEnds(:,2));
        end

        function val=get.EffectiveIntervals(obj)
            I=obj.Intervals;
            if fixed.internal.type.isAnyFloat(obj.DataTypeStr)
                if obj.ExcludeDenormals
                    I=setdiff(I,fixed.Interval.denormal(obj.DataTypeStr));
                end
            end
            val=I(:);
        end


        function bool=contains(obj,val)










            validateattributes(obj,{'fixed.ValueDomain'},{'scalar'},1);
            validateattributes(val,{'numeric','logical','embedded.fi'},{'real','nonempty'},2);


            bool=arrayfun(@(x)any(contains(obj.EffectiveIntervals,x)),val);


            isFinite=~(isnan(val)|isinf(val));
            if fixed.internal.type.isAnyHalf(val)
                val=single(val);
            end
            finiteValAfterCast=fixed.internal.utility.cast(val(isFinite),...
            numerictype(obj.DataTypeStr),obj.IsBuiltIn);
            if strcmp(obj.DataTypeStr,'half')
                isPrecise=single(finiteValAfterCast)==val(isFinite);
            else
                isPrecise=finiteValAfterCast==val(isFinite);
            end
            bool(isFinite)=bool(isFinite)&isPrecise;


            isNegZero=fixed.internal.utility.isnegzero(val);
            isNegZeroAllowed=fixed.internal.type.isAnyFloat(obj.DataTypeStr)&&~obj.ExcludeNegativeZero;
            bool(isNegZero)=bool(isNegZero)&isNegZeroAllowed;
        end
    end

    methods(Static,Hidden)
        function props=matlabCodegenNontunableProperties(~)



            props={'DataTypeStr','IsBuiltIn','TypedEnds',...
            'ExcludeDenormals','ExcludeNegativeZero'};
        end
    end
end
