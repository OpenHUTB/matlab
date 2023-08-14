classdef CommonSetsHDL




    properties(Constant=true)
        AutoOrProperty=matlab.system.StringSet({'Auto','Property'});
        AlgebraicIntlvMethod=matlab.system.StringSet({'Takeshita-Costello',...
        'Welch-Costas'});
        Algorithm=matlab.system.StringSet({'True APP','Max*','Max'});
        BinaryOrGray=matlab.system.StringSet({'Binary','Gray'});
        BinaryGrayCustom=matlab.system.StringSet({'Binary','Gray','Custom'});
        DoubleOrSingle=matlab.system.StringSet({'double','single'});
        LogicalOrDouble=matlab.system.StringSet({'logical','double'});
        DoubleLogicalSmallestUnsigned=matlab.system.StringSet({'double','logical','Smallest unsigned integer'});
        BitDataType=matlab.system.internal.StringSetGF({'Full precision',...
        'Smallest unsigned integer',...
        'double','single','int8',...
        'uint8','int16','uint16',...
        'int32','uint32','logical'},...
        {'Internal rule'},{'Full precision'});
        IntDataType=matlab.system.internal.StringSetGF({'Full precision',...
        'Smallest unsigned integer',...
        'double','single','int8',...
        'uint8','int16','uint16',...
        'int32','uint32'},...
        {'Internal rule'},{'Full precision'});
        SignedIntDataType=matlab.system.internal.StringSetGF({'Full precision',...
        'Smallest integer','double',...
        'single','int8','int16','int32'},...
        {'Internal rule'},{'Full precision'});
        UnsignedIntDataType=matlab.system.internal.StringSetGF({'Full precision',...
        'Smallest integer','Same as input',...
        'double','single','int8','uint8',...
        'int16','uint16','int32','uint32'},...
        {'Internal rule'},{'Full precision'});
        UnsignedBitDataType=matlab.system.internal.StringSetGF({'Full precision',...
        'Smallest unsigned integer',...
        'Same as input','double','single',...
        'int8','uint8','int16','uint16',...
        'int32','uint32','logical'},...
        {'Internal rule'},{'Full precision'});


        TerminationMethod=matlab.system.StringSet({'Continuous','Truncated','Terminated'});
        FrequencyPulseShapes=matlab.system.StringSet({'Rectangular',...
        'Raised Cosine',...
        'Spectral Raised Cosine',...
        'Gaussian',...
        'Tamed FM'});
        NormalizationMethods=matlab.system.StringSet({'Minimum distance between symbols','Average power','Peak power'});
        NoneOrProperty=matlab.system.StringSet({'None','Property'});
        DecisionOptions=matlab.system.StringSet({'Hard decision','Log-likelihood ratio','Approximate log-likelihood ratio'});
        SpecifyInputs=matlab.system.StringSet({'Property','Input port'});
        ResetOptions=matlab.system.StringSet({'Never','Every frame'});
        OutDataType=matlab.system.StringSet({'logical',...
        'int8','uint8','int16','uint16',...
        'int32','uint32','double'});
        SignedOutDataType=matlab.system.StringSet({...
        'int8','int16','int32','double'});
        Polarity=matlab.system.StringSet({'Positive','Negative'});
        DoubleInt8=matlab.system.StringSet({'double','int8'});
        SameAsInputDoubleLogical=matlab.system.StringSet({'Same as input','double','logical'});

    end

    methods(Static=true)
        function en=getSet(name)
            persistent instance;
            if isempty(instance)
                instance=comm.CommonSetsHDL;
            end

            switch name
            case 'AutoOrProperty'
                en=instance.AutoOrProperty;
            case 'AlgebraicIntlvMethod'
                en=instance.AlgebraicIntlvMethod;
            case 'Algorithm'
                en=instance.Algorithm;
            case 'BinaryOrGray'
                en=instance.BinaryOrGray;
            case 'BinaryGrayCustom'
                en=instance.BinaryGrayCustom;
            case 'DoubleOrSingle'
                en=instance.DoubleOrSingle;
            case 'LogicalOrDouble'
                en=instance.LogicalOrDouble;
            case 'DoubleLogicalSmallestUnsigned'
                en=instance.DoubleLogicalSmallestUnsigned;
            case 'BitDataType'
                en=instance.BitDataType;
            case 'IntDataType'
                en=instance.IntDataType;
            case 'UnsignedDataType'
                en=instance.UnsignedOutput;
            case 'SignedIntDataType'
                en=instance.SignedIntDataType;
            case 'UnsignedIntDataType'
                en=instance.UnsignedIntDataType;
            case 'UnsignedBitDataType'
                en=instance.UnsignedBitDataType;
            case 'TerminationMethod'
                en=instance.TerminationMethod;
            case 'FrequencyPulseShapes'
                en=instance.FrequencyPulseShapes;
            case 'NormalizationMethods'
                en=instance.NormalizationMethods;
            case 'NoneOrProperty'
                en=instance.NoneOrProperty;
            case 'DecisionOptions'
                en=instance.DecisionOptions;
            case 'SpecifyInputs'
                en=instance.SpecifyInputs;
            case 'ResetOptions'
                en=instance.ResetOptions;
            case 'OutDataType'
                en=instance.OutDataType;
            case 'SignedOutDataType'
                en=instance.SignedOutDataType;
            case 'Polarity'
                en=instance.Polarity;
            case 'DoubleInt8'
                en=instance.DoubleInt8;
            case 'SameAsInputDoubleLogical'
                en=instance.SameAsInputDoubleLogical;
            otherwise
                coder.internal.errorIf(true,'comm:system:CommonSetsHDL:unknownSet',name);
            end
        end

    end
end
