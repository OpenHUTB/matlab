classdef Curve<autosar.routines.RoutineBlock




    methods
        function description=getBlockDescription(~)
            description=message('autosarstandard:routines:CurveDescription').getString();
        end

        function type=getBlockType(~)
            type='Curve';
        end

        function sourceBlock=getSourceBlock(~)
            sourceBlock='simulink/Lookup Tables/n-D Lookup Table';
        end

        function constantParameters=getConstantParameters(~)
            constantParameters=containers.Map();
            constantParameters('NumberOfTableDimensions')='1';
            constantParameters('ExtrapMethod')='Clip';
            constantParameters('RemoveProtectionInput')='off';
            constantParameters('UseLastTableValue')='on';
        end

        function validRoutines=getValidRoutines(~)
            validRoutines={'Ifx_IntIpoCur',...
            'Ifx_IntIpoFixCur',...
            'Ifx_IntIpoFixICur',...
            'Ifx_IntLkUpCur',...
            'Ifx_IntLkUpFixCur',...
            'Ifx_IntLkUpFixICur',...
            'Ifl_IntIpoCur'};
        end
    end

    methods
        function[routine,fixitCommand,messageID]=getRoutineFromBlockSettings(self,blkH)
            blkH=get_param(blkH,'Handle');
            fixitCommand='';
            messageID='';
            if autosar.routines.RoutineBlock.isConfiguredForIFX(blkH)
                isLkUp=strcmp(get_param(blkH,'InterpMethod'),'Flat');
                isIpo=strcmp(get_param(blkH,'InterpMethod'),'Linear point-slope');
                if~isLkUp&&~isIpo
                    routine='No Valid Routine';
                    return;
                end
                if isLkUp,mode='LkUp';end
                if isIpo,mode='Ipo';end

                modelH=bdroot(blkH);
                if strcmp(get_param(blkH,'DataSpecification'),'Table and breakpoints')
                    if strcmp(get_param(blkH,'BreakpointsSpecification'),'Explicit values')
                        bpSpacing='';
                    elseif strcmp(get_param(modelH,'DefaultParameterBehavior'),'Tunable')


                        bpSpacing='FixI';
                    else
                        bpSpacingParamValue=...
                        autosar.routines.ifxifl.Utils.getParamNumericalValueFromBlock(blkH,'BreakpointsForDimension1Spacing');
                        if autosar.utils.Math.isPow2(bpSpacingParamValue)
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
                            [~,spacingType,spacing]=fixpt_evenspace_cleanup(lkUpObj.Breakpoints.Value,lkUpObj.Breakpoints.DataType);
                            if~strcmp(spacingType,DAStudio.message('SimulinkFixedPoint:datatyperules:EvenSpacing'))
                                routine='No Valid Routine';
                                messageID='Simulink:blocks:LookupTableMismatchEvenspacingSpecification';
                                return;
                            end
                        else
                            spacing=lkUpObj.Breakpoints.Spacing;
                        end

                        if autosar.utils.Math.isPow2(spacing)
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

                routine=['Ifx_Int',mode,bpSpacing,'Cur'];
            elseif autosar.routines.RoutineBlock.isConfiguredForIFL(blkH)
                routine='Ifl_IntIpoCur';

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
            else
                assert(false,'Expected IFX or IFL to be specified');
            end
        end

        function setupSignalValidation(~,blkH)
            if strcmp(get_param(blkH,'DataSpecification'),'Lookup table object')

                try
                    set_param(blkH,'OutDataTypeStr','Inherit: Inherit from ''Table data''');
                catch E
                    autosar.routines.RoutineBlock.logErrorCallback(blkH,E);
                end
                return;
            end

            if contains(get_param(blkH,'TargetedRoutine'),'Fix')

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
            Simulink.DataConstraints.clearForPort(getfullname(blkH),'Input',1);
            Simulink.DataConstraints.clearForPort(getfullname(blkH),'Output',1);





            if~strcmp(get_param(blkH,'BreakpointsForDimension1DataTypeStr'),'Inherit: Same as corresponding input')
                if strcmpi(mode,'warn')
                    MSLDiagnostic('autosarstandard:routines:curveBreakpointDataTypeSpecified',getfullname(blkH),blkH).reportAsWarning;
                else
                    autosar.validation.AutosarUtils.reportErrorWithFixit('autosarstandard:routines:curveBreakpointDataTypeSpecified',getfullname(blkH),blkH);
                end
            end

        end
    end

    methods(Access=protected)
        function applyDefaultSettings(~,blkH)
            set_param(blkH,'Table','[1 2 4]');
            set_param(blkH,'BlockKeywords',{'Lookup','IFX','IFL','Routine','AUTOSAR'});
            set_param(blkH,'TableDataTypeStr','Inherit: Same as output');
            set_param(blkH,'BreakpointsForDimension1DataTypeStr','Inherit: Same as corresponding input');
            set_param(blkH,'IntermediateResultsDataTypeStr','Inherit: Same as output');
            set_param(blkH,'InternalRulePriority','Precision');
            set_param(blkH,'FractionDataTypeStr','fixdt(0,16,16)');
        end

        function populateMask(self,maskObj,blkH)
            maskObj.Type=self.getBlockType();
            maskObj.Description=self.getBlockDescription();

            maskBuilder=autosar.routines.ifxifl.IFXIFLMaskBuilder(blkH);

            maskBuilder.createRoutineImplParameter(maskObj,'autosar.routines.ifxifl.Curve');
            maskBuilder.setBlkMaskTitle(maskObj);
            maskBuilder.createMaskHeader(maskObj,self.getValidRoutines());
            maskBuilder.createMaskTabs(maskObj);

            targetRoutineLibParam=maskObj.getParameter('TargetRoutineLibrary');
            targetLibCallback=targetRoutineLibParam.Callback;
            targetRoutineLibParam.Callback=[targetLibCallback,'autosar.routines.RoutineCallbacks.setFractionDataTypeStr(gcb);'];

            maskBuilder.createTableSpecification(maskObj,'Tab1',...
            'DataSpecification','LookupTableObject','Table');
            maskBuilder.createBreakpointSpecification(maskObj,'Tab1',1,'DataSpecification');
            maskBuilder.createLookupTableEditButton(maskObj,'Tab1');

            maskBuilder.createIndexSearchSpecification(maskObj,'Tab2',{'Linear search','Binary search','Evenly spaced points'});
            maskBuilder.createInterpolationSpecification(maskObj,'Tab2',{'Linear point-slope','Flat'});

            maskBuilder.createLookupDataTypeSpecification(maskObj,'Tab3');
            maskBuilder.createBreakpointDataTypeSpecification(maskObj,'Tab3',1);

            maskBuilder.createLookupTableWidget(maskObj,1);

            maskBuilder.createPortConstraints(maskObj,{'input_1','output_1'});

            maskBuilder.applyMaskInitialization(maskObj);
            maskBuilder.setHelpTarget(maskObj,'autosar_curve_block');
            self.applyAUTOSARFooter(maskObj);
        end
    end

end



