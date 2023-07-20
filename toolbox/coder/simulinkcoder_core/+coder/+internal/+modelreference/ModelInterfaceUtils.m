


classdef ModelInterfaceUtils<handle
    properties(Access=public)




        CanonicalParameters={}
        TestpointedParameters={}
        UsedCanonicalParametersIndexes=[]

        Inports={}
        Outports={}
        NumberOfPorts=0

        ParameterChangeEventTID=-1;

        ZCVectorLength=0
        ZcSignalInfos={}

        HasVarDimsInport=false
        HasVarDimsOutport=false

        InputPortIndexMap=[]
    end


    properties(Access=private)
ModelInterface
    end



    methods
        function this=ModelInterfaceUtils(modelInterface)
            this.ModelInterface=modelInterface;


            this.init;
        end


        function init(this)
            this.getCanonicalParameters;
            this.getTestpointedParameters;
            this.UsedCanonicalParametersIndexes=this.getUsedCanonicalParameterIndexes;

            this.getInports;
            this.getOutports;
            this.getZeroCrossingInformation;
            this.getParameterChangeEventTID;


            this.HasVarDimsInport=this.hasVarDimsInport;
            this.HasVarDimsOutport=this.hasVarDimsOutport;
            this.NumberOfPorts=length(this.Inports)+length(this.Outports);
        end
    end



    methods
        function modelInterface=getModelInterface(this)
            modelInterface=this.ModelInterface;
        end

        function globalTidString=getGlobalTidString(this)
            globalTidString=this.ModelInterface.GlobalScopeTid;
        end

        function ret=getStringLiteralCast(this,str)



            ret=str;
            if~contains(str,'"')
                ret=['"',ret,'"'];
            end

            if this.isGeneratingTargetInCpp
                ret=['const_cast<char *>(',ret,')'];
            end
        end

        function ret=getssMatrixType(this,num)


            str=num2str(num);
            if this.isGeneratingTargetInCpp
                ret=['static_cast<ssMatrixType>(',str,')'];
            else
                ret=str;
            end
        end
    end



    methods
        function status=isModelOutputSizeDependOnlyInputSize(this)
            if isfield(this.ModelInterface,'SignalSizeComputeType')
                status=this.ModelInterface.SignalSizeComputeType;
            else
                status=false;
            end
        end


        function isMI=isMultiInstance(this)
            isMI=this.ModelInterface.HasDWork;
        end


        function status=isDirectFeedThroughPort(this,portIdx)
            status=this.ModelInterface.DirectFeedThrough(portIdx);
        end


        function status=isConstantBlock(this)
            status=this.ModelInterface.IsConstant;
        end


        function status=isAPeriodicTriggered(this)
            status=this.ModelInterface.IsAPeriodicTriggered;
        end


        function status=disallowSampleTimeInheritance(this)
            status=this.ModelInterface.DisallowSampleTimeInheritance;
        end

        function status=needAbsoluteTime(this)
            status=this.ModelInterface.NeedAbsoluteTime;
        end
    end


    methods(Access=private)
        function getOutports(this)
            this.Outports=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'Outports');
        end


        function getInports(this)
            this.Inports=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'Inports');
            this.InputPortIndexMap=find(cellfun(@(port)(~port.IsFcnCall),this.Inports));
        end

        function getParameterChangeEventTID(this)
            this.ParameterChangeEventTID=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'ParameterChangeEventTID');
        end

        function getCanonicalParameters(this)
            this.CanonicalParameters=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'CanonicalParameters');
        end

        function getTestpointedParameters(this)
            this.TestpointedParameters=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'TestpointedParameters');
        end

        function indexes=getUsedCanonicalParameterIndexes(this)
            indexes=find(cellfun(@(param)(param.IsUsed>0),this.CanonicalParameters))-1;
        end


        function getZeroCrossingInformation(this)
            this.ZCVectorLength=this.ModelInterface.ZCVectorLength;
            this.ZcSignalInfos=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'ZcSignalInfos');
        end

        function hasVarDims=hasVarDimsInport(this)
            if~isempty(this.Inports)
                hasVarDims=this.hasVarDimsPort(this.Inports);
            else
                hasVarDims=false;
            end
        end


        function hasVarDims=hasVarDimsOutport(this)
            if~isempty(this.Outports)
                hasVarDims=this.hasVarDimsPort(this.Outports);
            else
                hasVarDims=false;
            end
        end
    end

    methods(Access=protected)
        function ret=isGeneratingTargetInCpp(this)
            ret=slfeature('ModelReferenceHonorsSimTargetLang')>0&&strcmp(get_param(this.ModelInterface.Name,'SimTargetLang'),'C++');
        end
    end


    methods(Static,Access=private)
        function hasVarDims=hasVarDimsPort(ports)
            hasVarDims=false;
            numberOfPorts=length(ports);
            for portIdx=1:numberOfPorts
                if ports{portIdx}.IsVarDim
                    hasVarDims=true;
                    return;
                end
            end
        end
    end
end


