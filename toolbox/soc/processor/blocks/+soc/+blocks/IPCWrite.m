classdef IPCWrite<matlab.System&coder.ExternalDependency




%#codegen
    properties(Nontunable)

        ChannelNum=0;

        NumBuff=4;

        IsIntEnabled=0;

        DataType='uint8';


        IPCBetween=0;



        CurrentPU=0;
    end


    properties(Access=private)

        IpcParams;
        IpcHandle;
        BuffSize;
        DataTypeInBytes;
        DataTypeId;

        Overwritten uint64=0;

        NumBufUsed uint16=0;
    end

    methods(Access=protected)
        function num=getNumInputsImpl(~)
            num=1;
        end
        function num=getNumOutputsImpl(~)
            num=2;
        end
        function[overwritten,numBufOut]=getOutputNamesImpl(~)

            overwritten='overwritten';
            numBufOut='buffersUsed';
        end
        function flag=allowModelReferenceDiscreteSampleTimeInheritanceImpl(~)
            flag=true;
        end
    end
    methods
        function obj=IPCWrite(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
        end

    end

    methods(Access=protected)

        function[overwritten,numBufOut]=isOutputFixedSizeImpl(~)

            overwritten=true;
            numBufOut=true;
        end

        function[overwritten,numBufOut]=isOutputComplexImpl(~)

            overwritten=false;
            numBufOut=false;
        end

        function[overwritten,numBufOut]=getOutputSizeImpl(~)

            overwritten=1;
            numBufOut=1;
        end

        function[overwritten,numBufOut]=getOutputDataTypeImpl(~)

            overwritten='uint64';
            numBufOut='uint16';
        end

        function validateInputsImpl(obj,In)


            obj.BuffSize=numel(In);
            switch class(In)
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
            case 'struct'
                obj.DataTypeInBytes=obj.getStructSize(In);
                obj.DataTypeId=uint16(MW_SOC_DataType.MW_STRUCT);
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

        function[overwriteOut,numBufOut]=stepImpl(obj,In)
            diagDataOut=struct('OverwriteDiag',uint16(0),'NumBuffUsedDiag',uint16(0));
            coder.cstructname(diagDataOut,'MW_IPC_Diag_T','extern','HeaderFile','mw_soc_ipc.h');
            if coder.target('rtw')

                if(obj.CurrentPU==3||obj.CurrentPU==4)
                    coder.ceval('MW_IPC_Write_CLA',coder.ref(obj.IpcHandle),obj.CurrentPU,obj.DataTypeId,coder.rref(In));
                    overwriteOut=uint64(0);
                    numBufOut=uint16(0);
                else
                    coder.ceval('MW_IPC_Write',coder.ref(obj.IpcHandle),obj.CurrentPU,obj.DataTypeId,coder.rref(In),coder.ref(diagDataOut));
                    obj.Overwritten=obj.Overwritten+uint64(diagDataOut.OverwriteDiag);
                    tempNumBufUsed=uint16(diagDataOut.NumBuffUsedDiag);




                    if~(tempNumBufUsed>obj.NumBuff)
                        obj.NumBufUsed=tempNumBufUsed;

                    end
                    overwriteOut=obj.Overwritten;
                    numBufOut=obj.NumBufUsed;
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
            name='IPC Write';
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
        function out=getStructSize(obj,In)
            out=0;
            structElements=fieldnames(In);
            for i=1:numel(structElements)
                signal=In.(structElements{i});
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
