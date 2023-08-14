function builtinBlockTypes(obj)




    if isR2020bOrEarlier(obj.ver)
        obj.removeBlocksOfType('MessageMerge');
    end

    if isR2020aOrEarlier(obj.ver)
        obj.removeBlocksOfType('MatrixViewerBlock');
        obj.removeBlocksOfType('SimscapeProbe');
    end

    if isR2020aOrEarlier(obj.ver)
        obj.removeBlocksOfType('VariablePulseGenerator');

        b=obj.findLibraryLinksTo('simulink/Discontinuities/PWM');
        obj.replaceWithEmptySubsystem(b);
    end

    if isR2019bOrEarlier(obj.ver)
        obj.removeBlocksOfType('StringReplaceBetween');
    end

    if isR2019aOrEarlier(obj.ver)
        obj.removeBlocksOfType('CFunction');
        obj.removeBlocksOfType('CoSimServiceBlock');
        obj.removeBlocksOfType('FirstOrderHold');
        obj.removeBlocksOfType('EntityTransportDelay');
        obj.removeBlocksOfType('StateOwnerGetter');
        obj.removeBlocksOfType('StateOwnerSetter');
        obj.removeBlocksOfType('UnfoldingSelector');

        obj.removeBlocksOfType('BitSlice');
        obj.removeBlocksOfType('CustomWebBlock');
        obj.removeBlocksOfType('DataTransferBlock');
        obj.removeBlocksOfType('IconEditorPreviewBlock');
        obj.removeBlocksOfType('StringReplace');
        obj.removeBlocksOfType('StringSearch');
        obj.removeBlocksOfType('StringStrip');
        obj.removeBlocksOfType('VariantPMConnector');

        obj.appendRule('<Block<BlockType|"ComboBox"><UseEnumeratedDataType:remove>>');
        obj.appendRule('<Block<BlockType|"Playback"><SampleTime:remove>>');
        obj.appendRule('<Block<BlockType|"Playback"><Interpolate:remove>>');
        obj.appendRule('<Block<BlockType|"RotarySwitchBlock"><UseEnumeratedDataType:remove>>');
        obj.appendRule('<Block<BlockType|"StreamIn"><Interpolate:remove>>');
        obj.appendRule('<Block<BlockType|"VarPlsDelay"><InitialInput:remove>>');
        obj.appendRule('<Block<BlockType|"VarPlsDelay"><BufferSize:remove>>');
    end

    if isR2018bOrEarlier(obj.ver)
        obj.removeBlocksOfType('AlgorithmDescriptorDelegate');
        obj.removeBlocksOfType('EntitySubscriber');
        obj.removeBlocksOfType('EntityTopic');
        obj.removeBlocksOfType('ExampleStreamOut');
        obj.removeBlocksOfType('FlexibleSink');
        obj.removeBlocksOfType('FlexibleSource');
        obj.removeBlocksOfType('FuzzerBlock');
        obj.removeBlocksOfType('IntrusiveAccessor');
        obj.removeBlocksOfType('ParameterReader');
        obj.removeBlocksOfType('ParameterWriter');
        obj.removeBlocksOfType('Playback');
        obj.removeBlocksOfType('Record');
        obj.removeBlocksOfType('SignalValidation');
        obj.removeBlocksOfType('StreamOutBlock');

        obj.appendRule('<Block<BlockType|"CustomGaugeBlock"><IsLinearGauge:remove>>');
        obj.appendRule('<Block<BlockType|"CustomGaugeBlock"><GaugeTrackLeft:remove>>');
        obj.appendRule('<Block<BlockType|"CustomGaugeBlock"><GaugeTrackTop:remove>>');
        obj.appendRule('<Block<BlockType|"CustomGaugeBlock"><GaugeTrackHeight:remove>>');
        obj.appendRule('<Block<BlockType|"CustomGaugeBlock"><GaugeTrackWidth:remove>>');
        obj.appendRule('<Block<BlockType|"CustomGaugeBlock"><GaugeTrackRotation:remove>>');
        obj.appendRule('<Block<BlockType|"PanelWebBlock"><PanelLabels:remove>>');
        obj.appendRule('<Block<BlockType|"RadioButtonGroup"><UseEnumeratedDataType:remove>>');
    end

    if isR2018aOrEarlier(obj.ver)
        obj.removeBlocksOfType('CCaller');
        obj.removeBlocksOfType('DescriptorStateSpace');
        obj.removeBlocksOfType('FcnCallPortGroup');
        obj.removeBlocksOfType('FindEntity');
        obj.removeBlocksOfType('MsgSvcAdapter');
        obj.removeBlocksOfType('PanelWebBlock');
        obj.removeBlocksOfType('ResetEventPortGroup');
        obj.removeBlocksOfType('StreamIn');
        obj.removeBlocksOfType('TagEntity');
    end

    if isR2016aOrEarlier(obj.ver)
        obj.removeBlocksOfType('StateReader');
        obj.removeBlocksOfType('StateWriter');
        obj.removeBlocksOfType('EventListener');
    end

    if isR2015bOrEarlier(obj.ver)
        obj.removeBlocksOfType('VariantSource');
        obj.removeBlocksOfType('VariantSink');
        obj.removeBlocksOfType('UnitConversion');
    end

    if isR2015aOrEarlier(obj.ver)
        obj.removeBlocksOfType('FromSpreadsheet');



        b=obj.findLibraryLinksTo('simulink/Sources/Waveform Generator');
        obj.replaceWithEmptySubsystem(b);
    end

    if isR2014bOrEarlier(obj.ver)
        obj.removeBlocksOfType('ResetPort');
    end

    if isR2014aOrEarlier(obj.ver)
        obj.removeBlocksOfType('FunctionCaller');
        obj.removeBlocksOfType('ArgIn');
        obj.removeBlocksOfType('ArgOut');
    end

    if isR2011bOrEarlier(obj.ver)
        obj.removeBlocksOfType('MATLABSystem');
    end

    if isR2010bOrEarlier(obj.ver)


        b=obj.findLibraryLinksTo('sldvlib/Temporal Operators/Detector');
        obj.replaceWithEmptySubsystem(b);
        b=obj.findLibraryLinksTo('sldvlib/Temporal Operators/Within Implies');
        obj.replaceWithEmptySubsystem(b);
        b=obj.findLibraryLinksTo('sldvlib/Temporal Operators/Extender');
        obj.replaceWithEmptySubsystem(b);

        obj.removeBlocksOfType('AsynchronousTaskSpecification');
        obj.removeBlocksOfType('FunctionCallFeedbackLatch');
        obj.removeBlocksOfType('AsyncTaskSpecification');
        obj.removeBlocksOfType('FunctionCallFeedbackLatch');
    end

    if isR2009bOrEarlier(obj.ver)
        obj.removeBlocksOfType('Find');
        obj.removeBlocksOfType('ForEach');
        obj.removeBlocksOfType('SecondOrderIntegrator');
        obj.removeBlocksOfType('StateEnablePort');
    end

    if isR2009aOrEarlier(obj.ver)
        obj.removeBlocksOfType('ImplicitIterator');
        obj.removeBlocksOfType('UnaryMinus');
    end

    if isR2007bOrEarlier(obj.ver)
        obj.removeBlocksOfType('DiscreteFir');
    end

    if isR2006bOrEarlier(obj.ver)
        obj.removeBlocksOfType('BusToVector');
        obj.removeBlocksOfType('PermuteDimensions');
        obj.removeBlocksOfType('Squeeze');
    end

    if isR2006aOrEarlier(obj.ver)
        obj.removeBlocksOfType('Interpolation_n-D');
        obj.removeBlocksOfType('PreLookup');
        obj.removeBlocksOfType('Reshape');
    end

end

