classdef IPCRead<matlab.System&coder.ExternalDependency



%#codegen

    properties(Nontunable)
        ChannelNum=0;
        NumBuff=4;
        IsIntEnabled=0;
        DataType='uint8'
        BuffSize=1;
        SampleTime=-1;



        StructForBus=struct;


        IPCBetween=0;



        CurrentPU=0;
    end


    properties(Access=private)
        IpcParams;
        IpcHandle;
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
        function obj=IPCRead(varargin)
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
                obj.DataTypeId=uint16(MW_SOC_DataType.MW_INT8);
            case 'uint8'
                obj.DataTypeInBytes=1;
                obj.DataTypeId=uint16(MW_SOC_DataType.MW_UINT8);
            case 'int16'
                obj.DataTypeInBytes=2;
                obj.DataTypeId=uint16(MW_SOC_DataType.MW_INT16);
            case 'uint16'
                obj.DataTypeInBytes=2;
                obj.DataTypeId=uint16(MW_SOC_DataType.MW_UINT16);
            case 'int32'
                obj.DataTypeInBytes=4;
                obj.DataTypeId=uint16(MW_SOC_DataType.MW_INT32);
            case 'uint32'
                obj.DataTypeInBytes=4;
                obj.DataTypeId=uint16(MW_SOC_DataType.MW_UINT32);
            case 'single'
                obj.DataTypeInBytes=4;
                obj.DataTypeId=uint16(MW_SOC_DataType.MW_FLOAT);
            case 'double'
                obj.DataTypeInBytes=8;
                obj.DataTypeId=uint16(MW_SOC_DataType.MW_DOUBLE);
            case 'int64'
                obj.DataTypeInBytes=8;
                obj.DataTypeId=uint16(MW_SOC_DataType.MW_INT64);
            case 'uint64'
                obj.DataTypeInBytes=8;
                obj.DataTypeId=uint16(MW_SOC_DataType.MW_UINT64);
            case 'boolean'
                obj.DataTypeInBytes=1;
                obj.DataTypeId=uint16(MW_SOC_DataType.MW_BOOL);
            otherwise
                if(startsWith(obj.DataType,'Bus: '))
                    obj.DataTypeInBytes=obj.getStructSize(obj.StructForBus);
                    obj.DataTypeId=uint16(MW_SOC_DataType.MW_STRUCT);
                end
            end
        end

        function out=isOutputFixedSizeImpl(~)

            out=true;
        end

        function out=isOutputComplexImpl(~)

            out=false;
        end

        function out=getOutputSizeImpl(obj)

            out=obj.BuffSize;
        end

        function out=getOutputDataTypeImpl(obj)

            if(startsWith(obj.DataType,'Bus: '))
                out=extractAfter(obj.DataType,'Bus: ');
            else
                out=obj.DataType;
            end
        end

        function setupImpl(obj)
            if coder.target('rtw')
                coder.cinclude('mw_soc_ipc.h');
                IpcParamsLoc=struct;
                coder.cstructname(IpcParamsLoc,'MW_IPC_Params_T','extern','HeaderFile','mw_soc_ipc.h');

                IpcParamsLoc.NumOfBuffers=obj.NumBuff;
                IpcParamsLoc.ChNum=obj.ChannelNum;
                IpcParamsLoc.BufferSize=obj.BuffSize;
                IpcParamsLoc.DataTypeInBytes=obj.DataTypeInBytes;
                IpcParamsLoc.IsIntEnabled=obj.IsIntEnabled;
                IpcParamsLoc.IPCBetween=obj.IPCBetween;

                obj.IpcParams=IpcParamsLoc;
                obj.IpcHandle=coder.opaque('MW_IPC_Handle','HeaderFile','mw_soc_c2000_ipc.h');
                obj.IpcHandle=coder.ceval('MW_IPC_Init',coder.ref(obj.IpcParams));
            end
        end

        function out=stepImpl(obj)
            if(matches(obj.DataType,{'int8','uint8','boolean','int16','uint16','int32','uint32','single','int64','uint64','double'}))
                out=zeros(obj.BuffSize,1,obj.DataType);
            elseif(startsWith(obj.DataType,'Bus: '))
                out=obj.StructForBus;
            end
            if coder.target('rtw')
                if(obj.CurrentPU==3||obj.CurrentPU==4)
                    coder.ceval('MW_IPC_Read_CLA',coder.ref(obj.IpcHandle),obj.CurrentPU,obj.DataTypeId,coder.wref(out));
                else
                    coder.ceval('MW_IPC_Read',coder.ref(obj.IpcHandle),obj.CurrentPU,obj.DataTypeId,coder.wref(out));
                end
            end
        end

        function releaseImpl(obj)

            if coder.target('rtw')
                coder.ceval('MW_IPC_Terminate',obj.IpcHandle);
            end
        end
    end

    methods(Static)
        function name=getDescriptiveName()
            name='IPC Read';
        end

        function b=isSupportedContext(context)
            b=context.isCodeGenTarget('rtw');
        end

        function updateBuildInfo(buildInfo,context)
            if context.isCodeGenTarget('rtw')

                drvdir=soc.internal.getRootDir;

                addIncludePaths(buildInfo,fullfile(drvdir,'include'));
                addIncludeFiles(buildInfo,'mw_soc_ipc.h');

                addDefines(buildInfo,sprintf('IPC_BLOCK_INCLUDED=1'));
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

    methods(Access=private)
        function out=getStructSize(obj,structObj)
            out=0;
            structElements=fieldnames(structObj);
            for i=1:numel(structElements)
                signal=structObj.(structElements{i});
                if(matches(class(signal),{'int8','uint8','boolean'}))
                    out=out+1*numel(signal);
                elseif(matches(class(signal),{'int16','uint16'}))
                    out=out+2*numel(signal);
                elseif(matches(class(signal),{'int32','uint32','single'}))
                    out=out+4*numel(signal);
                elseif(matches(class(signal),{'int64','uint64','double'}))
                    out=out+8*numel(signal);
                elseif(matches(class(signal),'struct'))
                    out=out+obj.getStructSize(signal);
                else
                    error("Signal of unsupported datatype present in bus.");
                end
            end
        end
    end
end
