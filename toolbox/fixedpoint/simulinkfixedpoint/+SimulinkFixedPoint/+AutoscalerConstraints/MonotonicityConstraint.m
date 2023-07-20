classdef MonotonicityConstraint<SimulinkFixedPoint.AutoscalerConstraints.CompositeFixedPointConstraint












    properties(Constant)
        Index=SimulinkFixedPoint.AutoscalerConstraints.ConstraintIndex.MonotonicityConstraint;
    end
    properties(SetAccess=private)
        DataTypeCreator;
    end
    methods
        function this=MonotonicityConstraint(dataTypeCreator)
            dataType=dataTypeCreator.DataType;
            wordLength=dataType.WordLength;
            fractionLength=dataType.FractionLength;
            wordLengthSet=wordLength:this.MaximumWordLength;
            nWordLengthSet=numel(wordLengthSet);

            maxValue=-Inf;
            values=dataTypeCreator.Values;
            for ii=1:numel(values)
                maxValue=max(maxValue,max(abs(double(values{ii}))));
            end



            if dataType.SignednessBool

                signedness="Signed";
                signedBit=1;
            else
                signedness=[];
                signedBit=0;
            end



            nWordLengths=nWordLengthSet;

            childConstraint=repmat(SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint.empty,1,nWordLengths);
            for ii=1:nWordLengths

                fractionLengthsSet=fractionLength(1)+(0:wordLengthSet(ii)-wordLengthSet(1));
                count=numel(fractionLengthsSet);
                success=true;
                while success










                    newFL=fractionLengthsSet(count)+1;
                    intergerLength=ceil(log2(maxValue+2^-newFL));
                    if intergerLength+signedBit+newFL<=wordLengthSet(ii)
                        fractionLengthsSet(count+1)=newFL;
                        count=count+1;
                    else
                        success=false;
                    end
                end
                childConstraint(ii)=SimulinkFixedPoint.AutoscalerConstraints.SpecificConstraint(signedness,wordLengthSet(ii),fractionLengthsSet);
            end


            this.ChildConstraint=childConstraint;
            this.DataTypeCreator=dataTypeCreator;
            setSignedness(this,signedness);
        end

        function flag=hasConflict(this)
            flag=isempty(this.ChildConstraint);
        end

        function comments=getConflictComments(this)
            comments=getConflictComments@SimulinkFixedPoint.AutoscalerConstraints.FixedPointConstraint(this);
            if hasConflict(this)
                comments=[comments,{DAStudio.message('SimulinkFixedPoint:autoscaling:clashWithMonotonicityConstraint')}];
            end
        end

        function comments=getComments(this)
            comments={DAStudio.message('SimulinkFixedPoint:autoscaling:GetMonotonicityConstraint',...
            this.ElementOfObject,getFullName(this))};
        end

        function outputType=snapDataType(this,inputType)


























            if~hasConflict(this)
                if this.ChildConstraint(end).SpecificWL(end)<inputType.WordLength
                    outputType=snapDataType(this.ChildConstraint(end),inputType);
                else
                    maxRangeBitCalculator=...
                    SimulinkFixedPoint.RangeBitCalculator.Factory.getCalculator(...
                    SimulinkFixedPoint.RangeBitCalculator.Type.Max);

                    dataTypeRangeBits=getRangeBits(maxRangeBitCalculator,...
                    SimulinkFixedPoint.RangeBitCalculator.ContextAdapter.BinaryPointNumericType(inputType));

                    correctionBit=isempty(this.SpecificSigned)&&inputType.SignednessBool;

                    nConstraints=numel(this.ChildConstraint);
                    for iConstraint=1:nConstraints
                        childConstraint=this.ChildConstraint(iConstraint);


                        if childConstraint.SpecificWL(1)>=inputType.WordLength
                            context=SimulinkFixedPoint.RangeBitCalculator.ContextAdapter.SpecificConstraint(childConstraint);
                            maxRangeBits=getRangeBits(maxRangeBitCalculator,context);
                            rangeBitsAccomodated=dataTypeRangeBits<=maxRangeBits-correctionBit;
                            if rangeBitsAccomodated||(iConstraint==nConstraints)
                                outputType=snapDataType(childConstraint,inputType);
                                break;
                            end
                        end
                    end
                end
            else
                outputType=inputType;
            end
        end
    end
end


