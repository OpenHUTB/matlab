function ReplaceSFcnWeightedMovingAverage(block,h)







    if askToReplace(h,block)
        oldEntries=GetMaskEntries(block);
        coef=oldEntries{1};
        initialCond=oldEntries{2};
        sampleTime=oldEntries{3};
        LockScaleValue=oldEntries{8};
        RndMethValue=oldEntries{9};
        DoSaturValue=oldEntries{10};
        GainDataTypeStr=oldEntries{11};
        OutDataTypeStrValue=oldEntries{4};
        coefUseInternalRule=strcmpi(GainDataTypeStr,'Inherit: Inherit via internal rule');
        outputUseInternalRule=strcmpi(OutDataTypeStrValue,'Inherit: Inherit via internal rule');
        outputUseBackProp=strcmpi(OutDataTypeStrValue,'Inherit: Inherit via back propagation');
        okToReplace=true;

        if coefUseInternalRule
            GainDataTypeStr='Inherit: Same word length as input';
        else
            obj=eval(GainDataTypeStr);
            if(isa(obj,'Simulink.NumericType')||isa(obj,'NumericType'))
                if strcmpi(obj.DataTypeMode,'Fixed-point: slope and bias scaling')
                    biasNotSupported=(obj.Bias~=0);
                    slope=obj.Slope;
                    logSlope=log2(slope);
                    slopeNotSupported=(floor(logSlope)~=logSlope);
                    if(biasNotSupported||slopeNotSupported)
                        okToReplace=false;
                    end
                end
            elseif isstruct(obj)
                okToReplace=false;
                fieldNames=fieldnames(obj);
                if strcmp(fieldNames(1),'Class')&&strcmp(fieldNames(2),'IsSigned')&&...
                    strcmp(fieldNames(3),'MantBits')
                    if strcmp(obj.Class,'FIX')
                        okToReplace=true;
                    end
                end
            else
                okToReplace=false;
            end
        end

        if outputUseInternalRule
            ProductTypeStrValue='Inherit: Inherit via internal rule';
            AccumTypeStrValue='Inherit: Same as product output';
            OutDataTypeStrValue='Inherit: Same as accumulator';
        elseif outputUseBackProp
            okToReplace=false;
        else
            ProductTypeStrValue=OutDataTypeStrValue;
            AccumTypeStrValue=OutDataTypeStrValue;
            obj=eval(OutDataTypeStrValue);
            if(isa(obj,'Simulink.NumericType')||isa(obj,'NumericType'))
                if strcmpi(obj.DataTypeMode,'Fixed-point: slope and bias scaling')
                    biasNotSupported=(obj.Bias~=0);
                    slope=obj.Slope;
                    logSlope=log2(slope);
                    slopeNotSupported=(floor(logSlope)~=logSlope);
                    if(biasNotSupported||slopeNotSupported)
                        okToReplace=false;
                    end
                end
            else
                okToReplace=false;
            end
        end

        if okToReplace
            funcSet=uReplaceBlock(h,block,'built-in/DiscreteFir',...
            'NumCoeffs',coef,...
            'IC',initialCond,...
            'sampletime',sampleTime,...
            'CoefDataTypeStr',GainDataTypeStr,...
            'ProductDataTypeStr',ProductTypeStrValue,...
            'AccumDataTypeStr',AccumTypeStrValue,...
            'OutDataTypeStr',OutDataTypeStrValue,...
            'LockScale',LockScaleValue,...
            'RndMeth',RndMethValue,...
            'SaturateOnIntegerOverflow',DoSaturValue);

            appendTransaction(h,block,h.ReplaceBlockReasonStr,{funcSet});
        end

    end

end
