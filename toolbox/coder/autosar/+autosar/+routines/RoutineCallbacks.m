classdef RoutineCallbacks
    methods(Static)
        function showDCIfParameterHasValue(blkH,maskObjectName,parameter,value)





            autosar.routines.RoutineCallbacks.doIfHasValue(blkH,maskObjectName,parameter,value,'dc','show');
        end

        function hideDCIfParameterHasValue(blkH,maskObjectName,parameter,value)





            autosar.routines.RoutineCallbacks.doIfHasValue(blkH,maskObjectName,parameter,value,'dc','hide');
        end

        function showParamIfParameterHasValue(blkH,maskObjectName,parameter,value)





            autosar.routines.RoutineCallbacks.doIfHasValue(blkH,maskObjectName,parameter,value,'param','show');
        end

        function hideParamIfParameterHasValue(blkH,maskObjectName,parameter,value)





            autosar.routines.RoutineCallbacks.doIfHasValue(blkH,maskObjectName,parameter,value,'param','hide');
        end

        function enableParamIfParameterHasValue(blkH,maskObjectName,parameter,value)





            autosar.routines.RoutineCallbacks.doIfHasValue(blkH,maskObjectName,parameter,value,'param','enable');
        end

        function disableParamIfParameterHasValue(blkH,maskObjectName,parameter,value)





            autosar.routines.RoutineCallbacks.doIfHasValue(blkH,maskObjectName,parameter,value,'param','disable');
        end

        function updateDataTypeOptions(blkH,dataSpecName)

            maskObj=Simulink.Mask.get(blkH);

            dataSpecification=get_param(blkH,dataSpecName);
            dataTypesTab=maskObj.getDialogControl('Tab3');
            if strcmp(dataSpecification,'Lookup table object')
                dataTypesTab.Visible='off';
            else
                dataTypesTab.Visible='on';

                if~isfield(get_param(blkH,'DialogParameters'),'BreakpointsSpecification')
                    return;
                end

                breakpointSpecification=get_param(blkH,'BreakpointsSpecification');
                tableDataTypeIdx=find(strcmp({maskObj.Parameters.Name},'TableDataTypeStr'));
                tableDataType=maskObj.Parameters(tableDataTypeIdx);
                if strcmpi(breakpointSpecification,'even spacing')
                    tableDataType.Visible='off';
                else
                    tableDataType.Visible='on';
                end
            end
        end

        function updateBreakpointOptions(blkH,dataSpecName)

            if~isfield(get_param(blkH,'DialogParameters'),'BreakpointsSpecification')
                return;
            end

            maskObj=Simulink.Mask.get(blkH);

            dataSpecification=get_param(blkH,dataSpecName);

            BreakpointsLabels1=maskObj.getDialogControl('TextGroup1');
            BreakpointsLabels2=maskObj.getDialogControl('TextGroup2');
            if strcmp(dataSpecification,'Lookup table object')
                BreakpointsLabels1.Visible='off';
                BreakpointsLabels2.Visible='off';
            else
                breakpointSpecification=get_param(blkH,'BreakpointsSpecification');
                if strcmpi(breakpointSpecification,'even spacing')
                    BreakpointsLabels1.Visible='on';
                    BreakpointsLabels2.Visible='on';
                else
                    BreakpointsLabels1.Visible='off';
                    BreakpointsLabels2.Visible='off';
                end
            end
        end

        function updateIndexSearchOptions(blkH,dataSpecName)







            if nargin<2
                dataSpec='';
            else
                dataSpec=get_param(blkH,dataSpecName);
            end

            if~isfield(get_param(blkH,'DialogParameters'),'BreakpointsSpecification')
                return;
            end

            maskObjectName='IndexSearchMode';

            maskObj=Simulink.Mask.get(blkH);
            maskObjIdx=find(strcmp({maskObj.Parameters.Name},maskObjectName));
            maskObjParam=maskObj.Parameters(maskObjIdx);

            breakpointSpec=get_param(blkH,'BreakpointsSpecification');
            if~isempty(dataSpec)&&strcmp(dataSpec,'Lookup table object')
                maskObjParam.Enabled='on';
            elseif strcmp(breakpointSpec,'Even spacing')
                set_param(blkH,maskObjectName,'Evenly spaced points');
                maskObjParam.Enabled='off';
            else
                maskObjParam.Enabled='on';
            end
        end


        function setFractionDataTypeStr(blkH)


            try

                if autosar.routines.RoutineBlock.isConfiguredForIFX(blkH)
                    set_param(blkH,'FractionDataTypeStr','fixdt(0,16,16)');
                elseif autosar.routines.RoutineBlock.isConfiguredForIFL(blkH)
                    set_param(blkH,'FractionDataTypeStr','Inherit: Inherit via internal rule');
                end
            catch E
                autosar.routines.RoutineBlock.logErrorCallback(blkH,E);
            end
        end

        function setDefaultDataTypes(blkH)





            autosar.routines.RoutineBlock.setupDataTypesCallback(blkH);
        end

        function applyFixit(blkPath,parameter,value)





            set_param(blkPath,parameter,value);
            autosar.routines.RoutineBlock.updateMaskCallback(blkPath);
        end

        function propagateParam(block,source,target)




            try
                val=get_param(block,source);
                set_param(block,target,val);
            catch E
                autosar.routines.RoutineBlock.logErrorCallback(block,E);
            end
        end

        function clearErrors(blk)
            autosar.routines.RoutineBlock.resetErrorsCallback(blk);
        end
    end

    methods(Static,Access=private)
        function doIfHasValue(blkH,maskObjectName,parameter,value,targetType,action)



            function setVisible(maskObj,value)
                if~strcmp(maskObj.Visible,value)
                    maskObj.Visible=value;
                end
            end

            function setEnabled(maskObj,value)
                if~strcmp(maskObj.Enabled,value)
                    maskObj.Enabled=value;
                end
            end

            assert(any(strcmp(targetType,{'param','dc'})),'Expected ''param'' or ''dc''');
            assert(any(strcmp(action,{'show','hide','enable','disable'})),'Expected ''show'',''hide'',''enable'' or ''disable''');

            val=get_param(blkH,parameter);

            maskObj=Simulink.Mask.get(blkH);

            switch targetType
            case 'param'
                maskObjIdx=find(strcmp({maskObj.Parameters.Name},maskObjectName));
                maskObj=maskObj.Parameters(maskObjIdx);
            case 'dc'
                maskObj=maskObj.getDialogControl(maskObjectName);
            end

            assert(~isempty(maskObj),'invalid mask object');

            if strcmp(val,value)
                switch action
                case 'show'
                    setVisible(maskObj,'on');
                case 'hide'
                    setVisible(maskObj,'off');
                case 'enable'
                    setEnabled(maskObj,'on');
                case 'disable'
                    setEnabled(maskObj,'off');
                end
            else
                switch action
                case 'show'
                    setVisible(maskObj,'off');
                case 'hide'
                    setVisible(maskObj,'on');
                case 'enable'
                    setEnabled(maskObj,'off');
                case 'disable'
                    setEnabled(maskObj,'on');
                end
            end
        end
    end
end






