classdef AXIRegisterWrite<ioplayback.SinkSystem&...
    coder.ExternalDependency




































%#codegen
%#ok<*EMCA>

    properties(Nontunable)

        DeviceName='/dev/mwipcore';

        RegisterOffset=uint32(hex2dec('0100'));
    end

    properties(Nontunable,Hidden)

        DataType='uint32';

        DataLength=uint32(1);

        SampleTime=0.001;
        DataTypeWarningasError=0;
    end

    properties(Nontunable,Access=private,Hidden)
        StridePerElement=uint32(4);
        DataByteLength=uint32(1);
        TypeByteSize=uint32(1);
        DeviceNameNull=char(0);
        StrobeOffset=uint32(hex2dec('0100'));
    end

    properties(Access=private,Hidden)
        DeviceState=uint32(0);
    end

    properties(Constant,Hidden)
        DataTypeSet=matlab.system.StringSet({...
        'double',...
        'single',...
        'int8',...
        'uint8',...
        'int16',...
        'uint16',...
        'int32',...
        'uint32',...
        'logical',...
        });

        WORD_SIZE_IN_BYTES=uint32(4);
    end


    methods(Static,Access=protected)
        function header=getHeaderImpl()
            text2Display=DAStudio.message('soc:utils:AXIRegisterWriteMaskDisplay');
            header=matlab.system.display.Header('soc.linux.AXIRegisterWrite',...
            'ShowSourceLink',false,...
            'Title','AXI4-Register Write',...
            'Text',text2Display);
        end
    end

    methods
        function obj=AXIRegisterWrite(varargin)
            coder.allowpcode('plain');

            setProperties(obj,nargin,varargin{:});
        end

        function set.DataLength(obj,val)
            validateattributes(val,...
            {'numeric'},{'positive','integer','scalar'},'','DataLength');
            obj.DataLength=uint32(val);
        end

        function set.RegisterOffset(obj,val)
            validateattributes(val,...
            {'numeric'},{'nonnegative','integer','scalar','<=',hex2dec('FFFF')},...
            '','RegisterOffset');
            obj.RegisterOffset=uint32(val);
        end

        function set.DeviceName(obj,val)
            validateattributes(val,...
            {'char'},{'nonempty'},'ischar','DeviceName');
            obj.DeviceName=val;
        end

        function event=getNextEvent(obj,~,~)
            if isequal(obj.SendSimulationInputTo,'Output port')||isequal(obj.SendSimulationInputTo,'Terminator')

                event=[];
                return;
            end
        end

        function y=readData(obj,ds)
            y=0;
            if isempty(coder.target)
                if nargin<2
                    ds=RecordedData(obj.DatasetName);
                end
                dataFile=getDataFile(ds,obj.SourceName);
                fid=fopen(dataFile,'r');
                if fid>0
                    y=fread(fid,Inf,['*',obj.DataType]);
                    fclose(fid);
                end

                ys=length(y);
                te=(ys/double(obj.DataLength))*obj.SampleTime;
                y=timeseries(y,linspace(0,te,ys));
            end
        end
    end

    methods(Hidden)
        function checkDataFile(~,~)
        end
    end

    methods(Access=private,Hidden)

        function InitData(obj,dtype,dlen)

            obj.DataType=dtype;
            obj.DataLength=dlen;

            switch(lower(obj.DataType))
            case 'double'
                obj.TypeByteSize=uint32(8);
            case 'single'
                obj.TypeByteSize=uint32(4);
            case 'int8'
                obj.TypeByteSize=uint32(1);
            case 'uint8'
                obj.TypeByteSize=uint32(1);
            case 'int16'
                obj.TypeByteSize=uint32(2);
            case 'uint16'
                obj.TypeByteSize=uint32(2);
            case 'int32'
                obj.TypeByteSize=uint32(4);
            case 'uint32'
                obj.TypeByteSize=uint32(4);
            case 'logical'
                obj.TypeByteSize=uint32(1);
            case 'boolean'
                obj.TypeByteSize=uint32(1);
            otherwise
                error(message('soc:utils:AXIRegisterDataTypeNotSupported',lower(obj.DataType)));
            end
            obj.DataByteLength=uint32(obj.DataLength*obj.TypeByteSize);
            RegistersPerElement=uint32(ceil(obj.TypeByteSize/obj.WORD_SIZE_IN_BYTES));
            obj.StridePerElement=uint32(obj.WORD_SIZE_IN_BYTES*RegistersPerElement);
            TotalIPCoreRegisters=double(RegistersPerElement*obj.DataLength);
            VectorExponent=ceil(log2(TotalIPCoreRegisters));
            BlockSize=pow2(VectorExponent)*obj.WORD_SIZE_IN_BYTES;
            obj.StrobeOffset=uint32(obj.RegisterOffset+BlockSize);
            obj.DeviceNameNull=[obj.DeviceName,char(0)];
        end

    end

    methods(Access=protected)
        function setupImpl(obj,data_in)
            obj.InitData(class(data_in),length(data_in));
            if isempty(coder.target)

                obj.DataFileFormat='TimeStamp';
                obj.SignalInfo.Name='AXI_Write';
                obj.SignalInfo.Dimensions=[size(data_in,1),1];
                obj.SignalInfo.DataType=class(data_in);
                obj.SignalInfo.IsComplex=false;
                setupImpl@ioplayback.SinkSystem(obj,data_in);
            elseif coder.target('Rtw')
                coder.cinclude('mw_axi_register_lct.h');
                obj.DeviceState=uint32(0);
                p_state=coder.opaque('MW_AXI_Register_struct *','NULL');
                p_state=coder.ceval('MW_AXI_REGISTER_INIT',obj.DeviceNameNull);
                obj.DeviceState=uint32(p_state);
            end
        end

        function varargout=stepImpl(obj,data_in)
            if isempty(coder.target)
                if isequal(obj.SendSimulationInputTo,'Output port')
                    varargout{1}=data_in;
                else
                    stepImpl@ioplayback.SinkSystem(obj,data_in);
                end
            else
                p_state=coder.opaque('MW_AXI_Register_struct *','NULL');
                p_state=coder.ceval('(MW_AXI_Register_struct *)',obj.DeviceState);
                if(obj.DataLength>1)
                    CurrentRegisterOffset=uint32(obj.RegisterOffset);
                    for i=1:obj.DataLength
                        coder.ceval('MW_AXI_REGISTER_WRITE',p_state,coder.rref(data_in(i)),uint32(CurrentRegisterOffset),obj.TypeByteSize);
                        CurrentRegisterOffset=uint32(CurrentRegisterOffset+obj.StridePerElement);
                    end
                    coder.ceval('MW_AXI_REGISTER_SYNC',p_state,uint32(obj.StrobeOffset));
                else
                    coder.ceval('MW_AXI_REGISTER_WRITE',p_state,coder.rref(data_in),uint32(obj.RegisterOffset),obj.TypeByteSize);
                end
                if isequal(obj.SendSimulationInputTo,'Output port')
                    varargout{1}=data_in;
                end
            end
        end

        function icon=getIconImpl(obj)
            icon=sprintf('Dev=%s',obj.DeviceName);
        end

        function varargout=getInputNamesImpl(~)
            varargout{1}='';
        end

        function varargout=getOutputNamesImpl(~)
            varargout{1}='';
        end

        function flag=isInactivePropertyImpl(obj,prop)%#ok<INUSL>
            switch(prop)
            case 'DeviceName'
                flag=false;
            case 'RegisterOffset'
                flag=false;
            otherwise


                flag=false;
            end
        end

        function releaseImpl(obj)
            if isempty(coder.target)
                releaseImpl@ioplayback.SinkSystem(obj);
            elseif coder.target('Rtw')
                p_state=coder.opaque('MW_AXI_Register_struct *','NULL');
                p_state=coder.ceval('(MW_AXI_Register_struct *)',obj.DeviceState);
                coder.ceval('MW_AXI_REGISTER_TERMINATE',p_state);
            end
        end

        function flag=isInputComplexityMutableImpl(~,~)
            flag=false;
        end

        function N=getNumInputsImpl(obj)%#ok<MANU>

            N=1;
        end

        function N=getNumOutputsImpl(obj)

            if isequal(obj.SendSimulationInputTo,'Output port')
                N=1;
            else
                N=0;
            end
        end

        function varargout=getOutputSizeImpl(obj)
            if isequal(obj.SendSimulationInputTo,'Output port')
                for k=1:getNumInputs(obj)
                    varargout{k}=propagatedInputSize(obj,k);
                end
            end

        end

        function varargout=isOutputComplexImpl(obj)
            if isequal(obj.SendSimulationInputTo,'Output port')
                for k=1:getNumInputs(obj)
                    varargout{k}=propagatedInputComplexity(obj,k);
                end
            end

        end

        function varargout=getOutputDataTypeImpl(obj)
            if isequal(obj.SendSimulationInputTo,'Output port')
                for k=1:getNumInputs(obj)
                    varargout{k}=propagatedInputDataType(obj,k);
                end
            end

        end

        function varargout=isOutputFixedSizeImpl(obj)
            if isequal(obj.SendSimulationInputTo,'Output port')
                for k=1:getNumInputs(obj)
                    varargout{k}=propagatedInputFixedSize(obj,k);
                end
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

    methods(Static)
        function name=getDescriptiveName()
            name='AXI4-REGISTER_WRITE';
        end

        function b=isSupportedContext(context)
            b=context.isCodeGenTarget('rtw')||context.isCodeGenTarget('sfun');
        end


        function updateBuildInfo(buildInfo,context)
            if context.isCodeGenTarget('rtw')||context.isCodeGenTarget('sfun')
                esbDir=soc.internal.getRootDir;
                addIncludePaths(buildInfo,fullfile(esbDir,'include'));
                addIncludeFiles(buildInfo,'mw_axi_register_lct.h');
                addIncludeFiles(buildInfo,'mw_axi_register.h');
                addSourceFiles(buildInfo,'mw_axi_register.c',fullfile(esbDir,'src'),'SkipForSil');
            end
        end

    end

end


