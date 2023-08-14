




classdef CompiledPortInfo<handle
    properties(SetAccess=private,GetAccess=public)
DataType
DesignMin
DesignMax
Dimensions
DimensionStr
DimensionsMode
SymbolicDimensions
Complexity
SampleTime
SampleTimeStr
SamplingMode
        IsTriggered=false

IsStructBus
AliasThruDataType
RTWSignalIdentifier
SignalObject
RTWStorageClass
RTWStorageTypeQualifier
VarSizeSig

Units
    end

    properties(Constant,Access=private)
        DefaultSymbolicDimensions={'NOSYMBOLIC','INHERIT'};
    end


    properties(Transient,GetAccess=private,SetAccess=private)
PortHandle
    end


    methods(Access=public)
        function this=CompiledPortInfo(portHandle)
            this.PortHandle=portHandle;
            this.init;
        end


        function signalObj=createSignalObject(this,initValue)
            signalObj=Simulink.Signal;
            signalObj.DataType=this.DataType;
            signalObj.Min=this.DesignMin;
            signalObj.Max=this.DesignMax;
            signalObj.Dimensions=this.Dimensions;
            signalObj.DimensionsMode=this.DimensionsMode;
            signalObj.Complexity=this.Complexity;


            signalObj.SampleTime=-1;

            signalObj.SamplingMode=this.SamplingMode;
            signalObj.InitialValue=initValue;
        end
    end


    methods(Hidden,Access=public)
        function copySampleTimeInfo(this,compiledPortInfo)
            this.SampleTime=compiledPortInfo.SampleTime;
            this.SampleTimeStr=compiledPortInfo.SampleTimeStr;
        end

        function dimsStr=computeDimensions(this)
            if~any(strcmpi(this.SymbolicDimensions,this.DefaultSymbolicDimensions))
                dimsStr=this.SymbolicDimensions;
            else
                dimsStr=this.DimensionStr;
            end
        end
    end

    methods(Static,Access=public)
        function[ts,tsStr,isTriggered]=getSampleTimeImpl(portHandle)
            compTs=get_param(portHandle,'CompiledPortSampleTime');
            if isempty(compTs)
                DAStudio.error('Simulink:Variants:SampleTimeEmptyDueToVariants');
            end
            assert(~isempty(compTs),'CompiledPortSampleTime is empty');



            isTriggered=false;
            if iscell(compTs)
                tsStr='';
                ts=compTs;
            else






                if isinf(compTs(1))

                    tsStr='inf';
                    ts=inf;
                else
                    if(length(compTs)==2)&&(compTs(1)==0)&&(compTs(2)==0)

                        tsStr='0';
                        ts=0;
                    else

                        if(compTs(1)==-1&&compTs(2)==-1)
                            isTriggered=true;
                            ts=compTs(3:4);
                        else
                            ts=compTs;
                        end

                        tsStr=['[',sprintf('%.17g',ts(1)),',',sprintf('%.17g',ts(2)),']'];
                    end
                end
            end
        end
    end


    methods(Access=private)
        function init(this)
            this.DesignMin=get_param(this.PortHandle,'CompiledPortDesignMin');
            this.DesignMax=get_param(this.PortHandle,'CompiledPortDesignMax');
            this.AliasThruDataType=get_param(this.PortHandle,'CompiledPortAliasedThruDataType');
            this.IsStructBus=logical(get_param(this.PortHandle,'IsCompiledStructureBus'));
            this.RTWSignalIdentifier=get_param(this.PortHandle,'CompiledRTWSignalIdentifier');
            this.SignalObject=get_param(this.PortHandle,'CompiledSignalObject');
            this.RTWStorageClass=get_param(this.PortHandle,'CompiledRTWStorageClass');
            this.RTWStorageTypeQualifier=get_param(this.PortHandle,'CompiledRTWStorageTypeQualifier');
            this.DataType=get_param(this.PortHandle,'CompiledPortDataType');
            this.Units=get_param(this.PortHandle,'CompiledPortUnit');
            this.getDimensions;
            this.getDimensionsMode;
            this.getComplexity;
            this.getFrameData;
            this.getSampleTime;
            this.getVarSizeSig;
        end

        function getDimensions(this)
            compDims=get_param(this.PortHandle,'CompiledPortDimensions');
            if isempty(compDims)
                DAStudio.error('Simulink:Variants:DimensionEmptyDueToVariants');
            end
            assert(~isempty(compDims),'CompiledPortDimensions is empty');
            if(compDims(1)>=2)
                nDims=compDims(1);
                dimsStr='';
                spcVal='';
                for k=1:nDims
                    if k>1
                        spcVal=' ';
                    end
                    dimsStr=sprintf('%s%s%d',dimsStr,spcVal,compDims(k+1));
                end
                dimsStr=['[',dimsStr,']'];
                dims=compDims(2:end);
            else
                dimsStr=sprintf('%d',compDims(2));
                dims=compDims(2);
            end


            this.Dimensions=dims;
            this.DimensionStr=dimsStr;
            this.SymbolicDimensions=get_param(this.PortHandle,'CompiledPortSymbolicDimensions');
        end


        function getDimensionsMode(this)
            compDimsMode=get_param(this.PortHandle,'CompiledPortDimensionsMode');
            if compDimsMode==0
                this.DimensionsMode='Fixed';
            else
                this.DimensionsMode='Variable';
            end
        end


        function getVarSizeSig(this)
            compPortDimsMode=get_param(this.PortHandle,'CompiledPortDimensionsMode');
            if any(compPortDimsMode)
                this.VarSizeSig='Yes';
            else
                this.VarSizeSig='Inherit';
            end
        end


        function getComplexity(this)
            compComplex=get_param(this.PortHandle,'CompiledPortComplexSignal');
            if(compComplex==0)
                this.Complexity='real';
            else
                this.Complexity='complex';
            end
        end


        function getFrameData(this)
            compFrame=get_param(this.PortHandle,'CompiledPortFrameData');
            if compFrame==0
                this.SamplingMode='Sample based';
            else
                this.SamplingMode='Frame based';
            end
        end



        function getSampleTime(this)

            [this.SampleTime,this.SampleTimeStr,this.IsTriggered]=Simulink.CompiledPortInfo.getSampleTimeImpl(this.PortHandle);
        end
    end
end
