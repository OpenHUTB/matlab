classdef DefinitionDomain<handle









    properties(SetAccess=?DataTypeOptimization.DimensionalityReductionStrategies.DimensionalityReductionStrategy)
signedness
fractionWidthVector
wordLengthVector
slopeAdjustmentFactor
bias
    end

    properties(SetAccess=private,Hidden)
dynamicRange
constraintSignedness
constraintWordLengths
constraintAllowableFractionCell
    end

    methods

        function this=DefinitionDomain(dynamicRange,constraint,safetyMargin)

            this.dynamicRange=dynamicRange.*(1+(safetyMargin/100));


            constraint=DataTypeOptimization.DataTypeConstraintsWrapper(constraint);

            this.constraintSignedness=constraint.isSigned;
            [this.constraintWordLengths,this.constraintAllowableFractionCell]=constraint.getAllowableWordLengths();


            this.calculateDomain();
        end

        function setSlopeAndBias(this,slopeAdjustmentFactor,bias)
            this.slopeAdjustmentFactor=slopeAdjustmentFactor;
            this.bias=bias;



            this.calculateSignedness();




            dIndex=1;
            cIndex=1;
            while cIndex<=length(this.constraintWordLengths)&&dIndex<=length(this.wordLengthVector)
                if this.wordLengthVector(dIndex)==this.constraintWordLengths(cIndex)
                    this.fractionWidthVector(dIndex)=this.calculateFraction(this.constraintWordLengths(cIndex),this.constraintAllowableFractionCell{cIndex});
                    dIndex=dIndex+1;
                end
                cIndex=cIndex+1;
            end
        end
    end

    methods(Hidden)
        function effectiveRange=getEffectiveRange(this)
            effectiveRange=this.dynamicRange;
            if~isempty(this.slopeAdjustmentFactor)&&~isempty(this.bias)
                effectiveRange=(effectiveRange-this.bias)./this.slopeAdjustmentFactor;
            end
        end

        function calculateDomain(this)


            this.calculateSignedness();


            this.calculateFractionVector();

        end

        function calculateSignedness(this)


            this.signedness=any(this.getEffectiveRange()<0)||this.constraintSignedness;
        end

        function calculateFractionVector(this)


            this.wordLengthVector=this.constraintWordLengths;

            this.fractionWidthVector=NaN*zeros(numel(this.wordLengthVector),1);
            for wIndex=1:numel(this.wordLengthVector)
                this.fractionWidthVector(wIndex)=...
                this.calculateFraction(this.wordLengthVector(wIndex),this.constraintAllowableFractionCell{wIndex});
            end


            infIndex=isinf(this.fractionWidthVector);
            this.fractionWidthVector(infIndex)=[];
            this.wordLengthVector(infIndex)=[];


        end

        function fl=calculateFraction(this,allowableWordLength,allowableFractionLengths)


            effectiveRange=this.getEffectiveRange();
            fl=fixed.DataTypeSelector.getfl(min(effectiveRange),max(effectiveRange),allowableWordLength,this.signedness);
            afl=allowableFractionLengths(allowableFractionLengths<=fl);
            if~isempty(afl)
                fl=max(afl);
            end
        end

        function show(this)

            fprintf('\t Definition domain: \n');
            fprintf('\t Dynamic Range: [%f, %f]\n',this.dynamicRange(1),this.dynamicRange(2));
            fprintf('\t\t - signedness: %i\n',this.signedness);
            fprintf('\t\t - word lengths: ');
            fprintf('%i ',this.wordLengthVector);
            fprintf('\n');
            fprintf('\t\t - fraction lengths: ');
            fprintf('%i ',this.fractionWidthVector);
            fprintf('\n\n');
        end

    end

end
