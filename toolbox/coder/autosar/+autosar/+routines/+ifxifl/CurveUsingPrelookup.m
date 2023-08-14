classdef CurveUsingPrelookup<autosar.routines.RoutineBlock




    methods
        function description=getBlockDescription(~)
            description=message('autosarstandard:routines:CurveUsingPrelookupDescription').getString();
        end

        function type=getBlockType(~)
            type='Curve Using Prelookup';
        end

        function sourceBlock=getSourceBlock(~)
            sourceBlock='simulink/Lookup Tables/Interpolation Using Prelookup';
        end

        function constantParameters=getConstantParameters(~)
            constantParameters=containers.Map();
            constantParameters('NumberOfTableDimensions')='1';
            constantParameters('ExtrapMethod')='Clip';
            constantParameters('RemoveProtectionIndex')='off';
            constantParameters('ValidIndexMayReachLast')='on';
        end

        function validRoutines=getValidRoutines(~)
            validRoutines={...
            'Ifx_IpoCur',...
            'Ifx_LkUpCur',...
            'Ifl_IpoCur'};
        end
    end

    methods
        function[routine,fixitCommand,messageID]=getRoutineFromBlockSettings(self,blkH)
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

                routine=['Ifx_',mode,'Cur'];
                return;
            elseif autosar.routines.RoutineBlock.isConfiguredForIFL(blkH)
                routine='Ifl_IpoCur';

                if~strcmp(get_param(blkH,'InterpMode'),'Linear point-slope')
                    routine='No Valid Routine';
                    fixitCommand=self.genSetParamFixit(blkH,'InterpMode','Linear point-slope');
                    messageID='autosarstandard:routines:IflIncorrectInterpMode';
                    return;
                end

                return;
            else
                assert(false,'Expected IFX or IFL to be specified');
            end
        end

        function setupSignalValidation(~,blkH)
            if strcmp(get_param(blkH,'TableSpecification'),'Lookup table object')

                try
                    set_param(blkH,'OutDataTypeStr','Inherit: Inherit from ''Table data''');
                catch E
                    autosar.routines.RoutineBlock.logErrorCallback(blkH,E);
                end
                return;
            end

            tableDataTypeStr=get_param(blkH,'TableDataTypeStr');
            if strcmp(tableDataTypeStr,'Inherit: Same as output')
                set_param(blkH,'OutDataTypeStr','Inherit: Inherit via back propagation');
            else
                set_param(blkH,'OutDataTypeStr',tableDataTypeStr);
            end
        end

        function updateSignalValidation(~,blkH,~)
            Simulink.DataConstraints.clearForPort(getfullname(blkH),'Output',1);
        end
    end

    methods(Access=protected)
        function applyDefaultSettings(~,blkH)
            set_param(blkH,'Table','[1 2 4]');
            set_param(blkH,'BlockKeywords',{'Interpolation','IFX','IFL','Routine','AUTOSAR'});
            set_param(blkH,'TableDataTypeStr','Inherit: Same as output');
            set_param(blkH,'RequireIndexFractionAsBus','on');
            set_param(blkH,'IntermediateResultsDataTypeStr','Inherit: Same as output');
            set_param(blkH,'InternalRulePriority','Precision');
        end

        function populateMask(self,maskObj,blkH)
            maskObj.Type=self.getBlockType();
            maskObj.Description=self.getBlockDescription();

            maskBuilder=autosar.routines.ifxifl.IFXIFLMaskBuilder(blkH);

            maskBuilder.createRoutineImplParameter(maskObj,'autosar.routines.ifxifl.CurveUsingPrelookup');
            maskBuilder.setBlkMaskTitle(maskObj);
            maskBuilder.createMaskHeader(maskObj,self.getValidRoutines());
            maskBuilder.createMaskTabs(maskObj);

            maskBuilder.createTableSpecification(maskObj,'Tab1',...
            'TableSpecification','LookupTableObject','Table');
            maskBuilder.createLookupTableEditButton(maskObj,'Tab1');

            maskBuilder.createInterpolationSpecification(maskObj,'Tab2',{'Linear point-slope','Flat'});

            maskBuilder.createLookupDataTypeSpecification(maskObj,'Tab3');

            maskBuilder.createPortConstraints(maskObj,{'output_1'});

            maskBuilder.applyMaskInitialization(maskObj);
            maskBuilder.setHelpTarget(maskObj,'autosar_curve_using_prelookup_block');
            self.applyAUTOSARFooter(maskObj);
        end
    end
end



