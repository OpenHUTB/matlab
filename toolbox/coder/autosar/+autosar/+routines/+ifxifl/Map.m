classdef Map<autosar.routines.RoutineBlock




    methods
        function description=getBlockDescription(~)
            description=message('autosarstandard:routines:MapDescription').getString();
        end

        function type=getBlockType(~)
            type='Map';
        end

        function sourceBlock=getSourceBlock(~)
            sourceBlock='simulink/Lookup Tables/n-D Lookup Table';
        end

        function constantParameters=getConstantParameters(~)
            constantParameters=containers.Map();
            constantParameters('NumberOfTableDimensions')='2';
            constantParameters('ExtrapMethod')='Clip';
            constantParameters('RemoveProtectionInput')='off';
            constantParameters('UseLastTableValue')='on';
        end

        function validRoutines=getValidRoutines(~)
            validRoutines={...
            'Ifx_IntIpoMap',...
            'Ifx_IntIpoFixMap',...
            'Ifx_IntIpoFixIMap',...
            'Ifx_IntLkUpMap',...
            'Ifx_IntLkUpFixMap',...
            'Ifx_IntLkUpFixIMap',...
            'Ifx_IntLkUpBaseMap',...
            'Ifx_IntLkUpFixBaseMap',...
            'Ifx_IntLkUpFixIBaseMap',...
            'Ifl_IntIpoMap'};
        end
    end

    methods
        function[routine,fixitCommand,messageID]=getRoutineFromBlockSettings(self,blkH)
            fixitCommand='';
            messageID='';
            if autosar.routines.RoutineBlock.isConfiguredForIFX(blkH)

                isBase=strcmp(get_param(blkH,'InterpMethod'),'Flat');
                isIpo=strcmp(get_param(blkH,'InterpMethod'),'Linear point-slope');
                isLkUp=strcmp(get_param(blkH,'InterpMethod'),'Nearest');

                if isLkUp
                    mode='LkUp';
                    baseOpt='';
                elseif isIpo
                    mode='Ipo';
                    baseOpt='';
                elseif isBase
                    mode='LkUp';
                    baseOpt='Base';
                else
                    routine='No Valid Routine';
                    return;
                end
                modelH=bdroot(blkH);
                if strcmp(get_param(blkH,'DataSpecification'),'Table and breakpoints')
                    if strcmp(get_param(blkH,'BreakpointsSpecification'),'Explicit values')
                        bpSpacing='';
                    elseif strcmp(get_param(modelH,'DefaultParameterBehavior'),'Tunable')


                        bpSpacing='FixI';
                    else
                        bpSpacingParam1Value=...
                        autosar.routines.ifxifl.Utils.getParamNumericalValueFromBlock(blkH,'BreakpointsForDimension1Spacing');
                        bpSpacingParam2Value=...
                        autosar.routines.ifxifl.Utils.getParamNumericalValueFromBlock(blkH,'BreakpointsForDimension2Spacing');

                        if autosar.utils.Math.isPow2(bpSpacingParam1Value)&&...
                            autosar.utils.Math.isPow2(bpSpacingParam2Value)
                            bpSpacing='Fix';
                        else
                            bpSpacing='FixI';
                        end
                    end
                else
                    lookupObject=get_param(blkH,'LookupTableObject');
                    [exists,lkUpObj]=autosar.utils.Workspace.objectExistsInModelScope(modelH,lookupObject);
                    if~exists
                        routine='No Valid Routine';
                        return;
                    end


                    indexSearchMode=get_param(blkH,'IndexSearchMode');
                    if strcmp(indexSearchMode,'Evenly spaced points')
                        if~strcmp(lkUpObj.BreakpointsSpecification,'Even spacing')
                            [~,spacingType1,spacing1]=fixpt_evenspace_cleanup(lkUpObj.Breakpoints(1).Value,lkUpObj.Breakpoints(1).DataType);
                            [~,spacingType2,spacing2]=fixpt_evenspace_cleanup(lkUpObj.Breakpoints(2).Value,lkUpObj.Breakpoints(2).DataType);
                            if~strcmp(spacingType1,DAStudio.message('SimulinkFixedPoint:datatyperules:EvenSpacing'))...
                                ||~strcmp(spacingType2,DAStudio.message('SimulinkFixedPoint:datatyperules:EvenSpacing'))
                                routine='No Valid Routine';
                                messageID='Simulink:blocks:LookupTableMismatchEvenspacingSpecification';
                                return;
                            end
                        else
                            spacing1=lkUpObj.Breakpoints(1).Spacing;
                            spacing2=lkUpObj.Breakpoints(2).Spacing;
                        end

                        if autosar.utils.Math.isPow2(spacing1)...
                            &&autosar.utils.Math.isPow2(spacing2)
                            bpSpacing='Fix';
                        else
                            bpSpacing='FixI';
                        end
                    else
                        if strcmp(lkUpObj.BreakpointsSpecification,'Even spacing')
                            routine='No Valid Routine';
                            messageID='Simulink:blocks:LookupTableMismatchEvenspacingSpecification';
                            return;
                        end

                        bpSpacing='';
                    end
                end

                routine=['Ifx_Int',mode,bpSpacing,baseOpt,'Map'];
                return;
            elseif autosar.routines.RoutineBlock.isConfiguredForIFL(blkH)
                routine='Ifl_IntIpoMap';

                if~strcmp(get_param(blkH,'InterpMode'),'Linear point-slope')
                    routine='No Valid Routine';
                    fixitCommand=self.genSetParamFixit(blkH,'InterpMode','Linear point-slope');
                    messageID='autosarstandard:routines:IflIncorrectInterpMode';
                    return;
                end

                if strcmp(get_param(blkH,'DataSpecification'),'Table and breakpoints')
                    if~strcmp(get_param(blkH,'BreakpointsSpecification'),'Explicit values')
                        routine='No Valid Routine';
                        fixitCommand=self.genSetParamFixit(blkH,'BreakpointsSpecification','Explicit values');
                        messageID='autosarstandard:routines:IflIncorrectBreakpointsSpecification';
                        return;
                    end
                else
                    lookupObject=get_param(blkH,'LookupTableObject');
                    modelH=bdroot(blkH);
                    [exists,lkUpObj]=autosar.utils.Workspace.objectExistsInModelScope(modelH,lookupObject);
                    if~exists
                        routine='No Valid Routine';
                        return;
                    end

                    if~strcmp(lkUpObj.BreakpointsSpecification,'Explicit values')
                        routine='No Valid Routine';
                        messageID='autosarstandard:routines:IflObjectIncorrectBreakpointsSpecification';
                        return;
                    end
                end

                return;
            else
                assert(false,'Expected IFX or IFL to be specified');
            end
        end

        function setupSignalValidation(~,blkH)
            if(get_param(blkH,'DataSpecification')=="Lookup table object"...
                &&get_param(blkH,'OutDataTypeStr')~="Inherit: Inherit from 'Table data'")

                try
                    set_param(blkH,'OutDataTypeStr','Inherit: Inherit from ''Table data''');
                catch E
                    autosar.routines.RoutineBlock.logErrorCallback(blkH,E);
                end
                return;
            end

            if strcmpi(get_param(blkH,'BreakpointsSpecification'),'even spacing')

                set_param(blkH,'OutDataTypeStr','Inherit: Same as first input');
                set_param(blkH,'TableDataTypeStr','Inherit: Same as output');
                return;
            end

            tableDataTypeStr=get_param(blkH,'TableDataTypeStr');
            if strcmp(tableDataTypeStr,'Inherit: Same as output')
                set_param(blkH,'OutDataTypeStr','Inherit: Inherit via back propagation');
            else
                set_param(blkH,'OutDataTypeStr',tableDataTypeStr);
            end
        end

        function updateSignalValidation(~,blkH,mode)
            In1=Simulink.DataConstraints;
            In2=Simulink.DataConstraints;
            Out=Simulink.DataConstraints;

            In1.clearForPort(getfullname(blkH),'Input',1);
            In2.clearForPort(getfullname(blkH),'Input',2);
            Out.clearForPort(getfullname(blkH),'Output',1);

            if autosar.routines.RoutineBlock.isConfiguredForIFX(blkH)
                if strcmp(get_param(bdroot(blkH),'ArrayLayout'),'Row-major')







                    In1.GreaterOrEqualWLExcludingSignBitThanInput=2;
                    In1.setDataConstraintsToPort(getfullname(blkH),'Input',1);
                else


                    In2.GreaterOrEqualWLExcludingSignBitThanInput=1;
                    In2.setDataConstraintsToPort(getfullname(blkH),'Input',2);
                end
            end






            if~strcmp(get_param(blkH,'BreakpointsForDimension1DataTypeStr'),'Inherit: Same as corresponding input')...
                ||~strcmp(get_param(blkH,'BreakpointsForDimension2DataTypeStr'),'Inherit: Same as corresponding input')
                if strcmpi(mode,'warn')
                    MSLDiagnostic('autosarstandard:routines:mapBreakpointDataTypeSpecified',getfullname(blkH),blkH).reportAsWarning;
                else
                    autosar.validation.AutosarUtils.reportErrorWithFixit('autosarstandard:routines:mapBreakpointDataTypeSpecified',getfullname(blkH),blkH);
                end
            end

        end
    end

    methods(Access=protected)
        function applyDefaultSettings(~,blkH)
            set_param(blkH,'Table','[4 5 6;16 19 20;10 18 23]');
            set_param(blkH,'BlockKeywords',{'Lookup','IFX','IFL','Routine','AUTOSAR'});
            set_param(blkH,'TableDataTypeStr','Inherit: Same as output');
            set_param(blkH,'BreakpointsForDimension1DataTypeStr','Inherit: Same as corresponding input');
            set_param(blkH,'BreakpointsForDimension2DataTypeStr','Inherit: Same as corresponding input');
            set_param(blkH,'InputSameDT','off');
            set_param(blkH,'IntermediateResultsDataTypeStr','Inherit: Same as output');
            set_param(blkH,'InternalRulePriority','Precision');
            set_param(blkH,'FractionDataTypeStr','fixdt(0,16,16)');
        end

        function populateMask(self,maskObj,blkH)
            maskObj.Type=self.getBlockType();
            maskObj.Description=self.getBlockDescription();

            maskBuilder=autosar.routines.ifxifl.IFXIFLMaskBuilder(blkH);

            maskBuilder.createRoutineImplParameter(maskObj,'autosar.routines.ifxifl.Map');
            maskBuilder.setBlkMaskTitle(maskObj);
            maskBuilder.createMaskHeader(maskObj,self.getValidRoutines());
            maskBuilder.createMaskTabs(maskObj);

            maskBuilder.createTableSpecification(maskObj,'Tab1',...
            'DataSpecification','LookupTableObject','Table');
            maskBuilder.createBreakpointSpecification(maskObj,'Tab1',2,'DataSpecification');
            maskBuilder.createLookupTableEditButton(maskObj,'Tab1');

            maskBuilder.createIndexSearchSpecification(maskObj,'Tab2',{'Linear search','Binary search','Evenly spaced points'});
            maskBuilder.createInterpolationSpecification(maskObj,'Tab2',{'Linear point-slope','Flat','Nearest'});

            maskBuilder.createLookupDataTypeSpecification(maskObj,'Tab3');
            maskBuilder.createBreakpointDataTypeSpecification(maskObj,'Tab3',2);

            targetRoutineLibParam=maskObj.getParameter('TargetRoutineLibrary');
            targetLibCallback=targetRoutineLibParam.Callback;
            targetRoutineLibParam.Callback=[targetLibCallback,'autosar.routines.RoutineCallbacks.setFractionDataTypeStr(gcb);'];

            maskBuilder.createLookupTableWidget(maskObj,2);

            maskBuilder.createPortConstraints(maskObj,{'input_1','input_2','output_1'});

            maskBuilder.applyMaskInitialization(maskObj);
            maskBuilder.setHelpTarget(maskObj,'autosar_map_block');
            self.applyAUTOSARFooter(maskObj);
        end
    end
end



