classdef Prelookup<autosar.routines.RoutineBlock




    methods
        function description=getBlockDescription(~)
            description=message('autosarstandard:routines:PrelookupDescription').getString();
        end

        function type=getBlockType(~)
            type='Prelookup';
        end

        function sourceBlock=getSourceBlock(~)
            sourceBlock='simulink/Lookup Tables/Prelookup';
        end

        function constantParameters=getConstantParameters(~)
            constantParameters=containers.Map();
            constantParameters('ExtrapMethod')='Clip';
            constantParameters('RemoveProtectionInput')='off';
            constantParameters('UseLastBreakpoint')='on';
        end

        function validRoutines=getValidRoutines(~)
            validRoutines={...
            'Ifx_DPSearch',...
            'Ifl_DPSearch'};
        end
    end

    methods
        function[routine,fixitCommand,messageID]=getRoutineFromBlockSettings(~,blkH)
            fixitCommand='';
            messageID='';

            if strcmp(get_param(blkH,'BPSpecification'),'Breakpoint object')
                breakpointObject=get_param(blkH,'BreakpointObject');
                model=bdroot(blkH);
                [exists,~]=autosar.utils.Workspace.objectExistsInModelScope(model,breakpointObject);
                if~exists
                    routine='No Valid Routine';
                    return;
                end
            end

            if autosar.routines.RoutineBlock.isConfiguredForIFX(blkH)
                routine='Ifx_DPSearch';
                return;
            elseif autosar.routines.RoutineBlock.isConfiguredForIFL(blkH)
                routine='Ifl_DPSearch';
                return;
            else
                assert(false,'Expected IFX or IFL to be specified');
            end
        end

        function setupSignalValidation(~,blkH)
            if strcmp(get_param(blkH,'BreakpointsSpecification'),'Breakpoint object')
                set_param(blkH,'BreakpointDataTypeStr','Inherit: Inherit from ''Breakpoint data''');
            else
                set_param(blkH,'BreakpointDataTypeStr','Inherit: Same as input');
            end
        end

        function updateSignalValidation(~,blkH,~)
            Simulink.DataConstraints.clearForPort(getfullname(blkH),'Input',1);
        end
    end

    methods(Access=protected)
        function applyDefaultSettings(~,blkH)
            set_param(blkH,'BreakpointsData','[1 2 3]');
            set_param(blkH,'OutputSelection','Index and fraction as bus');
            set_param(blkH,'BlockKeywords',{'Prelookup','IFX','IFL','Routine','AUTOSAR'});
        end

        function populateMask(self,maskObj,blkH)
            maskObj.Type=self.getBlockType();
            maskObj.Description=self.getBlockDescription();

            maskBuilder=autosar.routines.ifxifl.IFXIFLMaskBuilder(blkH);

            maskBuilder.createRoutineImplParameter(maskObj,'autosar.routines.ifxifl.Prelookup');
            maskBuilder.setBlkMaskTitle(maskObj);
            maskBuilder.createMaskHeader(maskObj,self.getValidRoutines());

            targetRoutineLibParam=maskObj.getParameter('TargetRoutineLibrary');
            targetLibCallback=targetRoutineLibParam.Callback;
            targetRoutineLibParam.Callback=[targetLibCallback,'autosar.routines.ifxifl.Prelookup.setOutputTypes(gcb);'];

            maskBuilder.createMaskTabs(maskObj,true);

            maskBuilder.createPrelookupBreakpointSpecification(maskObj,'Tab1');

            maskBuilder.createIndexSearchSpecification(maskObj,'Tab2',{'Linear search','Binary search'});
            maskBuilder.createInterpolationSpecification(maskObj,'Tab2',{});

            maskBuilder.createPortConstraints(maskObj,{'input_1'});

            maskBuilder.applyMaskInitialization(maskObj);
            maskBuilder.setHelpTarget(maskObj,'autosar_prelookup_block');

            maskObj.BlockDVGIcon='BSWBlockIcon.PreLookup';
            maskObj.IconOpaque='transparent';
            set_param(blkH,'MoveFcn','autosar.routines.ifxifl.Prelookup.updateIcon(gcb);')
        end
    end

    methods(Static)
        function setOutputTypes(blkH)
            if autosar.routines.RoutineBlock.isConfiguredForIFX(blkH)
                set_param(blkH,'OutputBusDataTypeStr','Bus: Ifx_DPResultU16_Type');
                busType=Ifx_DPResultU16_Type;
                indexType=busType.Index;
                fractionType=busType.Ratio;
            elseif autosar.routines.RoutineBlock.isConfiguredForIFL(blkH)
                set_param(blkH,'OutputBusDataTypeStr','Bus: Ifl_DPResultF32_Type');
                busType=Ifl_DPResultF32_Type;
                indexType=busType.Index;
                fractionType=busType.Ratio;
            end

            if isa(indexType,'Simulink.NumericType')
                set_param(blkH,'IndexDataTypeStr',indexType.tostring);
            else
                set_param(blkH,'IndexDataTypeStr',class(indexType));
            end

            if isa(fractionType,'Simulink.NumericType')
                set_param(blkH,'FractionDataTypeStr',indexType.tostring);
            else
                set_param(blkH,'FractionDataTypeStr',class(indexType));
            end
        end

        function updateIcon(blkH)
            position=get_param(blkH,'Position');
            cellPos=num2cell(position(3:4)-position(1:2));
            [width,height]=deal(cellPos{:});
            maskObj=Simulink.Mask.get(blkH);
            if width<40||height<40
                maskObj.BlockDVGIcon='BSWBlockIcon.PreLookup_OnlyText';
            else
                maskObj.BlockDVGIcon='BSWBlockIcon.PreLookup';
            end
        end
    end
end




