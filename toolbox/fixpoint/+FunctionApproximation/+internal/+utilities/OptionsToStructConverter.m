classdef OptionsToStructConverter<handle





    methods(Access={?FunctionApproximation.internal.AbstractUtils})
        function this=OptionsToStructConverter()
        end
    end

    methods
        function optionsStruct=convert(~,options)
            optionsStruct=struct();
            optionsNames=properties(options);
            for iName=1:numel(optionsNames)
                currentName=optionsNames{iName};
                value=options.(currentName);
                if strcmp(currentName,'BreakpointSpecification')


                    value=FunctionApproximation.BreakpointSpecification.getHighestEnum(value);
                end
                if strcmp(currentName,'WordLengths')

                    value=FunctionApproximation.internal.Utils.getCompactStringForIntegerVector(value);
                end
                if isenum(value)

                    value=string(value);
                end
                if isnumeric(value)||islogical(value)


                    value=fixed.internal.compactButAccurateMat2Str(value);
                end
                optionsStruct.(currentName)=value;
            end
        end
    end
end
