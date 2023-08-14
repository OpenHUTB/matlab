classdef ADCRead<matlab.System&coder.ExternalDependency




%#codegen

    properties(Nontunable)
        DataType='uint8'
        SampleTime=-1;
    end

    properties(Nontunable)
        BlockID='';
    end


    properties(Access=private)

        AdcParams;
        AdcHandle;
        DataTypeInBytes;
        DataTypeId;
    end

    methods(Access=protected)
        function num=getNumInputsImpl(~)
            num=0;
        end
        function num=getNumOutputsImpl(~)
            num=1;
        end
    end

    methods
        function obj=ADCRead(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Access=protected)
        function stVal=getSampleTimeImpl(obj)
            if obj.SampleTime==-1
                stVal=createSampleTime(obj,'Type','Inherited');
            else
                stVal=createSampleTime(obj,'Type','Discrete','SampleTime',obj.SampleTime);
            end
        end

        function flag=allowModelReferenceDiscreteSampleTimeInheritanceImpl(~)
            flag=true;
        end

        function validatePropertiesImpl(obj)


            switch obj.DataType
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
        end

        function out=isOutputFixedSizeImpl(~)

            out=true;
        end

        function out=isOutputComplexImpl(~)

            out=false;
        end

        function out=getOutputSizeImpl(~)

            out=1;
        end

        function out=getOutputDataTypeImpl(obj)

            out=obj.DataType;
        end

        function setupImpl(obj)
            coder.extrinsic('codertarget.peripherals.utils.getPeripheralDataStructType');
            if coder.target('rtw')

                coder.cinclude('mw_soc_adc.h');

                strType=coder.const(codertarget.peripherals.utils.getPeripheralDataStructType('ADC'));
                coder.ceval("extern "+strType+" "+obj.BlockID+";//");


                str=coder.const(obj.BlockID);
                AdcCustParams=coder.opaque('MW_Void_Ptr_T',coder.const("(MW_Void_Ptr_T)"+"&"+str),'HeaderFile','mw_soc_drv_generic.h');

                AdcParamsLoc=struct;
                coder.cstructname(AdcParamsLoc,'MW_ADC_Params_T','extern','HeaderFile','mw_soc_adc.h');
                AdcParamsLoc.DataType=obj.DataTypeId;

                obj.AdcParams=AdcParamsLoc;

                obj.AdcHandle=coder.opaque('MW_Void_Ptr_T','HeaderFile','mw_soc_drv_generic.h');
                obj.AdcHandle=coder.ceval('MW_ADC_Init',coder.ref(obj.AdcParams),AdcCustParams);
            end
        end

        function out=stepImpl(obj)
            out=zeros(1,1,obj.DataType);
            if coder.target('rtw')
                out=coder.ceval('MW_ADC_getCount',obj.AdcHandle);
            end
        end

        function releaseImpl(obj)

            if coder.target('rtw')
                coder.ceval('MW_ADC_Terminate',obj.AdcHandle);
            end
        end
    end

    methods(Static)
        function name=getDescriptiveName()
            name='ADC Read';
        end

        function b=isSupportedContext(context)
            b=context.isCodeGenTarget('rtw');
        end

        function updateBuildInfo(buildInfo,context)
            if context.isCodeGenTarget('rtw')

                drvdir=soc.internal.getRootDir;

                addIncludePaths(buildInfo,fullfile(drvdir,'include'));
                addIncludeFiles(buildInfo,'mw_soc_adc.h');

                addDefines(buildInfo,sprintf('ADC_BLOCK_INCLUDED=1'));
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


