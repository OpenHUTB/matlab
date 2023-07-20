classdef PWMWrite<matlab.System&coder.ExternalDependency




%#codegen

    properties(Nontunable)
        BlockID='';
    end


    properties(Access=private)

        PwmParams;
        PwmHandle;
        DataTypeInBytes;
        DataTypeId;
    end

    methods(Access=protected)
        function num=getNumInputsImpl(~)
            num=1;
        end
        function num=getNumOutputsImpl(~)
            num=0;
        end
        function flag=allowModelReferenceDiscreteSampleTimeInheritanceImpl(~)
            flag=true;
        end
    end
    methods
        function obj=PWMWrite(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Access=protected)
        function validateInputsImpl(obj,in)


            switch class(in)
            case 'int8'
                obj.DataTypeInBytes=1;
                obj.DataTypeId=MW_SOC_DataType.MW_INT8;
            case 'uint8'
                obj.DataTypeInBytes=1;
                obj.DataTypeId=MW_SOC_DataType.MW_UINT8;
            case 'int16'
                obj.DataTypeInBytes=2;
                obj.DataTypeId=MW_SOC_DataType.MW_INT16;
            case 'uint16'
                obj.DataTypeInBytes=2;
                obj.DataTypeId=MW_SOC_DataType.MW_UINT16;
            case 'int32'
                obj.DataTypeInBytes=4;
                obj.DataTypeId=MW_SOC_DataType.MW_INT32;
            case 'uint32'
                obj.DataTypeInBytes=4;
                obj.DataTypeId=MW_SOC_DataType.MW_UINT32;
            case 'single'
                obj.DataTypeInBytes=4;
                obj.DataTypeId=MW_SOC_DataType.MW_FLOAT;
            case 'double'
                obj.DataTypeInBytes=8;
                obj.DataTypeId=MW_SOC_DataType.MW_DOUBLE;
            case 'int64'
                obj.DataTypeInBytes=8;
                obj.DataTypeId=MW_SOC_DataType.MW_INT64;
            case 'uint64'
                obj.DataTypeInBytes=8;
                obj.DataTypeId=MW_SOC_DataType.MW_UINT64;
            case 'boolean'
                obj.DataTypeInBytes=1;
                obj.DataTypeId=MW_SOC_DataType.MW_BOOL;
            end
            if~isstruct(in)
                error(message('simdemos:MLSysBlockMsg:BusInput'));
            end
        end

        function setupImpl(obj)
            coder.extrinsic('codertarget.peripherals.utils.getPeripheralDataStructType');
            if coder.target('rtw')
                coder.cinclude('mw_soc_pwm.h');

                strType=coder.const(codertarget.peripherals.utils.getPeripheralDataStructType('PWM'));
                coder.ceval("extern "+strType+" "+obj.BlockID+";//");

                PWMCustParams=coder.opaque('MW_Void_Ptr_T',coder.const("(MW_Void_Ptr_T)"+"&"+obj.BlockID),'HeaderFile','mw_soc_drv_generic.h');

                PwmParamsLoc=struct;
                coder.cstructname(PwmParamsLoc,'MW_PWM_Params_T','extern','HeaderFile','mw_soc_pwm.h');
                PwmParamsLoc.DataType=obj.DataTypeId;
                PwmParamsLoc.Compare1=single(0);
                PwmParamsLoc.Compare2=single(0);
                PwmParamsLoc.IsPeriodInpVal=boolean(0);
                PwmParamsLoc.Period=single(0);
                PwmParamsLoc.IsPhaseInpVal=boolean(0);
                PwmParamsLoc.Phase=single(0);

                obj.PwmParams=PwmParamsLoc;

                obj.PwmHandle=coder.opaque('MW_Void_Ptr_T','HeaderFile','mw_soc_drv_generic.h');
                obj.PwmHandle=coder.ceval('MW_PWM_Init',coder.ref(obj.PwmParams),PWMCustParams);
            end
        end

        function stepImpl(obj,in)
            if coder.target('rtw')
                obj.PwmParams.Compare1=in.compare(1);
                obj.PwmParams.Compare2=in.compare(2);
                obj.PwmParams.IsPeriodInpVal=in.isPeriodValid;
                obj.PwmParams.Period=in.period;
                obj.PwmParams.IsPhaseInpVal=in.isPhaseValid;
                obj.PwmParams.Phase=in.phase;
                coder.ceval('MW_PWM_Write',obj.PwmHandle,coder.ref(obj.PwmParams));
            end
        end

        function releaseImpl(obj)

            if coder.target('rtw')
                coder.ceval('MW_PWM_Terminate',obj.PwmHandle);
            end
        end
    end

    methods(Static)
        function name=getDescriptiveName()
            name='PWM Write';
        end

        function b=isSupportedContext(context)
            b=context.isCodeGenTarget('rtw');
        end

        function updateBuildInfo(buildInfo,context)
            if context.isCodeGenTarget('rtw')

                drvdir=soc.internal.getRootDir;

                addIncludePaths(buildInfo,fullfile(drvdir,'include'));
                addIncludeFiles(buildInfo,'mw_soc_pwm.h');

                addDefines(buildInfo,sprintf('PWM_BLOCK_INCLUDED=1'));
            end
        end
    end
    methods(Static,Access=protected)

        function simMode=getSimulateUsingImpl(~)
            simMode='Interpreted execution';
        end

        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
    end
end


