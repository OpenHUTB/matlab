classdef HDLLUTModelInfo<FunctionApproximation.internal.datatomodeladapter.ModelInfo






    properties(Constant)
        DelayLibraryPath='simulink/Commonly Used Blocks/Delay';
        SubtractLibraryPath='simulink/Math Operations/Subtract';
        SwitchLibraryPath='simulink/Commonly Used Blocks/Switch'
        SameDTLibraryPath='simulink/Signal Attributes/Data Type Duplicate';
        SubsystemLibraryPath='simulink/Commonly Used Blocks/Subsystem';
        GainLibraryPath='simulink/Commonly Used Blocks/Gain';
        BitSliceLibraryPath='hdlsllib/Logic and Bit Operations/Bit Slice';
        ProductLibraryPath='simulink/Math Operations/Product';
        AddLibraryPath='simulink/Math Operations/Add';
        DirectLUTBlockLibraryPath='simulink/Lookup Tables/Direct Lookup Table (n-D)';
        MinWLSpacingReciprocal=18;
        ResetDelayColor='cyan';
        InheritViaBackPropagation='Inherit: Inherit via back propagation';
    end

    properties(SetAccess=immutable)
        TableValueVarName=['FunctionApproximation_TableValue_',datestr(now,'yyyymmddTHHMMSSFFF')]
        DeltaTableValueVarName=['FunctionApproximation_DeltaTableValue_',datestr(now,'yyyymmddTHHMMSSFFF')]
        DeltaXLBVarNamePrefix=['FunctionApproximation_LB_',datestr(now,'yyyymmddTHHMMSSFFF')]
        DeltaXUBVarNamePrefix=['FunctionApproximation_UB_',datestr(now,'yyyymmddTHHMMSSFFF')]
        FirstBPVarName=['FunctionApproximation_FirstBP_',datestr(now,'yyyymmddTHHMMSSFFF')]
        IndexSearchGainVarName=['FunctionApproximation_IndexSearchGain_',datestr(now,'yyyymmddTHHMMSSFFF')]
    end

    methods
        function hanldes=getDelayBlockHandles(this)
            hanldes=Simulink.findBlocksOfType(this.ModelName,'Delay');
        end

        function turnDelaysOff(this)
            handles=getDelayBlockHandles(this);
            this.setCommentState(handles,'through');
        end

        function turnDelaysOn(this)
            handles=getDelayBlockHandles(this);
            this.setCommentState(handles,'off');
        end

        function update(this,blockData)

            update@FunctionApproximation.internal.datatomodeladapter.ModelInfo(this,blockData);




            if blockData.Data{1}(1)~=0
                this.ModelWorkspace.assignin(this.getFirstBreakpointVariableName(1),blockData.Data{1}(1));
            end

            dt=blockData.InputTypes(1);
            if~fixed.internal.type.isAnyFloat(dt)
                dt.SignednessBool=0;
            end
            set_param(this.getPathForSwitchSaturationUpperBound(1),'OutDataTypeStr',this.InheritViaBackPropagation);

            ub=blockData.Data{1}(end)-blockData.Data{1}(1);
            this.ModelWorkspace.assignin(this.getDeltaXSaturationUpperBoundVariableName(1),ub);
            set_param(this.getPathForConstantSaturationUpperBound(1),'OutDataTypeStr',this.correctType(ub,blockData.StorageTypes(1)).tostringInternalFixdt());

            nPointslog2=ceil(log2(numel(blockData.Data{1})));
            wl=this.getWordlengthForReciprocalSpacing(nPointslog2);
            this.ModelWorkspace.assignin(this.getIndexSearchGainVariableName(1),fi(1/diff(blockData.Data{1}(1:2)),0,wl));
            dt=numerictype(0,wl,wl-nPointslog2);
            set_param(this.getPathForReciprocalSpacingGain(1),'OutDataTypeStr',parseDataType(dt.tostringInternalFixdt()).ResolvedString);

            tv=blockData.Data{end};
            tvdt=blockData.StorageTypes(end);
            this.ModelWorkspace.assignin(this.getTableValueVariableName(),tv);
            set_param(this.getPathForTableValueLU(),'TableDataTypeStr',parseDataType(tvdt.tostringInternalFixdt()).ResolvedString);

            deltaTV=tv(2:end)-tv(1:end-1);
            deltaTV(end+1)=0;
            deltaTVDT=this.correctType(deltaTV,tvdt);

            if strcmp(blockData.InterpolationMethod,'linear')
                this.ModelWorkspace.assignin(this.getDeltaTableValueVariableName(),deltaTV);
                set_param(this.getPathForDeltaTableValueLU(),'TableDataTypeStr',parseDataType(deltaTVDT.tostringInternalFixdt()).ResolvedString);
            end

            wlZeroIndex=wl-1;
            indexMSB=wlZeroIndex-nPointslog2;
            ubFraction=indexMSB;
            lbIndex=indexMSB+1;
            if strcmp(blockData.InterpolationMethod,'linear')
                set_param(this.getPathForFractionBitSlice(1),'lidx',int2str(ubFraction));
                set_param(this.getPathForFractionBitSlice(1),'ridx','0');
                dt=numerictype(0,ubFraction+1,ubFraction+1);
                set_param(this.getPathForIndexExtractor(1),'OutDataTypeStr',parseDataType(dt.tostringInternalFixdt()).ResolvedString);
            end
            set_param(this.getPathForIndexBitSlice(1),'lidx',int2str(wlZeroIndex));
            set_param(this.getPathForIndexBitSlice(1),'ridx',int2str(lbIndex));

            if strcmp(blockData.InterpolationMethod,'linear')
                set_param(this.getPathForAddingTableValue(),'OutDataTypeStr',parseDataType(blockData.OutputType.tostringInternalFixdt()).ResolvedString);
            else
                set_param(this.getPathForOutDTC(),'OutDataTypeStr',parseDataType(blockData.OutputType.tostringInternalFixdt()).ResolvedString);
            end
        end

        function moveDataToBlocksFromModelWorkspace(this,blockData)
            if blockData.Data{1}(1)~=0
                set_param(this.getPathForInputSubractionConstant(1),'Value',...
                fixed.internal.compactButAccurateNum2Str(this.ModelWorkspace.evalin(this.getFirstBreakpointVariableName(1))),...
                'OutDataTypeStr',this.InheritViaBackPropagation);
            end
            upperBound=fixed.internal.compactButAccurateNum2Str(this.ModelWorkspace.evalin(this.getDeltaXSaturationUpperBoundVariableName(1)));
            set_param(this.getPathForConstantSaturationUpperBound(1),'Value',upperBound);
            set_param(this.getPathForSwitchSaturationUpperBound(1),'Threshold',upperBound);
            set_param(this.getPathForReciprocalSpacingGain(1),'Gain',fixed.internal.compactButAccurateNum2Str(this.ModelWorkspace.evalin(this.getIndexSearchGainVariableName(1))));
            set_param(this.getPathForTableValueLU(),'Table',fixed.internal.compactButAccurateMat2Str(this.ModelWorkspace.evalin(this.getTableValueVariableName())));
            if strcmp(blockData.InterpolationMethod,'linear')
                set_param(this.getPathForDeltaTableValueLU(),'Table',fixed.internal.compactButAccurateMat2Str(this.ModelWorkspace.evalin(this.getDeltaTableValueVariableName())));
            end
        end

        function varName=getIndexSearchGainVariableName(this,idx)
            varName=[this.IndexSearchGainVarName,int2str(idx)];
        end

        function varName=getTableValueVariableName(this)
            varName=this.TableValueVarName;
        end

        function varName=getDeltaTableValueVariableName(this)
            varName=this.DeltaTableValueVarName;
        end

        function varName=getFirstBreakpointVariableName(this,idx)
            varName=[this.FirstBPVarName,int2str(idx)];
        end

        function varName=getDeltaXSaturationUpperBoundVariableName(this,idx)
            varName=[this.DeltaXUBVarNamePrefix,int2str(idx)];
        end

        function path=getPathForInput(this,idx)
            path=[this.getBlockPath(),'/',getNameForInput(this,idx)];
        end

        function path=getPathForOutput(this)
            path=[this.getBlockPath(),'/',getNameForOutput(this)];
        end

        function path=getPathForDelayAtInput(this,idx)
            path=[this.getBlockPath(),'/',getNameForDelayAtInput(this,idx)];
        end

        function path=getPathForSubtractAtInput(this,idx)
            path=[this.getBlockPath(),'/',getNameForSubtractAtInput(this,idx)];
        end

        function path=getPathForInputSubractionConstant(this,idx)
            path=[this.getBlockPath(),'/',getNameForInputSubractionConstant(this,idx)];
        end

        function path=getPathForSwitchSaturationUpperBound(this,idx)
            path=[this.getBlockPath(),'/',getNameForSwitchSaturationUpperBound(this,idx)];
        end

        function path=getPathForConstantSaturationUpperBound(this,idx)
            path=[this.getBlockPath(),'/',getNameForConstantSaturationUpperBound(this,idx)];
        end

        function path=getPathForSameDTAtInput(this,idx)
            path=[this.getBlockPath(),'/',getNameForSameDTAtInput(this,idx)];
        end

        function path=getPathForReciprocalSpacingGain(this,idx)
            path=[this.getBlockPath(),'/',getNameForReciprocalSpacingGain(this,idx)];
        end

        function blockName=getNameForInput(~,idx)
            blockName=['Input',int2str(idx)];
        end

        function blockName=getNameForOutput(~)
            blockName='Output';
        end

        function blockName=getNameForDelayAtInput(~,idx)
            blockName=['RegisterAtStart',int2str(idx)];
        end

        function blockName=getNameForSubtractAtInput(~,idx)
            blockName=['SubtractFirstBP',int2str(idx)];
        end

        function blockName=getNameForInputSubractionConstant(~,idx)
            blockName=['ShiftFirstBP',int2str(idx)];
        end

        function blockName=getNameForSwitchSaturationUpperBound(~,idx)
            blockName=['SaturateUpperBound',int2str(idx)];
        end

        function blockName=getNameForConstantSaturationUpperBound(~,idx)
            blockName=['UpperBound',int2str(idx)];
        end

        function blockName=getNameForSameDTAtInput(~,idx)
            blockName=['SameDT',int2str(idx)];
        end

        function blockName=getNameForReciprocalSpacingGain(~,idx)
            blockName=['ReciprocalSpacing',int2str(idx)];
        end

        function path=getPathForPreIndexSearchDelay(this,idx)
            path=[this.getBlockPath(),'/',getNameForPreIndexSearchDelay(this,idx)];
        end

        function blockName=getNameForPreIndexSearchDelay(~,idx)
            blockName=['DelayPreIndexSearch',int2str(idx)];
        end

        function path=getPathForIndexBitSlice(this,idx)
            path=[this.getBlockPath(),'/',getNameForIndexBitSlice(this,idx)];
        end

        function blockName=getNameForIndexBitSlice(~,idx)
            blockName=['IndexBitSlice',int2str(idx)];
        end

        function path=getPathForFractionBitSlice(this,idx)
            path=[this.getBlockPath(),'/',getNameForFractionBitSlice(this,idx)];
        end

        function blockName=getNameForFractionBitSlice(~,idx)
            blockName=['FractionBitSlice',int2str(idx)];
        end

        function path=getPathForIndexExtractor(this,idx)
            path=[this.getBlockPath(),'/',getNameForIndexExtractor(this,idx)];
        end

        function blockName=getNameForIndexExtractor(~,idx)
            blockName=['IndexValue',int2str(idx)];
        end

        function path=getPathForTableValueLU(this)
            path=[this.getBlockPath(),'/',getNameForTableValueLU(this)];
        end

        function blockName=getNameForTableValueLU(~)
            blockName='TableValue';
        end

        function path=getPathForResetAfterTableValueLU(this)
            path=[this.getBlockPath(),'/',getNameForResetAfterTableValueLU(this)];
        end

        function blockName=getNameForResetAfterTableValueLU(~)
            blockName='ResetPostTableValue';
        end

        function path=getPathForDeltaTableValueLU(this)
            path=[this.getBlockPath(),'/',getNameForDeltaTableValueLU(this)];
        end

        function blockName=getNameForDeltaTableValueLU(~)
            blockName='DeltaTableValue';
        end

        function path=getPathForResetAfterDeltaTableValueLU(this)
            path=[this.getBlockPath(),'/',getNameForResetAfterDeltaTableValueLU(this)];
        end

        function blockName=getNameForResetAfterDeltaTableValueLU(~)
            blockName='ResetPostDeltaTableValue';
        end

        function path=getPathForResetAfterDeltaTableValueLUForFractionLine(this)
            path=[this.getBlockPath(),'/',getNameForResetAfterDeltaTableValueLUForFractionLine(this)];
        end

        function blockName=getNameForResetAfterDeltaTableValueLUForFractionLine(~)
            blockName='ResetPostDeltaTableValueFractionLine';
        end

        function path=getPathForProductPostTableValue(this)
            path=[this.getBlockPath(),'/',getNameForProductPostTableValue(this)];
        end

        function blockName=getNameForProductPostTableValue(~)
            blockName='ProductFractionAndDeltaTableValue';
        end

        function path=getPathForAddingTableValue(this)
            path=[this.getBlockPath(),'/',getNameForAddingTableValue(this)];
        end

        function blockName=getNameForAddingTableValue(~)
            blockName='InterpolatedTableValue';
        end

        function path=getPathForDelayPostInterpolation(this)
            path=[this.getBlockPath(),'/',getNameForDelayPostInterpolation(this)];
        end

        function blockName=getNameForDelayPostInterpolation(~)
            blockName='DelayAfterInterpolation';
        end

        function path=getPathForRegisterPreProductTableValueLine(this)
            path=[this.getBlockPath(),'/',getNameForRegisterPreProductTableValueLine(this)];
        end

        function blockName=getNameForRegisterPreProductTableValueLine(~)
            blockName='RegisterPreProductTableValueLine';
        end

        function path=getPathForRegisterPostProductTableValueLine(this)
            path=[this.getBlockPath(),'/',getNameForRegisterPostProductTableValueLine(this)];
        end

        function blockName=getNameForRegisterPostProductTableValueLine(~)
            blockName='RegisterPostProductTableValueLine';
        end

        function path=getPathForRegisterPreProductDeltaTableValueLine(this)
            path=[this.getBlockPath(),'/',getNameForRegisterPreProductDeltaTableValueLine(this)];
        end

        function blockName=getNameForRegisterPreProductDeltaTableValueLine(~)
            blockName='RegisterPreProductDeltaTableValueLine';
        end

        function path=getPathForRegisterPreProductFractionLine(this)
            path=[this.getBlockPath(),'/',getNameForRegisterPreProductFractionLine(this)];
        end

        function blockName=getNameForRegisterPreProductFractionLine(~)
            blockName='RegisterPreProductFractionLine';
        end

        function path=getPathForRegisterPostProduct(this)
            path=[this.getBlockPath(),'/',getNameForRegisterPostProduct(this)];
        end

        function blockName=getNameForRegisterPostProduct(~)
            blockName='RegisterPostProduct';
        end

        function path=getPathForOutDTC(this)
            path=[this.getBlockPath(),'/',getNameForOutDTC(this)];
        end

        function blockName=getNameForOutDTC(~)
            blockName='CastToOutputType';
        end
    end

    methods(Static)
        function setCommentState(blockHandles,state)
            for iHandle=1:numel(blockHandles)
                set_param(blockHandles(iHandle),'Commented',state);
            end
        end

        function wl=getWordlengthForReciprocalSpacing(nPointslog2)
            wl=max(nPointslog2+10,FunctionApproximation.internal.datatomodeladapter.HDLLUTModelInfo.MinWLSpacingReciprocal);



        end

        function type=correctType(value,type)
            if~fixed.internal.type.isAnyFloat(type)
                type.Bias=0;
                if any(value<0)&&~type.SignednessBool
                    type.FractionLength=type.FractionLength-1;
                    type.SignednessBool=true;
                end
                if~any(value<0)&&type.SignednessBool
                    type.SignednessBool=false;
                end
                numOverflows=fixed.internal.numOverAndUnderflows(value,type);
                if numOverflows
                    type.FractionLength=type.FractionLength-1;
                end
            end
        end

        function setDelayReset(blockHandles,value)
            for idx=1:numel(blockHandles)
                blockPath=Simulink.ID.getFullName(blockHandles(idx));
                hdlset_param(blockPath,'ResetType',value);
                set_param(blockPath,'BackgroundColor',...
                FunctionApproximation.internal.datatomodeladapter.HDLLUTModelInfo.ResetDelayColor);
            end
        end

        function latency=getLatency(interpolation)







            latency=3+3*(interpolation=="Linear");
        end
    end
end


