function[sgrpInfo,cpArray]=diagnostics()





    sgrpInfo.Name=pm_message('sm:sli:configParameters:diagnostics:Name');
    sgrpInfo.Description=pm_message('sm:sli:configParameters:diagnostics:Description');

    errLevel=findtype('mech2.ErrorLevel');


    groupName='Evaluation';
    eMsgId='sm:model:evaluate:';

    cpArray(1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidUnit');
    cpArray(end).Label=getEvalLabel('invalidUnit');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Visible=false;
    cpArray(end).Ids={[eMsgId,'InvalidUnit'];
    [eMsgId,'InvalidUnit2']};

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidDimension');
    cpArray(end).Label=getEvalLabel('invalidDimension');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[eMsgId,'InvalidDimension'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidVectorParameterSize');
    cpArray(end).Label=getEvalLabel('invalidVectorParameterSize');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[eMsgId,'InvalidVectorParameterSize'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidVectorParameterMinSize');
    cpArray(end).Label=getEvalLabel('invalidVectorParameterMinSize');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[eMsgId,'InvalidVectorParameterMinSize'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('paramRangeError');
    cpArray(end).Label=getEvalLabel('paramRangeError');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids={[eMsgId,'OpenRangeError'];
    [eMsgId,'ClosedRangeError'];
    [eMsgId,'OpenClosedRangeError'];
    [eMsgId,'ClosedOpenRangeError'];
    [eMsgId,'IntegerRangeError'];
    [eMsgId,'NonIntegerError'];
    [eMsgId,'NegativeScalar'];
    [eMsgId,'ZeroScalar'];
    [eMsgId,'NonpositiveScalar'];
    [eMsgId,'NonpositiveVector'];
    'sm:model:visualProperties:RangeError';
    };

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidValueInf');
    cpArray(end).Label=getEvalLabel('invalidValueInf');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[eMsgId,'InvalidValueInf'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidValueNaN');
    cpArray(end).Label=getEvalLabel('invalidValueNaN');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[eMsgId,'InvalidValueNaN'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('nonSymmetricMatrix');
    cpArray(end).Label=getEvalLabel('nonSymmetricMatrix');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[eMsgId,'NonSymmetricMatrix'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('repeatedRows');
    cpArray(end).Label=getEvalLabel('repeatedRows');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[eMsgId,'RepeatedRows'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('notLessThanError');
    cpArray(end).Label=getEvalLabel('notLessThanError');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[eMsgId,'NotLessThanError'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('sumNotLessThanError');
    cpArray(end).Label=getEvalLabel('sumNotLessThanError');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[eMsgId,'SumNotLessThanError'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('monotonicIncreasing');
    cpArray(end).Label=getEvalLabel('monotonicIncreasing');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[eMsgId,'MonotonicIncreasing'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('xGridVectorMatrixMismatch');
    cpArray(end).Label=getEvalLabel('xGridVectorMatrixMismatch');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[eMsgId,'XGridVectorMatrixMismatch'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('yGridVectorMatrixMismatch');
    cpArray(end).Label=getEvalLabel('yGridVectorMatrixMismatch');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[eMsgId,'YGridVectorMatrixMismatch'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidFileUnit');
    cpArray(end).Label=getEvalLabel('invalidFileUnit');
    cpArray(end).DataType='mech2.UnconfigurableWarning';
    cpArray(end).DefaultValue=errLevel.String{2};
    cpArray(end).Ids={[eMsgId,'FileUnitsRequired'];
    [eMsgId,'FileUnitsNotRecognized'];
    [eMsgId,'FileUnitsInvalid'];
    };
    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('fileReadingError');
    cpArray(end).Label=getEvalLabel('fileReadingError');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids={[eMsgId,'FilenameRequired'];
    [eMsgId,'FileNotExist'];
    };

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('openCascadeDeprecated');
    cpArray(end).Label=getEvalLabel('openCascadeDeprecated');
    cpArray(end).DataType='mech2.UnconfigurableWarning';
    cpArray(end).DefaultValue=errLevel.String{2};
    cpArray(end).Ids='sm:model:solid:OpenCascadeDeprecated';

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('fileUnitsNotFound');
    cpArray(end).Label=getEvalLabel('fileUnitsNotFound');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[eMsgId,'FileUnitsNotFound'];

    vMsgId='sm:model:visualProperties:';
    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidVisualProperty');
    cpArray(end).Label=getEvalLabel('invalidVisualProperty');
    cpArray(end).DataType='mech2.ErrorLevel';
    cpArray(end).DefaultValue=errLevel.String{2};
    cpArray(end).Ids={[vMsgId,'InvalidColorVector'];
    [vMsgId,'ClosedRangeError'];
    'sm:model:graphic:InvalidInertiaEllipsoidForPointMass';
    'sm:model:solid:FromFileVisualPropertiesNotFound';
    };

    gMsgId='sm:model:geometry:';
    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('crossSectionNullEdge');
    cpArray(end).Label=getEvalLabel('crossSectionNullEdge');
    cpArray(end).DataType='mech2.ErrorLevel';
    cpArray(end).DefaultValue=errLevel.String{2};
    cpArray(end).Ids={[gMsgId,'CrossSectionNullEdge'];
    [gMsgId,'CrossSectionBoundaryNullEdge'];
    };

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('crossSectionTinyEdge');
    cpArray(end).Label=getEvalLabel('crossSectionTinyEdge');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids={[gMsgId,'CrossSectionTinyEdge'];
    [gMsgId,'CrossSectionBoundaryTinyEdge'];
    };

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidCrossSection');
    cpArray(end).Label=getEvalLabel('invalidCrossSection');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids={[gMsgId,'CrossSectionNotEnoughValidPts'];
    [gMsgId,'CrossSectionBoundaryNotEnoughValidPts'];
    [gMsgId,'CrossSectionNotInCRHP'];
    [gMsgId,'CrossSectionSelfIntersect'];
    [gMsgId,'CrossSectionBoundarySelfIntersect'];
    [gMsgId,'CrossSectionNotCCW'];
    [gMsgId,'CrossSectionSelfOverlap'];
    [gMsgId,'CrossSectionBoundarySelfOverlap'];
    [gMsgId,'CrossSectionInvalidOrdering'];
    [gMsgId,'CrossSectionBoundaryInvalidOrdering'];
    [gMsgId,'InvalidMultiplyConnectedCrossSection'];
    [gMsgId,'NonPositiveAreaCrossSection'];
    [gMsgId,'CrossSectionalAnalysisFailed'];
    };

    iMsgId='sm:model:inertia:';
    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidZeroMass');
    cpArray(end).Label=getEvalLabel('invalidZeroMass');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[iMsgId,'InvalidZeroMass'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidModeActuationModeSettings');
    cpArray(end).Label=getEvalLabel('invalidModeActuationModeSettings');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids='sm:model:joint:InvalidModeActuationModeSettings';

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('nullLimitRange');
    cpArray(end).Label=getEvalLabel('nullLimitRange');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids='sm:model:jointPrimitive:NullLimitRange';

    sMsgId='sm:model:solid:';
    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('incompatibleGeometricInertia');
    cpArray(end).Label=getEvalLabel('incompatibleGeometricInertia');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[sMsgId,'InvalidGeometricInertia'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidGeometryForInertia');
    cpArray(end).Label=getEvalLabel('invalidGeometryForInertia');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[sMsgId,'InvalidGeometryForInertia'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('densityNotFoundInFile');
    cpArray(end).Label=getEvalLabel('densityNotFoundInFile');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[sMsgId,'DensityNotFoundInFile'];

    rMsgId='sm:model:rotation:';
    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('zeroRotationAxis');
    cpArray(end).Label=getEvalLabel('zeroRotationAxis');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[rMsgId,'ZeroRotationAxis'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidRotationSpecification');
    cpArray(end).Label=getEvalLabel('invalidRotationSpecification');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[rMsgId,'InvalidAlignedAxesParameters'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('nonOrthogonalRotationMatrix');
    cpArray(end).Label=getEvalLabel('nonOrthogonalRotationMatrix');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[rMsgId,'NonOrthogonalRotationMatrix'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('nonProperOrthogonalRotationMatrix');
    cpArray(end).Label=getEvalLabel('nonProperOrthogonalRotationMatrix');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[rMsgId,'NonProperOrthogonalRotationMatrix'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('nonUnitQuaternion');
    cpArray(end).Label=getEvalLabel('nonUnitQuaternion');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[rMsgId,'NonUnitQuaternion'];

    cMsgId='sm:model:commonGear:';
    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidInternalGearRadii');
    cpArray(end).Label=getEvalLabel('invalidInternalGearRadii');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[cMsgId,'InvalidInternalGearRadii'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidInternalGearRatio');
    cpArray(end).Label=getEvalLabel('invalidInternalGearRatio');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[cMsgId,'InvalidInternalGearRatio'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('repeatedDataPoints');
    cpArray(end).Label=getEvalLabel('repeatedDataPoints');
    cpArray(end).DataType='mech2.UnconfigurableWarning';
    cpArray(end).DefaultValue=errLevel.String{2};
    cpArray(end).Ids=[gMsgId,'RepeatedDataPoints'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('insufficientDataPoints');
    cpArray(end).Label=getEvalLabel('insufficientDataPoints');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[gMsgId,'InsufficientDataPoints'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('colinearSplineDataPoints');
    cpArray(end).Label=getEvalLabel('colinearSplineDataPoints');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[gMsgId,'ColinearSplineDataPoints'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidValueCantEvaluate');
    cpArray(end).Label=getEvalLabel('invalidValueCantEvaluate');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids='sm:local:model:evaluate:CantEvaluate';

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidDependentParameters');
    cpArray(end).Label=getEvalLabel('invalidDependentParameters');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids={'sm:model:geometry:GeometryInertiaCyclicDependency',...
    'sm:model:geometry:MultipleMassDependentParams',...
    'sm:model:geometry:DependentParamNan',...
    };

    fseMsgId='sm:model:flexibleSuperelement:';
    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidNumberOfFrameOrigins');
    cpArray(end).Label=getEvalLabel('invalidNumberOfFrameOrigins');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[fseMsgId,'InvalidNumberOfFrameOrigins'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('invalidNumberOfFrameOrientations');
    cpArray(end).Label=getEvalLabel('invalidNumberOfFrameOrientations');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[fseMsgId,'InvalidNumberOfFrameOrientations'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('inconsistentRowDimensions');
    cpArray(end).Label=getEvalLabel('inconsistentRowDimensions');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[fseMsgId,'InconsistentRowDimensions'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('inconsistentMatrixDimensions');
    cpArray(end).Label=getEvalLabel('inconsistentMatrixDimensions');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[fseMsgId,'InconsistentMatrixDimensions'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('tooFewRowsAndColumns');
    cpArray(end).Label=getEvalLabel('tooFewRowsAndColumns');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[fseMsgId,'TooFewRowsAndColumns'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('incorrectModalDecimation');
    cpArray(end).Label=getEvalLabel('incorrectModalDecimation');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[fseMsgId,'IncorrectModalDecimation'];

    anrMsgId='sm:model:annularRectangle:';
    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('thicknessTooLarge');
    cpArray(end).Label=getEvalLabel('thicknessTooLarge');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[anrMsgId,'ThicknessTooLarge'];


    groupName='Topology';
    msgId='sm:compiler:topologyAnalysis:';

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('floatingEntity');
    cpArray(end).Label=getLabel('floatingEntity');
    cpArray(end).DataType='mech2.UnconfigurableWarning';
    cpArray(end).DefaultValue=errLevel.String{2};
    cpArray(end).Ids=[msgId,'FloatingEntity'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('unconnectedFramePorts');
    cpArray(end).Label=getLabel('unconnectedFramePorts');
    cpArray(end).DataType='mech2.ErrorLevel';
    cpArray(end).DefaultValue=errLevel.String{2};
    cpArray(end).Ids={[msgId,'UnconnectedFramePort'];
    [msgId,'UnconnectedFramePort6Dof'];
    [msgId,'TwoUnconnectedFramePorts']
    [msgId,'DanglingBlock']};

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('unconnectedGeometryPorts');
    cpArray(end).Label=getLabel('unconnectedGeometryPorts');
    cpArray(end).DataType='mech2.ErrorLevel';
    cpArray(end).DefaultValue=errLevel.String{2};
    cpArray(end).Ids=[msgId,'UnconnectedGeometryPort'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('unconnectedForceGeometryPort');
    cpArray(end).Label=getLabel('unconnectedForceGeometryPort');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'UnconnectedForceGeometryPort'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('floatingGeometryForce');
    cpArray(end).Label=getLabel('floatingGeometryForce');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'FloatingGeometryForce'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('conflictingGeometry');
    cpArray(end).Label=getLabel('conflictingGeometry');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'ConflictingGeometry'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('invalidGeomConnected');
    cpArray(end).Label=getLabel('invalidGeomConnected');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'InvalidGeometryConnected'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('duplicateGeomConnected');
    cpArray(end).Label=getLabel('duplicateGeomConnected');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'DuplicateGeometryConnected'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('unsupportedGeomConnection');
    cpArray(end).Label=getLabel('unsupportedGeomConnection');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'UnsupportedGeometryConnection'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('unsupportedGeomCombination');
    cpArray(end).Label=getLabel('unsupportedGeomCombination');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'UnsupportedGeometryCombination'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('unsupportedContactWithIO');
    cpArray(end).Label=getLabel('unsupportedContactWithIO');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'UnsupportedContactWithIO'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('parallelContactForceBlocks');
    cpArray(end).Label=getLabel('parallelContactForceBlocks');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'ParallelContactForceBlocks'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('unsupportedRtpPrism');
    cpArray(end).Label=getLabel('unsupportedRtpPrism');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'UnsupportedRtpPrismInContact'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('unsupportedZeroCrossing');
    cpArray(end).Label=getLabel('unsupportedZeroCrossing');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'UnsupportedZeroCrossingPCGrid'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('beltCable:invalidBeltCableConnection');
    cpArray(end).Label=getLabel('beltCable:invalidBeltCableConnection');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'beltCable:InvalidBeltCableConnection'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('beltCable:pulley:unconnectedBeltCablePort');
    cpArray(end).Label=getLabel('beltCable:pulley:unconnectedBeltCablePort');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'beltCable:pulley:UnconnectedBeltCablePort'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('beltCable:pulley:unconnectedBeltCablePorts');
    cpArray(end).Label=getLabel('beltCable:pulley:unconnectedBeltCablePorts');
    cpArray(end).DataType='mech2.UnconfigurableWarning';
    cpArray(end).DefaultValue=errLevel.String{2};
    cpArray(end).Ids=[msgId,'beltCable:pulley:UnconnectedBeltCablePorts'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('beltCable:pulley:selfConnectedBeltCablePorts');
    cpArray(end).Label=getLabel('beltCable:pulley:selfConnectedBeltCablePorts');
    cpArray(end).DataType='mech2.UnconfigurableWarning';
    cpArray(end).DefaultValue=errLevel.String{2};
    cpArray(end).Ids=[msgId,'beltCable:pulley:SelfConnectedBeltCablePorts'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=...
    getTopoName('beltCable:circuitEndBlock:unconnectedBeltCablePort');
    cpArray(end).Label=...
    getLabel('beltCable:circuitEndBlock:unconnectedBeltCablePort');
    cpArray(end).DataType='mech2.UnconfigurableWarning';
    cpArray(end).DefaultValue=errLevel.String{2};
    cpArray(end).Ids=[msgId,'beltCable:circuitEndBlock:UnconnectedBeltCablePort'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=...
    getTopoName('beltCable:beltCableProperties:conflictingBeltCableProperties');
    cpArray(end).Label=...
    getLabel('beltCable:beltCableProperties:conflictingBeltCableProperties');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=...
    [msgId,'beltCable:beltCableProperties:ConflictingBeltCableProperties'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=...
    getTopoName('beltCable:beltCableProperties:noBeltCablePropertiesConnected');
    cpArray(end).Label=...
    getLabel('beltCable:beltCableProperties:noBeltCablePropertiesConnected');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=...
    [msgId,'beltCable:beltCableProperties:NoBeltCablePropertiesConnected'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('redundantBlock');
    cpArray(end).Label=getLabel('redundantBlock');
    cpArray(end).DataType='mech2.ErrorLevel';
    cpArray(end).DefaultValue=errLevel.String{2};
    cpArray(end).Ids=[msgId,'RedundantBlock'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('shortedTransform');
    cpArray(end).Label=getLabel('shortedTransform');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'ShortedTransform'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('rigidCycle');
    cpArray(end).Label=getLabel('rigidCycle');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids={[msgId,'RigidCycle'];
    [msgId,'RigidCycleBreak'];
    [msgId,'RigidCycleBreakTransform'];
    };

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('conflictingRefFrames');
    cpArray(end).Label=getLabel('conflictingRefFrames');
    cpArray(end).DataType='mech2.ErrorLevel';
    cpArray(end).DefaultValue=errLevel.String{2};
    cpArray(end).Ids=[msgId,'ConflictingReferenceFrames'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('conflictingMachineEnvironments');
    cpArray(end).Label=getLabel('conflictingMachineEnvironments');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'ConflictingMachineEnvironments'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('conflictingGravitySpecification');
    cpArray(end).Label=getLabel('conflictingGravitySpecification');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'ConflictingGravitySpecification'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('flexibleBodiesInGravitationalField');
    cpArray(end).Label=getLabel('flexibleBodiesInGravitationalField');
    cpArray(end).DataType='mech2.UnconfigurableWarning';
    cpArray(end).DefaultValue=errLevel.String{2};
    cpArray(end).Ids=[msgId,'FlexibleBodiesInGravitationalField'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('rigidlyBoundBlock');
    cpArray(end).Label=getLabel('rigidlyBoundBlock');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids={[msgId,'RigidlyBoundJoint']
    };
    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('rigidlyBoundBlock');
    cpArray(end).Label=getLabel('rigidlyBoundBlock');
    cpArray(end).DataType='mech2.ErrorLevel';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids={[msgId,'RigidlyBoundConstraint'];
    [msgId,'RigidlyBoundForceBlock'];
    [msgId,'OnePortForceBlockGrounded'];
    [msgId,'RigidlyBoundMultiBlockConstraint'];
    };


    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('rigidlyBoundJointWithIO');
    cpArray(end).Label=getLabel('rigidlyBoundJointWithIO');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids={[msgId,'RigidlyBoundJointWithIO']};

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('directSignalConnection');
    cpArray(end).Label=getLabel('directSignalConnection');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids={[msgId,'DirectSignalConnection']
    };

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('invalidMassDistribution');
    cpArray(end).Label=getLabel('invalidMassDistribution');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids={[msgId,'InvalidMassDistribution']...
    ,[msgId,'InvalidMassDistWithoutVarInert']
    };

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getTopoName('jointlessFlexibleBodyLoop');
    cpArray(end).Label=getLabel('jointlessFlexibleBodyLoop');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'JointlessFlexibleBodyLoop'];



    groupName='Inertia';
    msgId='sm:compiler:inertiaAnalysis:';

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getInertiaName('improperRigidBodyProperties');
    cpArray(end).Label=getInertiaLabel('improperRigidBodyProperties');
    cpArray(end).DataType='mech2.UnconfigurableWarning';
    cpArray(end).DefaultValue=errLevel.String{2};
    cpArray(end).Ids=[msgId,'ImproperRigidBodyProperties'];



    groupName='Body Modeling';
    msgId='sm:compiler:bodyAnalysis:';

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getBodyModelingName('unsatisfiedNumberOfElements');
    cpArray(end).Label=getBodyModelingLabel('unsatisfiedNumberOfElements');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'UnsatisfiedNumberOfElements'];


    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getBodyModelingName('unsatisfiedNumRetainedModes');
    cpArray(end).Label=getBodyModelingLabel('unsatisfiedNumRetainedModes');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'UnsatisfiedNumRetainedModes'];


    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getBodyModelingName('frameLocationError');
    cpArray(end).Label=getBodyModelingLabel('frameLocationError');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'FrameLocationError'];


    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getBodyModelingName('meshingError');
    cpArray(end).Label=getBodyModelingLabel('meshingError');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'MeshingError'];



    groupName='Assembly';
    msgId='sm:compiler:state:';

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getAssmName('unsatisfiedDesiredTarget');
    cpArray(end).Label=getAssmLabel('unsatisfiedDesiredTarget');
    cpArray(end).DataType='mech2.ErrorLevel';
    cpArray(end).DefaultValue=errLevel.String{2};
    cpArray(end).Ids=[msgId,'UnsatisfiedDesiredTarget'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getAssmName('jointTargetOverSpecification');
    cpArray(end).Label=getAssmLabel('jointTargetOverSpecification');
    cpArray(end).DataType='mech2.ErrorLevel';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'JointTargetOverSpecification'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getEvalName('operatingPointError');
    cpArray(end).Label=getEvalLabel('operatingPointError');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'OperatingPointError'];



    groupName='Actuation';
    msgId='sm:compiler:actuation:';

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getActuationName('invalidActuation');
    cpArray(end).Label=getActuationLabel('invalidActuation');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'InvalidActuation'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getActuationName('overspecifiedDynamics');
    cpArray(end).Label=getActuationLabel('overspecifiedDynamics');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'OverspecifiedDynamics'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getActuationName('underspecifiedDynamics');
    cpArray(end).Label=getActuationLabel('underspecifiedDynamics');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'UnderspecifiedDynamics'];

    cpArray(end+1)=simmechanics.sli.internal.ConfigurationParameter;
    cpArray(end).Group=groupName;
    cpArray(end).Name=getActuationName('unsupportedActuationWithFlexibleBodies');
    cpArray(end).Label=getActuationLabel('unsupportedActuationWithFlexibleBodies');
    cpArray(end).DataType='mech2.UnconfigurableError';
    cpArray(end).DefaultValue=errLevel.String{3};
    cpArray(end).Ids=[msgId,'UnsupportedActuationWithFlexibleBodies'];

end

function msg=getEvalName(param)
    msg=pm_message(...
    ['sm:sli:configParameters:diagnostics:evaluation:',param,':ParamName']);
end

function msg=getEvalLabel(param)
    msg=pm_message(...
    ['sm:sli:configParameters:diagnostics:evaluation:',param,':Label']);
end

function msg=getTopoName(param)
    msg=pm_message(...
    ['sm:sli:configParameters:diagnostics:topology:',param,':ParamName']);
end

function msg=getLabel(param)
    msg=pm_message(...
    ['sm:sli:configParameters:diagnostics:topology:',param,':Label']);
end

function msg=getInertiaName(param)
    msg=pm_message(...
    ['sm:sli:configParameters:diagnostics:inertia:',param,':ParamName']);
end

function msg=getInertiaLabel(param)
    msg=pm_message(...
    ['sm:sli:configParameters:diagnostics:inertia:',param,':Label']);
end

function msg=getBodyModelingName(param)
    msg=pm_message(...
    ['sm:sli:configParameters:diagnostics:bodyModeling:',param,':ParamName']);
end

function msg=getBodyModelingLabel(param)
    msg=pm_message(...
    ['sm:sli:configParameters:diagnostics:bodyModeling:',param,':Label']);
end

function msg=getAssmName(param)
    msg=pm_message(...
    ['sm:sli:configParameters:diagnostics:assembly:',param,':ParamName']);
end

function msg=getAssmLabel(param)
    msg=pm_message(...
    ['sm:sli:configParameters:diagnostics:assembly:',param,':Label']);
end

function msg=getActuationName(param)
    msg=pm_message(...
    ['sm:sli:configParameters:diagnostics:actuation:',param,':ParamName']);
end

function msg=getActuationLabel(param)
    msg=pm_message(...
    ['sm:sli:configParameters:diagnostics:actuation:',param,':Label']);
end



