classdef(CompatibleInexactProperties=true)TimeSeries...
    <matlab.mixin.SetGet&matlab.mixin.Copyable




    properties(Transient,SetObservable)
        TimeSeriesSource=[];
        TimeSeriesSourceType(1,1)Aero.animation.internal.TimeSeriesSourceType='Array6DoF';
        TimeSeriesReadFcn{mustBeA(TimeSeriesReadFcn,["char","string","function_handle"])}=@()x;
    end

    methods
        function set.TimeSeriesSource(h,value)
            if istimetable(value)

                value=sortrows(value);
            end
            h.TimeSeriesSource=value;
        end
        function set.TimeSeriesSourceType(h,value)
            h.TimeSeriesSourceType=value;
            setTimeSeriesSourceTypeImpl(h,value)
        end
        function value=get.TimeSeriesSourceType(h)
            value=char(h.TimeSeriesSourceType);
        end

        function set.TimeSeriesReadFcn(h,value)
            if isa(value,"function_handle")
                h.TimeSeriesReadFcn=value;
            else
                h.TimeSeriesReadFcn=str2func(value);
            end
        end
    end

    methods(Hidden)
        function setTimeSeriesSourceTypeImpl(~,~)

        end

        function consistencyCheck(h)


            enum=string(enumeration("Aero.animation.internal.TimeSeriesSourceType"));
            typeMap=containers.Map(enum,{'timeseries','timetable','double','double','struct',''});
            funcMap=containers.Map(enum,{'Timeseries','Timetable','6DoF','3DoF','Struct',''});

            idxNotCustom={h.TimeSeriesSourceType}~="Custom";
            hNotCustom=h(idxNotCustom);

            arrayfun(@(hh)validateConsistency(hh,typeMap,funcMap),hNotCustom);
        end
    end
end

function validateConsistency(h,typeMap,funcMap)
    if~isa(h.TimeSeriesSource,typeMap(h.TimeSeriesSourceType))
        error(message('aero:Timeseries:SourceDType'));
    end
    if~contains(func2str(h.TimeSeriesReadFcn),funcMap(h.TimeSeriesSourceType))
        error(message('aero:Timeseries:ReadFcn'));
    end
end
