classdef SpecificConstraint<SimulinkFixedPoint.AutoscalerConstraints.FixedPointConstraint







    properties(Constant)
        Index=SimulinkFixedPoint.AutoscalerConstraints.ConstraintIndex.SpecificConstraint;
    end
    properties(SetAccess=private)
        SpecificWL=[];
        SpecificFL=[];
    end
    properties(SetAccess=private)

        HasSignednessConflict=false;


        HasWordlengthConflict=false;


        HasFractionlengthConflict=false;
    end
    methods
        function this=SpecificConstraint(specificSigned,specificWL,specificFL)

            setSignedness(this,specificSigned);
            setWordLengths(this,specificWL);
            setFractionLengths(this,specificFL);
        end

        function outputType=snapDataType(this,inputType)








































































































































            if~hasConflict(this)
                inputSignedness=inputType.SignednessBool;
                inputWL=inputType.WordLength;
                inputFL=inputType.FractionLength;

                signednessConstraint=isSigned(this);
                wordLengthConstraints=this.SpecificWL;
                fractionLengthConstraints=this.SpecificFL;

                outputWL=inputWL;
                outputFL=inputFL;


                if isempty(this.SpecificSigned)
                    outputSignedness=inputSignedness;
                else
                    outputSignedness=signednessConstraint;
                end

                maxRangeBitCalculator=...
                SimulinkFixedPoint.RangeBitCalculator.Factory.getCalculator(...
                SimulinkFixedPoint.RangeBitCalculator.Type.Max);

                inputRangeBits=getRangeBits(maxRangeBitCalculator,...
                SimulinkFixedPoint.RangeBitCalculator.ContextAdapter.BinaryPointNumericType(inputType));

                if~isempty(this.SpecificWL)&&~isempty(this.SpecificFL)

                    context=SimulinkFixedPoint.RangeBitCalculator.ContextAdapter.SpecificConstraint(this);
                    allRangeBitsCalculator=...
                    SimulinkFixedPoint.RangeBitCalculator.Factory.getCalculator(...
                    SimulinkFixedPoint.RangeBitCalculator.Type.AllCombinations);
                    allRangeBits=getRangeBits(allRangeBitsCalculator,context);















                    correctionBit=isempty(this.SpecificSigned)&&inputSignedness;

                    if max(allRangeBits(:))>=inputRangeBits



                        wordLengths=getWordLengths(context);
                        [~,wordLengthClosestIndices]=sort(abs(wordLengths-inputWL));
                        wordLengths=wordLengths(wordLengthClosestIndices);
                        allRangeBits=allRangeBits(:,wordLengthClosestIndices);
                        fractionLengths=getFractionLengths(context);
                        nColumns=numel(wordLengths);
                        validIndices=allRangeBits>=(inputRangeBits+correctionBit);
                        for iColumn=1:nColumns
                            fractionLengthIndices=validIndices(:,iColumn);
                            if any(fractionLengthIndices)
                                outputWL=wordLengths(iColumn);

                                validFractionLengths=fliplr(fractionLengths(fractionLengthIndices));
                                [~,fractionLengthClosestIndices]=sort(abs(validFractionLengths-inputFL));




                                validFractionLengths=validFractionLengths(fractionLengthClosestIndices);
                                outputFL=validFractionLengths(1);
                                break;
                            end
                        end
                    else
                        outputWL=max(wordLengthConstraints);
                        outputFL=min(fractionLengthConstraints);
                    end
                elseif~isempty(this.SpecificWL)&&isempty(this.SpecificFL)

                    if inputWL>wordLengthConstraints(end)
                        outputWL=wordLengthConstraints(end);
                    elseif inputWL<wordLengthConstraints(1)
                        outputWL=wordLengthConstraints(1);
                    else
                        outputWL=min(wordLengthConstraints(wordLengthConstraints>=inputWL));
                    end
                    outputFL=min(outputWL-outputSignedness-inputRangeBits,inputFL);
                elseif isempty(this.SpecificWL)&&~isempty(this.SpecificFL)

                    if inputFL>fractionLengthConstraints(end)
                        outputFL=fractionLengthConstraints(end);
                    elseif inputFL<fractionLengthConstraints(1)
                        outputFL=fractionLengthConstraints(1);
                    else
                        outputFL=max(fractionLengthConstraints(fractionLengthConstraints<=inputFL));
                    end
                    outputWL=max(inputRangeBits+outputSignedness+outputFL,inputWL);
                    if outputWL>this.MaximumWordLength
                        diffWL=outputWL-this.MaximumWordLength;
                        outputWL=this.MaximumWordLength;
                        outputFL=outputFL-diffWL;
                        outputFL=max(fractionLengthConstraints(fractionLengthConstraints<=outputFL));
                        if isempty(outputFL)
                            outputFL=fractionLengthConstraints(1);
                        end
                    end
                else

                    outputWL=min(inputWL,this.MaximumWordLength);
                    if(outputWL-outputSignedness-inputFL)>=inputRangeBits
                        outputFL=inputFL;
                    else
                        outputFL=outputWL-outputSignedness-inputRangeBits;
                    end
                end

                outputType=inputType;
                outputType.SignednessBool=outputSignedness;
                outputType.WordLength=outputWL;
                outputType.FractionLength=outputFL;


                if fixed.isSignedOneBit(outputType)
                    outputType.WordLength=outputType.WordLength+1;
                    if isempty(this.SpecificFL)
                        outputType.FractionLength=outputType.FractionLength+1;
                    end
                end
            else
                outputType=inputType;
            end
        end

        function flag=hasConflict(this)


            flag=this.HasSignednessConflict...
            ||this.HasWordlengthConflict...
            ||this.HasFractionlengthConflict;
        end

        function comments=getComments(this)




            if isempty(this.SpecificSigned)&&isempty(this.SpecificWL)&&isempty(this.SpecificFL)
                comments={''};
            else
                if isempty(this.SpecificSigned)&&isempty(this.SpecificWL)&&this.SpecificFL==0
                    comments={getString(message('SimulinkFixedPoint:autoscaling:GetAutoscalerConstraint',...
                    this.ElementOfObject,getFullName(this),getString(message('SimulinkFixedPoint:autoscaling:ConstrainedintegerOnly'))))};
                elseif isempty(this.SpecificSigned)&&~isempty(this.SpecificFL)&&this.SpecificFL==0&&all(ismember(this.SpecificWL,[8,16,32]))





                    comments={getString(message('SimulinkFixedPoint:autoscaling:GetAutoscalerConstraint',...
                    this.ElementOfObject,getFullName(this),getString(message('SimulinkFixedPoint:autoscaling:ConstrainedbuiltinIntegerOnly'))))};
                elseif isempty(this.SpecificSigned)&&~isempty(this.SpecificWL)&&isempty(this.SpecificFL)
                    minWL=min(this.SpecificWL);
                    maxWL=max(this.SpecificWL);
                    comments={getString(message('SimulinkFixedPoint:autoscaling:GetAutoscalerConstraint',...
                    this.ElementOfObject,getFullName(this),...
                    getString(message('SimulinkFixedPoint:autoscaling:ConstrainedwordlengthOnly',...
                    minWL,...
                    maxWL))))};
                elseif~isempty(this.SpecificSigned)
                    if strcmpi(this.SpecificSigned,'Signed')
                        comments={getString(message('SimulinkFixedPoint:autoscaling:GetAutoscalerConstraint',...
                        this.ElementOfObject,getFullName(this),getString(message('SimulinkFixedPoint:autoscaling:signedOnly'))))};
                    elseif strcmpi(this.SpecificSigned,'Unsigned')
                        comments={getString(message('SimulinkFixedPoint:autoscaling:GetAutoscalerConstraint',...
                        this.ElementOfObject,getFullName(this),getString(message('SimulinkFixedPoint:autoscaling:unsignedOnly'))))};
                    else
                        comments={''};
                    end
                else
                    comments={''};
                end
            end
        end

        function comments=getConflictComments(this)

            comments=getConflictComments@SimulinkFixedPoint.AutoscalerConstraints.FixedPointConstraint(this);
            if this.HasSignednessConflict
                comments=[comments,{getString(message('SimulinkFixedPoint:autoscaling:conflictingConstraints',...
                'signedness'))}];
            end

            if this.HasWordlengthConflict
                comments=[comments,{getString(message('SimulinkFixedPoint:autoscaling:conflictingConstraints',...
                'word length'))}];
            end

            if this.HasFractionlengthConflict
                comments=[comments,{getString(message('SimulinkFixedPoint:autoscaling:conflictingConstraints',...
                'fraction length'))}];
            end
        end
    end

    methods(Hidden)

        function validateSpecificWL(this,val)
            if~isempty(val)&&(~isnumeric(val)||any(isnan(val(:)))||~max(isfinite(val(:)))||any(~isreal(val(:)))||max(val(:))>this.MaximumWordLength||min(val(:))<this.MinimumWordLength)
                DAStudio.error('SimulinkFixedPoint:autoscaling:invalidSpecificWL');
            end
        end
        function validateSpecificFL(~,val)
            if~isempty(val)&&(~isnumeric(val)||any(isnan(val(:)))||~max(isfinite(val(:)))||any(~isreal(val(:))))
                DAStudio.error('SimulinkFixedPoint:autoscaling:invalidSpecificFL');
            end
        end
        function setWordLengths(this,specificWL)

            validateSpecificWL(this,specificWL);
            this.SpecificWL=sort(specificWL);
        end
        function setFractionLengths(this,specificFL)

            validateSpecificFL(this,specificFL);
            this.SpecificFL=sort(specificFL);
        end
        function setHasSignednessConflict(this,flag)
            this.HasSignednessConflict=flag;
        end
        function setHasWordlengthConflict(this,flag)
            this.HasWordlengthConflict=flag;
        end
        function setHasFractionlengthConflict(this,flag)
            this.HasFractionlengthConflict=flag;
        end
    end
end




