classdef BasicTypesConfig < handle

    properties
        GenDirectory
        ModelName
        SupportComplex
        MaxMultiwordBits
    end

    properties ( SetAccess = immutable )
        PurelyIntegerCode
        ReplaceRTWTypesWithARTypes
        UsingLanguageStandardTypes
        FixedWidthIntHeader
        BasicTypeNames
        BooleanHeader
    end

    methods
        function this = BasicTypesConfig( genFolder, options )
            arguments
                genFolder
                options.PurelyIntegerCode
                options.SupportComplex
                options.MaxMultiwordBits
                options.ReplaceRTWTypesWithARTypes = false
                options.ModelName = ''
                options.UsingLanguageStandardTypes = false
                options.FixedWidthIntHeader = 'rtwtypes.h'
                options.BasicTypeNames = [  ]
                options.BooleanHeader = 'rtwtypes.h'
            end

            this.GenDirectory = genFolder;
            this.PurelyIntegerCode = options.PurelyIntegerCode;
            this.SupportComplex = options.SupportComplex;
            this.MaxMultiwordBits = options.MaxMultiwordBits;
            this.ReplaceRTWTypesWithARTypes = options.ReplaceRTWTypesWithARTypes;
            this.ModelName = options.ModelName;
            this.UsingLanguageStandardTypes = options.UsingLanguageStandardTypes;
            this.FixedWidthIntHeader = options.FixedWidthIntHeader;
            this.BasicTypeNames = options.BasicTypeNames;
            this.BooleanHeader = options.BooleanHeader;

        end
    end
end

