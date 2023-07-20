classdef SLComponentMatcher<handle




    properties(Access=private)
PortMatcher
DataTransferMatcher
RateTransitionMatcher
FcnCallInportMatcher
FunctionCallerMatcher
InternalTriggerMatcher
ServerFunctionMatcher
StepFunctionMatcher
ArgInMatcher
ArgOutMatcher
ModelScopedParameterMatcher
InitializeFunctionMatcher
TerminateFunctionMatcher
ResetFunctionMatcher


SignalMatcher
StateMatcher
DataStoreMatcher
SynthesizedDataStoreMatcher

MdlName
        M3iParam2SlParamMap containers.Map
    end

    methods(Access=public)
        function this=SLComponentMatcher(mdlName)

            this.PortMatcher=autosar.updater.modelMapping.Port(mdlName);
            this.DataTransferMatcher=autosar.updater.modelMapping.DataTransfer(mdlName);
            this.RateTransitionMatcher=autosar.updater.modelMapping.RateTransition(mdlName);
            this.FcnCallInportMatcher=autosar.updater.modelMapping.FcnCallInport(mdlName);
            this.FunctionCallerMatcher=autosar.updater.modelMapping.FunctionCaller(mdlName);
            this.InternalTriggerMatcher=autosar.updater.modelMapping.InternalTrigger(mdlName);
            this.ServerFunctionMatcher=autosar.updater.modelMapping.ServerFunction(mdlName);
            this.StepFunctionMatcher=autosar.updater.modelMapping.StepFunction(mdlName);
            this.ArgInMatcher=autosar.updater.modelMapping.ArgIn(mdlName);
            this.ArgOutMatcher=autosar.updater.modelMapping.ArgOut(mdlName);
            this.ModelScopedParameterMatcher=autosar.updater.modelMapping.ModelScopedParameter(mdlName);
            this.InitializeFunctionMatcher=autosar.updater.modelMapping.InitializeFunction(mdlName);
            this.TerminateFunctionMatcher=autosar.updater.modelMapping.TerminateFunction(mdlName);
            this.ResetFunctionMatcher=autosar.updater.modelMapping.ResetFunction(mdlName);
            this.SignalMatcher=autosar.updater.modelMapping.Signal(mdlName);
            this.StateMatcher=autosar.updater.modelMapping.State(mdlName);
            this.DataStoreMatcher=autosar.updater.modelMapping.DataStore(mdlName);
            this.SynthesizedDataStoreMatcher=autosar.updater.modelMapping.SynthesizedDataStore(mdlName);

            this.MdlName=mdlName;


            this.markAsUnmatched();

            this.M3iParam2SlParamMap=containers.Map();
            mappingManager=get_param(this.MdlName,'MappingManager');
            modelMapping=mappingManager.getActiveMappingFor('AutosarTarget');

            if~isempty(modelMapping)
                for ii=1:numel(modelMapping.LookupTables)
                    lut=modelMapping.LookupTables(ii);
                    arParamInfo=lut.MappedTo;
                    if strcmp(arParamInfo.ParameterAccessMode,'PortParameter')
                        this.M3iParam2SlParamMap([arParamInfo.Port,'_',arParamInfo.Parameter])=lut.LookupTableName;
                    else
                        this.M3iParam2SlParamMap(arParamInfo.Parameter)=lut.LookupTableName;
                    end
                end


                for ii=1:numel(modelMapping.ModelScopedParameters)
                    modelScopedParam=modelMapping.ModelScopedParameters(ii);
                    arParamInfo=modelScopedParam.MappedTo;
                    if strcmp(arParamInfo.ArDataRole,'PortParameter')
                        port=arParamInfo.getPerInstancePropertyValue('Port');
                        dataElement=arParamInfo.getPerInstancePropertyValue('DataElement');
                        this.M3iParam2SlParamMap([port,'_',dataElement])=modelScopedParam.Parameter;
                    else
                        parameter=arParamInfo.getPerInstancePropertyValue('Name');
                        this.M3iParam2SlParamMap(parameter)=modelScopedParam.Parameter;
                    end
                end


                vars=autosar.validation.CompiledModelUtils.getReferencedWSVars(this.MdlName,false);
                for i=1:length(vars)
                    obj=vars(i).obj;
                    objName=vars(i).objName;


                    if((isa(obj,'AUTOSAR.Parameter')&&...
                        strcmp(vars(i).obj.CoderInfo.StorageClass,'Custom')&&...
                        strcmp(obj.CoderInfo.CustomStorageClass,'CalPrm'))...
                        ||...
                        (isa(vars(i).obj,'Simulink.Parameter')&&...
                        strcmp(vars(i).obj.CoderInfo.StorageClass,'Custom')&&...
                        isa(vars(i).obj.CoderInfo.CustomAttributes,'SimulinkCSC.AttribClass_AUTOSAR_CalPrm'))...
                        )
                        attr=obj.CoderInfo.CustomAttributes;
                        this.M3iParam2SlParamMap([attr.PortName,'_',attr.ElementName])=objName;
                    end
                end
            end
        end

        function[isMapped,blockPath]=isRunnableMapped(this,m3iRunnable)

            isMapped=false;
            blockPath=[];

            if~autosar.api.Utils.isMapped(this.MdlName)
                return
            end

            [isMapped,blockPath]=this.FcnCallInportMatcher.isMapped(m3iRunnable);
            if isMapped,return;end

            [isMapped,blockPath]=this.ServerFunctionMatcher.isMapped(m3iRunnable);
            if isMapped,return;end

            [isMapped,~]=this.isRunnableMappedToStepFcn(m3iRunnable);
            if isMapped,return;end

            [isMapped,blockPath]=this.InitializeFunctionMatcher.isMapped(m3iRunnable);
            if isMapped,return;end

            [isMapped,blockPath]=this.TerminateFunctionMatcher.isMapped(m3iRunnable);
            if isMapped,return;end

            [isMapped,blockPath]=this.ResetFunctionMatcher.isMapped(m3iRunnable);
            if isMapped,return;end
        end

        function[isMapped,periodStr]=isRunnableMappedToStepFcn(this,m3iRunnable)
            [isMapped,periodStr]=this.StepFunctionMatcher.isMapped(m3iRunnable);
        end

        function slParam=getSlParamName(this,paramName)
            if this.M3iParam2SlParamMap.isKey(paramName)
                slParam=this.M3iParam2SlParamMap(paramName);
            else
                slParam=paramName;
            end


            this.ModelScopedParameterMatcher.isMapped(slParam);
        end

        function[isMapped,blks]=isPortOperationMapped(this,sys,m3iClientPort,m3iOperation)
            [isMapped,blks]=this.FunctionCallerMatcher.isMapped(sys,m3iClientPort,m3iOperation);
        end

        function[isMapped,blk]=isServerFunctionMapped(this,sys,m3iServerPort,m3iMethod)
            [isMapped,blk]=this.ServerFunctionMatcher.isMapped(sys,m3iServerPort,m3iMethod);
        end

        function[isMapped,blks]=isInternalTriggerPointMapped(this,...
            m3iTrigPoint,m3iTriggeringRun,triggeringRunPath)
            [isMapped,blks]=this.InternalTriggerMatcher.isMapped(...
            m3iTrigPoint,m3iTriggeringRun,triggeringRunPath);
        end

        function[isMapped,slObj]=isPortElementMapped(this,m3iPort,m3iElement,slBlockType)
            [isMapped,slObj]=this.PortMatcher.isMapped(m3iPort,m3iElement,slBlockType);
        end

        function[isMapped,isUpdatedBlk]=isIsUpdatedPortElementMapped(this,m3iPort,m3iElement,slBlockType)
            [isMapped,isUpdatedBlk]=this.PortMatcher.isMapped(m3iPort,m3iElement,slBlockType,'IsUpdated');
        end

        function[isMapped,errorStatusBlk]=isErrorStatusPortElementMapped(this,m3iPort,m3iElement,slBlockType)
            [isMapped,errorStatusBlk]=this.PortMatcher.isMapped(m3iPort,m3iElement,slBlockType,'ErrorStatus');
        end

        function[isMapped,signalName]=isDataTransferMapped(this,m3iIrvData)
            [isMapped,signalName]=this.DataTransferMatcher.isMapped(m3iIrvData);
        end


        function[isMapped,blockPath]=isRateTransitionMapped(this,m3iIrvData)
            [isMapped,blockPath]=this.RateTransitionMatcher.isMapped(m3iIrvData);
        end


        function[isMapped,blockPath]=isArgumentMapped(this,sys,m3iArgument,slArgDirection)
            assert(ismember(slArgDirection,{'ArgIn','ArgOut'}),'slArgDirection should be ArgIn or ArgOut');

            if strcmp(slArgDirection,'ArgIn')
                [isMapped,blockPath]=this.ArgInMatcher.isMapped(sys,m3iArgument,slArgDirection);
            else
                [isMapped,blockPath]=this.ArgOutMatcher.isMapped(sys,m3iArgument,slArgDirection);
            end
        end


        function[isMapped,sigObj]=isArTypedPIMMapped(self,m3iData)
            [isMapped,sigObj]=self.isMappedStateSignalDSM(m3iData,'ArTypedPerInstanceMemory');
        end

        function[isMapped,sigObj]=isStaticMemoryMapped(self,m3iData)
            [isMapped,sigObj]=self.isMappedStateSignalDSM(m3iData,'StaticMemory');
        end

        function[isMapped,dsmName,slObj]=isMappedToSynthDSM(this,m3iData,type)
            if nargin<3
                type='';
            end
            [isMapped,dsmName,slObj]=this.SynthesizedDataStoreMatcher.isMapped(m3iData,type);
        end

        function[isMapped,blockH,slObj]=isMappedToDSM(this,m3iData,type)
            if nargin<3
                type='';
            end
            [isMapped,blockH,slObj]=this.DataStoreMatcher.isMapped(m3iData,type);
        end

        function[isMapped,lineH,slObj]=isMappedToSignal(this,m3iData,type)
            if nargin<3
                type='';
            end
            [isMapped,lineH,slObj]=this.SignalMatcher.isMapped(m3iData,type);
        end

        function[isMapped,stateOwnerBlkH,stateName,slObj]=isMappedToState(this,m3iData,type)
            if nargin<3
                type='';
            end
            [isMapped,stateOwnerBlkH,stateName,slObj]=this.StateMatcher.isMapped(m3iData,type);
        end

        function[isMapped,sigObj]=isMappedStateSignalDSM(self,m3iData,type)
            [isMapped,~,sigObj]=self.isMappedToDSM(m3iData,type);
            if isMapped
                return;
            end

            [isMapped,~,sigObj]=self.isMappedToSignal(m3iData,type);
            if isMapped
                return;
            end

            [isMapped,~,~,sigObj]=self.isMappedToState(m3iData,type);
            if isMapped
                return;
            end

            if slfeature('ArSynthesizedDS')>0
                [isMapped,~,sigObj]=self.isMappedToSynthDSM(m3iData,type);
            end
        end


        function doDeletions(this,changeLogger,deletionMode)
            this.PortMatcher.logDeletions(changeLogger,deletionMode);
            this.DataTransferMatcher.logDeletions(changeLogger);
            this.RateTransitionMatcher.logDeletions(changeLogger);
            this.FcnCallInportMatcher.logDeletions(changeLogger);
            this.FunctionCallerMatcher.logDeletions(changeLogger);
            this.InternalTriggerMatcher.logDeletions(changeLogger);
            this.ServerFunctionMatcher.logDeletions(changeLogger);
            this.StepFunctionMatcher.logDeletions(changeLogger);
            this.ArgInMatcher.logDeletions(changeLogger);
            this.ArgOutMatcher.logDeletions(changeLogger);
            this.ModelScopedParameterMatcher.logDeletions(changeLogger);
            this.InitializeFunctionMatcher.logDeletions(changeLogger);
            this.TerminateFunctionMatcher.logDeletions(changeLogger);
            this.ResetFunctionMatcher.logDeletions(changeLogger);
            this.SignalMatcher.logDeletions(changeLogger);
            this.StateMatcher.logDeletions(changeLogger);
            this.DataStoreMatcher.logDeletions(changeLogger);
            if slfeature('ArSynthesizedDS')>0
                this.SynthesizedDataStoreMatcher.logDeletions(changeLogger);
            end
        end
    end

    methods(Access=private)
        function markAsUnmatched(this)
            this.PortMatcher.markAsUnmatched();
            this.DataTransferMatcher.markAsUnmatched();
            this.RateTransitionMatcher.markAsUnmatched();
            this.FcnCallInportMatcher.markAsUnmatched();
            this.FunctionCallerMatcher.markAsUnmatched();
            this.InternalTriggerMatcher.markAsUnmatched();
            this.ServerFunctionMatcher.markAsUnmatched();
            this.StepFunctionMatcher.markAsUnmatched();
            this.ArgInMatcher.markAsUnmatched();
            this.ArgOutMatcher.markAsUnmatched();
            this.ModelScopedParameterMatcher.markAsUnmatched();
            this.InitializeFunctionMatcher.markAsUnmatched();
            this.TerminateFunctionMatcher.markAsUnmatched();
            this.ResetFunctionMatcher.markAsUnmatched();
            this.SignalMatcher.markAsUnmatched();
            this.StateMatcher.markAsUnmatched();
            this.DataStoreMatcher.markAsUnmatched();
            if slfeature('ArSynthesizedDS')>0
                this.SynthesizedDataStoreMatcher.markAsUnmatched();
            end
        end
    end
end



