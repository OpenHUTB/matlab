function c=getSystemObjectConstraintsForF2F()




























    c=containers.Map();

    c('dsp.ArrayVectorAdder')=getArrayVectorAdderF2FConstraints();
    c('dsp.BiquadFilter')=getBiquadFilterF2FConstraints();
    c('dsp.FIRDecimator')=getFIRDecimatorF2FConstraints();
    c('dsp.FIRInterpolator')=getFIRInterpolatorF2FConstraints();
    c('dsp.FIRRateConverter')=getFIRRateConverterF2FConstraints();
    c('dsp.IIRFilter')=getIIRFilterF2FConstraints();
    c('dsp.LowerTriangularSolver')=getLowerTriangularSolverF2FConstraints();
    c('dsp.LUFactor')=getLUFactorF2FConstraints();
    c('dsp.UpperTriangularSolver')=getUpperTriangularSolverF2FConstraints();
    c('dsp.VariableFractionalDelay')=getVariableFractionalDelayF2FConstraints();
    c('dsp.Window')=getWindowF2FConstraints();

end

function value=getArrayVectorAdderF2FConstraints()
    value=struct();
    value.CustomAccumulatorDataType.Signedness='Auto';
    value.CustomOutputDataType.Signedness='Auto';
end

function value=getBiquadFilterF2FConstraints()
    value=struct();
    value.CustomMultiplicandDataType.Signedness='Auto';
    value.CustomSectionInputDataType.Signedness='Auto';
    value.CustomSectionOutputDataType.Signedness='Auto';
    value.CustomNumeratorProductDataType.Signedness='Auto';
    value.CustomDenominatorProductDataType.Signedness='Auto';
    value.CustomNumeratorAccumulatorDataType.Signedness='Auto';
    value.CustomDenominatorAccumulatorDataType.Signedness='Auto';
    value.CustomStateDataType.Signedness='Auto';
    value.CustomOutputDataType.Signedness='Auto';
end

function value=getFIRDecimatorF2FConstraints()
    value=struct();
    value.CustomProductDataType.Signedness='Auto';
    value.CustomAccumulatorDataType.Signedness='Auto';
    value.CustomOutputDataType.Signedness='Auto';
end

function value=getFIRInterpolatorF2FConstraints()
    value=getFIRDecimatorF2FConstraints();
end

function value=getFIRRateConverterF2FConstraints()
    value=getFIRDecimatorF2FConstraints();
end

function value=getLowerTriangularSolverF2FConstraints()
    value=struct();
    value.CustomProductDataType.Signedness='Auto';
    value.CustomAccumulatorDataType.Signedness='Auto';
    value.CustomOutputDataType.Signedness='Auto';
end

function value=getLUFactorF2FConstraints()
    value=getLowerTriangularSolverF2FConstraints();
end

function value=getUpperTriangularSolverF2FConstraints()
    value=getLowerTriangularSolverF2FConstraints();
end

function value=getIIRFilterF2FConstraints()
    value=struct();
    value.CustomNumeratorProductDataType.Signedness='Auto';
    value.CustomDenominatorProductDataType.Signedness='Auto';
    value.CustomNumeratorAccumulatorDataType.Signedness='Auto';
    value.CustomDenominatorAccumulatorDataType.Signedness='Auto';
    value.CustomStateDataType.Signedness='Auto';
    value.CustomOutputDataType.Signedness='Auto';
    value.CustomMultiplicandDataType.Signedness='Auto';
end

function value=getVariableFractionalDelayF2FConstraints()
    value=struct();
    value.CustomProductPolynomialValueDataType.Signedness='Auto';
    value.CustomAccumulatorPolynomialValueDataType.Signedness='Auto';
    value.CustomMultiplicandPolynomialValueDataType.Signedness='Auto';
    value.CustomProductDataType.Signedness='Auto';
    value.CustomAccumulatorDataType.Signedness='Auto';
    value.CustomOutputDataType.Signedness='Auto';
end

function value=getWindowF2FConstraints()
    value=struct();
    value.CustomProductDataType.Signedness='Auto';
    value.CustomOutputDataType.Signedness='Auto';
end


