classdef AXIRegisterRead<ioplayback.SourceSystem&...
    ioplayback.system.mixin.Event&coder.ExternalDependency




































%#codegen
%#ok<*EMCA>

    properties(Nontunable)

        DeviceName='/dev/mwipcore';

        RegisterOffset=uint32(hex2dec('0100'));

        DataType='uint32';

        DataLength=uint32(1);

        DataSource='Internal';

        SampleTime=0.1;
    end

    properties(Nontunable,Hidden)
        StridePerElement=uint32(4);
        DataByteLength=uint32(1);
        TypeByteSize=uint32(1);
        DeviceNameNull=char(0);
        StrobeOffset=uint32(hex2dec('0100'));
    end

    properties(Access=private,Hidden)
        DeviceState=uint32(0);
EventTick
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
        'boolean',...
        });

        WORD_SIZE_IN_BYTES=uint32(4);
    end


    methods(Static,Access=protected)
        function header=getHeaderImpl()
            text2Display=DAStudio.message('soc:utils:AXIRegisterReadMaskDisplay');
            header=matlab.system.display.Header('soc.linux.AXIRegisterRead',...
            'ShowSourceLink',false,...
            'Title','AXI4-Register Read',...
            'Text',text2Display);
        end
    end

    methods
        function obj=AXIRegisterRead(varargin)
            coder.allowpcode('plain');

            setProperties(obj,nargin,varargin{:});
            obj.DataTypeWarningasError=0;
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

        function set.SampleTime(obj,newTime)
            coder.extrinsic('error');
            coder.extrinsic('message');
            if isLocked(obj)
                error(message('svd:svd:SampleTimeNonTunable'))
            end
            newTime=ioplayback.internal.validateSampleTime(newTime);
            obj.SampleTime=newTime;
        end

        function checkDataFile(obj,dataFile)%#ok<INUSD>
            if isempty(coder.target)





            end
        end

        function event=getNextEvent(obj,eventID,~)
            if isequal(obj.SimulationOutput,'From input port')||isequal(obj.SimulationOutput,'Zeros')

                event=[];
                return;
            else

                event.ID=eventID;
                if obj.SampleTime>0

                    event.Time=obj.SampleTime*obj.EventTick;
                else



                    event.Time=obj.RecordedSampleTime*obj.EventTick;
                end
                obj.EventTick=obj.EventTick+1;
            end
        end

    end

    methods(Hidden)

        function InitData(obj)
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
            obj.DeviceNameNull=[obj.DeviceName,char(0)];
            RegistersPerElement=uint32(ceil(obj.TypeByteSize/obj.WORD_SIZE_IN_BYTES));
            obj.StridePerElement=uint32(obj.WORD_SIZE_IN_BYTES*RegistersPerElement);
            TotalIPCoreRegisters=double(RegistersPerElement*obj.DataLength);
            VectorExponent=ceil(log2(TotalIPCoreRegisters));
            BlockSize=pow2(VectorExponent)*obj.WORD_SIZE_IN_BYTES;
            obj.StrobeOffset=uint32(obj.RegisterOffset+BlockSize);
        end

    end

    methods(Access=protected)

        function st=getSampleTimeImpl(obj)
            if obj.SampleTime==-1
                st=createSampleTime(obj,'Type','Inherited');
            else
                st=createSampleTime(obj,'Type','Discrete','SampleTime',obj.SampleTime);
            end
        end

        function setupImpl(obj,varargin)
            obj.InitData();
            obj.EventTick=0;
            if isequal(obj.DataType,'boolean')
                dType='logical';
            else
                dType=obj.DataType;
            end

            if isempty(coder.target)

                if isequal(obj.SimulationOutput,'From input port')
                    dSize=propagatedInputSize(obj,1);
                    validateattributes(varargin{1},{dType},...
                    {'size',dSize},'AXIRegisterRead','input');
                else
                    obj.DataFileFormat='TimeStamp';
                    obj.SignalInfo.Name='AXI4_Lite';
                    obj.SignalInfo.Dimensions=[obj.DataLength,1];
                    obj.SignalInfo.DataType=dType;
                    obj.SignalInfo.IsComplex=false;
                    setupImpl@ioplayback.SourceSystem(obj);
                    if isequal(obj.SimulationOutput,'From recorded file')
                        setup(obj.Reader,1);
                    end
                end
            end

            if coder.target('Rtw')
                coder.cinclude('mw_axi_register_lct.h');
                obj.DeviceState=uint32(0);
                p_state=coder.opaque('MW_AXI_Register_struct *','NULL');
                p_state=coder.ceval('MW_AXI_REGISTER_INIT',obj.DeviceNameNull);
                obj.DeviceState=uint32(p_state);
            end
        end


        function data_out=stepImpl(obj,varargin)
            if isequal(obj.DataType,'boolean')
                data_out=coder.nullcopy(cast((1:1:obj.DataLength)','logical'));
            else
                data_out=coder.nullcopy(cast((1:1:obj.DataLength)',obj.DataType));
            end

            if isempty(coder.target)
                switch(obj.SimulationOutput)
                case 'From input port'
                    data_out=varargin{1};
                otherwise
                    data_out=stepImpl@ioplayback.SourceSystem(obj);
                end
            elseif coder.target('Rtw')
                p_state=coder.opaque('MW_AXI_Register_struct *','NULL');
                p_state=coder.ceval('(MW_AXI_Register_struct *)',obj.DeviceState);
                if(obj.DataLength>1)
                    coder.ceval('MW_AXI_REGISTER_SYNC',p_state,uint32(obj.StrobeOffset));
                    CurrentRegisterOffset=uint32(obj.RegisterOffset);
                    for i=1:obj.DataLength
                        coder.ceval('MW_AXI_REGISTER_READ',p_state,coder.ref(data_out(i)),uint32(CurrentRegisterOffset),obj.TypeByteSize);
                        CurrentRegisterOffset=uint32(CurrentRegisterOffset+obj.StridePerElement);
                    end
                else
                    coder.ceval('MW_AXI_REGISTER_READ',p_state,coder.ref(data_out),uint32(obj.RegisterOffset),obj.TypeByteSize);
                end
            end
        end

        function icon=getIconImpl(obj)
            icon=sprintf('Dev=%s',obj.DeviceName);
        end


        function outputname=getOutputNamesImpl(~)
            outputname='';
        end

        function flag=isInactivePropertyImpl(obj,prop)
            switch(prop)
            case 'DataLength'
                flag=false;
            case 'DeviceName'
                flag=false;
            case 'RegisterOffset'
                flag=false;
            case 'DataType'
                flag=false;
            case 'SampleTime'
                flag=false;
            otherwise


                flag=false;
            end
        end

        function releaseImpl(obj)
            if isempty(coder.target)
                if~isequal(obj.SimulationOutput,'From input port')
                    releaseImpl@ioplayback.SourceSystem(obj);
                end
            elseif coder.target('Rtw')
                p_state=coder.opaque('MW_AXI_Register_struct *','NULL');
                p_state=coder.ceval('(MW_AXI_Register_struct *)',obj.DeviceState);
                coder.ceval('MW_AXI_REGISTER_TERMINATE',p_state);
            end
        end
        function flag=isInputSizeMutableImpl(~,~)
            flag=false;
        end

        function flag=isInputComplexityMutableImpl(~,~)
            flag=false;
        end


        function varargout=isOutputFixedSizeImpl(~)
            varargout{1}=true;
        end

        function out=getOutputSizeImpl(obj)
            if isequal(obj.SimulationOutput,'From input port')
                out=propagatedInputSize(obj,1);
            else
                out=[double(obj.DataLength),1];
            end
        end

        function out=getOutputDataTypeImpl(obj)
            if isequal(obj.SimulationOutput,'From input port')
                out=propagatedInputDataType(obj,1);
            else
                if isequal(obj.DataType,'boolean')
                    out='logical';
                else
                    out=obj.DataType;
                end
            end
        end

        function N=getNumInputsImpl(obj)

            N=0;
            if isequal(obj.SimulationOutput,'From input port')
                N=1;
            end
        end

        function N=getNumOutputsImpl(obj)%#ok<MANU>

            N=1;
        end

        function varargout=isOutputComplexImpl(~)
            varargout{1}=false;
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
            name='AXI4-REGISTER_READ';
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


