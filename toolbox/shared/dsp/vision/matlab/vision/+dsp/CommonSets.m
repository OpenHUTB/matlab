classdef CommonSets




    properties(Constant=true)
        PropertyOrInputPort=matlab.system.StringSet({...
        'Property',...
        'Input port'});

        AutoOrProperty=matlab.system.StringSet({...
        'Auto',...
        'Property'});

        FrameOrSampleBased=matlab.system.StringSet({...
        'Frame based',...
        'Sample based'});

        Dimension=matlab.system.StringSet({...
        'All','Row','Column','Custom'});

        RowVectorInterpretation=matlab.system.StringSet({...
        'Multiple Channels','Single Channel'});

        ResetCondition=matlab.system.StringSet({'Rising edge',...
        'Falling edge',...
        'Either edge',...
        'Non-zero'});

        ROIForm=matlab.system.StringSet({...
        'Rectangles','Lines','Label matrix','Binary mask'});

        ROIPortionToProcess=matlab.system.StringSet({...
        'Entire ROI','ROI perimeter'});

        ROIStatistics=matlab.system.StringSet({...
        'Individual statistics for each ROI',...
        'Single statistic for all ROIs'});

        SineComputation=matlab.system.StringSet({...
        'Trigonometric function',...
        'Table lookup'});

        IgnoreWarnError=matlab.system.StringSet({'Ignore','Warn','Error'});

        FirstCoeffNotOneAction=matlab.system.StringSet(...
        {'Replace it with 1','Normalize','Normalize and warn','Error'});

        NonUnityFirstCoefficientAction=matlab.system.StringSet(...
        {'Replace with 1','Normalize'});

        DoubleSingleUsr=matlab.system.StringSet({'double','single',...
        'Custom'});

        FFTImplementation=matlab.system.StringSet({'Auto','Radix-2','FFTW'});


        RoundMode=matlab.system.StringSet(...
        {'Ceiling','Convergent','Floor','Nearest','Round','Simplest','Zero'});
        RoundingMethod=matlab.system.StringSet(...
        {'Ceiling','Convergent','Floor','Nearest','Round','Simplest','Zero'});

        LimitedRoundMode=matlab.system.StringSet({'Floor','Nearest'});
        OverflowMode=matlab.system.StringSet({'Wrap','Saturate'});
        OverflowAction=matlab.system.StringSet({'Wrap','Saturate'});


        FixptModeBasic=matlab.system.StringSet({
        'Same as input',...
        'Custom'});

        FixptModeInherit=matlab.system.internal.StringSetGF({
        'Full precision',...
        'Same as input',...
        'Custom'},...
        {'Internal rule'},{'Full precision'});

        FixptModeProd=matlab.system.StringSet({
        'Same as product',...
        'Same as input',...
        'Custom'});

        FixptModeInheritProd=matlab.system.internal.StringSetGF({
        'Full precision',...
        'Same as product',...
        'Same as input',...
        'Custom'},...
        {'Internal rule'},{'Full precision'});
        FixptModeInheritProdUnscaled=matlab.system.internal.StringSetGF({
        'Full precision',...
        'Same as product',...
        'Custom'},...
        {'Internal rule'},{'Full precision'});

        FixptModeAccum=matlab.system.StringSet({
        'Same as accumulator',...
        'Same as input',...
        'Custom'});

        FixptModeAccumProd=matlab.system.StringSet({
        'Same as accumulator',...
        'Same as product',...
        'Same as input',...
        'Custom'});

        FixptModeUnscaled=matlab.system.StringSet({
        'Same word length as input',...
        'Custom'});

        FixptModeEitherScale=matlab.system.StringSet({
        'Same word length as input',...
        'Custom'});


        FixptModeBasicFirst=matlab.system.StringSet({
        'Same as first input',...
        'Custom'});
        FixptModeInheritUnscaled=matlab.system.internal.StringSetGF({
        'Full precision',...
        'Custom'},...
        {'Internal rule'},{'Full precision'});
        FixptModeInheritFirst=matlab.system.internal.StringSetGF({
        'Full precision',...
        'Same as first input',...
        'Custom'},...
        {'Internal rule'},{'Full precision'});
        FixptModeInheritProdFirst=matlab.system.internal.StringSetGF({
        'Full precision',...
        'Same as product',...
        'Same as first input',...
        'Custom'},...
        {'Internal rule'},{'Full precision'});
        FixptModeProdFirst=matlab.system.StringSet({...
        'Same as product',...
        'Same as first input',...
        'Custom'});
        FixptModeAccumProdFirst=matlab.system.StringSet({
        'Same as accumulator',...
        'Same as product',...
        'Same as first input',...
        'Custom'});
        FixptModeAccumFirst=matlab.system.StringSet({...
        'Same as accumulator',...
        'Same as first input',...
        'Custom'});
        FixptModeAccumNoInput=matlab.system.StringSet({...
        'Same as accumulator',...
        'Custom'});
        FixptModeProdNoInput=matlab.system.StringSet({
        'Same as product',...
        'Custom'});
        FixptModeAccumProdNoInput=matlab.system.StringSet({
        'Same as accumulator',...
        'Same as product',...
        'Custom'});
        FixptModeEitherScaleFirst=matlab.system.StringSet({
        'Same word length as first input',...
        'Custom'});

        FixptModeScaledOnly=matlab.system.StringSet({'Custom'});

        FixptModeUnscaledOnly=matlab.system.StringSet({'Custom'});


    end
    methods(Static=true)
        function en=getSet(name)
            persistent instance;
            if isempty(instance)
                instance=dsp.CommonSets;
            end

            switch name
            case 'ResetCondition'
                en=instance.ResetCondition;
            case 'PropertyOrInputPort'
                en=instance.PropertyOrInputPort;
            case 'AutoOrProperty'
                en=instance.AutoOrProperty;
            case 'FrameOrSampleBased'
                en=instance.FrameOrSampleBased;
            case 'Dimension'
                en=instance.Dimension;
            case 'RowVectorInterpretation'
                en=instance.RowVectorInterpretation;
            case 'IgnoreWarnError'
                en=instance.IgnoreWarnError;
            case 'FirstCoeffNotOneAction'
                en=instance.FirstCoeffNotOneAction;
            case 'NonUnityFirstCoefficientAction'
                en=instance.NonUnityFirstCoefficientAction;
            case 'FFTImplementation'
                en=instance.FFTImplementation;
            case 'RoundMode'
                en=instance.RoundMode;
            case 'RoundingMethod'
                en=instance.RoundingMethod;
            case 'LimitedRoundMode'
                en=instance.LimitedRoundMode;
            case 'OverflowMode'
                en=instance.OverflowMode;
            case 'OverflowAction'
                en=instance.OverflowAction;
            case 'ROIForm'
                en=instance.ROIForm;
            case 'ROIPortionToProcess'
                en=instance.ROIPortionToProcess;
            case 'ROIStatistics'
                en=instance.ROIStatistics;
            case 'SineComputation'
                en=instance.SineComputation;
            case 'DoubleSingleUsr'
                en=instance.DoubleSingleUsr;
            case 'FixptModeBasic'
                en=instance.FixptModeBasic;
            case 'FixptModeProd'
                en=instance.FixptModeProd;
            case 'FixptModeAccum'
                en=instance.FixptModeAccum;
            case 'FixptModeAccumProd'
                en=instance.FixptModeAccumProd;
            case 'FixptModeInherit'
                en=instance.FixptModeInherit;
            case 'FixptModeInheritUnscaled'
                en=instance.FixptModeInheritUnscaled;
            case 'FixptModeInheritProd'
                en=instance.FixptModeInheritProd;
            case 'FixptModeInheritProdUnscaled'
                en=instance.FixptModeInheritProdUnscaled;
            case 'FixptModeUnscaled'
                en=instance.FixptModeUnscaled;
            case 'FixptModeEitherScale'
                en=instance.FixptModeEitherScale;
            case 'FixptModeAccumNoInput'
                en=instance.FixptModeAccumNoInput;
            case 'FixptModeProdNoInput'
                en=instance.FixptModeProdNoInput;
            case 'FixptModeAccumProdNoInput'
                en=instance.FixptModeAccumProdNoInput;
            case 'FixptModeEitherScaleFirst'
                en=instance.FixptModeEitherScaleFirst;
            case 'FixptModeScaledOnly'
                en=instance.FixptModeScaledOnly;
            case 'FixptModeUnscaledOnly'
                en=instance.FixptModeUnscaledOnly;
            case 'FixptModeBasicFirst'
                en=instance.FixptModeBasicFirst;
            case 'FixptModeInheritFirst'
                en=instance.FixptModeInheritFirst;
            case 'FixptModeInheritProdFirst'
                en=instance.FixptModeInheritProdFirst;
            case 'FixptModeProdFirst'
                en=instance.FixptModeProdFirst;
            case 'FixptModeAccumProdFirst'
                en=instance.FixptModeAccumProdFirst;
            case 'FixptModeAccumFirst'
                en=instance.FixptModeAccumFirst;
            otherwise
                error(message('dspshared:system:CommonSets:unknownSet',name));
            end
        end

    end
end
