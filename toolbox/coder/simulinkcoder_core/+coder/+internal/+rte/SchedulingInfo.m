classdef SchedulingInfo




    properties
ModelHeader
ServiceHeader
SuppressErrorStatus

isMultiTasking

initTasks
outputTasks
periodicOutputTasks
asyncOutputTasks
unknownTasks
termTasks

TimingProperties
Ticks
TickOffsets

ModelName
ModelClassObjectName
ModelClassName
StopTime
FunctionHeaders
    end

    properties(Access=private)
codeDesc
codeDescUtils
    end

    methods

        function this=SchedulingInfo(modelName)
            this.codeDesc=coder.getCodeDescriptor(modelName);

            this.ModelName=this.codeDesc.ModelName;

            componentInterface=this.codeDesc.getFullComponentInterface;
            this.ModelHeader=[componentInterface.HeaderFile,'.h'];
            this.TimingProperties=componentInterface.TimingProperties;

            if~isempty(componentInterface.PlatformServices)&&...
                ~isempty(componentInterface.PlatformServices.ServiceHeaderFileName)
                this.ServiceHeader=this.codeDesc.getFullComponentInterface.PlatformServices.ServiceHeaderFileName;
            end

            this.SuppressErrorStatus=get_param(this.ModelName,'SuppressErrorStatus');


            internalDatas=componentInterface.InternalData;
            if~isempty(internalDatas)
                this.ModelClassObjectName=internalDatas(1).Implementation.Identifier;
                this.ModelClassName=internalDatas(1).Implementation.Type.Identifier;
            else
                this.ModelClassObjectName='';
                this.ModelClassName='';
            end

            this.StopTime=get_param(this.ModelName,'StopTime');

            compInterfaceAdaptor=rtw.connectivity.CIAdaptor(componentInterface);


            this.initTasks=this.extractTasks(compInterfaceAdaptor.InitializeFunctions);
            this.outputTasks=this.extractTasks(compInterfaceAdaptor.OutputFunctions);
            this.termTasks=this.extractTasks(compInterfaceAdaptor.TerminateFunctions);


            this.periodicOutputTasks=this.extractTasksBasedOnTiming('PERIODIC',compInterfaceAdaptor.OutputFunctions);
            this.asyncOutputTasks=this.extractTasksBasedOnTiming('ASYNCHRONOUS',compInterfaceAdaptor.OutputFunctions);

            this.unknownTasks=this.collectUnknownTasks(componentInterface.OutputFunctions);


            this.isMultiTasking=this.checkMultiTasking(this.ModelName,compInterfaceAdaptor);



            if~isempty(this.periodicOutputTasks)
                baseRate=this.getBaseRate();
                for ii=1:length(this.periodicOutputTasks)
                    this.Ticks(ii)=round(this.periodicOutputTasks(ii).codeInfoData.Timing.SamplePeriod/baseRate);
                    this.TickOffsets(ii)=...
                    round(this.periodicOutputTasks(ii).codeInfoData.Timing.SampleOffset/baseRate);
                end
            end


            this.FunctionHeaders=this.collectFunctionHeaders();
        end

        function baseRate=getBaseRate(this)

            threshold=10^9;
            baseRate=this.periodicOutputTasks(1).codeInfoData.Timing.SamplePeriod*threshold;
            for ii=2:numel(this.periodicOutputTasks)
                baseRate=gcd(baseRate,this.periodicOutputTasks(ii).codeInfoData.Timing.SamplePeriod*threshold);
            end
            baseRate=baseRate/threshold;
        end
    end

    methods(Access=private)
        function tasks=extractTasksBasedOnTiming(~,timingMode,outputTasks)
            numTasks=length(outputTasks);
            tasks=[];
            for i=1:numTasks
                if~isempty(outputTasks(i).Timing)&&...
                    strcmp(outputTasks(i).Timing.TimingMode,timingMode)
                    tasks(end+1).codeInfoData=outputTasks(i);
                    tasks(end).id=i;
                end
            end
        end

        function tasks=extractTasks(~,functions)
            numTasks=length(functions);
            tasks=[];
            for i=1:numTasks
                tasks(end+1).codeInfoData=functions(i);
                tasks(end).id=i;
            end
        end

        function timing=findTimingRates(~,timingInterfaces,timingMode)

            numTimings=length(timingInterfaces);
            keepIndices=false(1,numTimings);
            for i=1:numTimings
                if strcmp(timingInterfaces(i).TimingMode,timingMode)
                    keepIndices(i)=true;
                end
            end

            timing=timingInterfaces(keepIndices);
        end

        function isMultiTasking=checkMultiTasking(this,modelName,compInterfaceAdaptor)

            buildDirInfo=RTW.getBuildDir(modelName);
            modelRefRelativeBuildDir=buildDirInfo.ModelRefRelativeBuildDir;

            buildDir=buildDirInfo.BuildDirectory;
            inTheLoopType=rtw.pil.InTheLoopType.ModelBlockStandalone;

            clientInterface=coder.connectivity.CoreSimulinkInterface;
            tmwInternalArtifactsPath=fullfile(buildDirInfo.CodeGenFolder,modelRefRelativeBuildDir,'tmwinternal');

            locator=coder.internal.connectivity.ComponentAndSubComponentArtifactsWithoutMarker(...
            modelName,buildDir,inTheLoopType,tmwInternalArtifactsPath);
            infoStruct=locator.getInfoStruct();
            configInterface=coder.connectivity.SimulinkCoderConfig(infoStruct,modelName);

            rtw.connectivity.Utils.validateArg(configInterface,...
            'coder.connectivity.SimulinkCoderConfig');

            isExportFcnDiagram=clientInterface.isExportFcnModel(configInterface);

            if isExportFcnDiagram
                isMultiTasking=false;
            else
                switch length(this.periodicOutputTasks)
                case 0






                    periodicRates=this.findTimingRates(compInterfaceAdaptor.TimingProperties,'PERIODIC');
                    switch length(periodicRates)
                    case{0,1}



                        isMultiTasking=false;
                    otherwise

                        rtw.connectivity.ProductInfo.error('target',...
                        'CodeInfoOptimizedOutputTask',...
                        modelName);
                    end
                case 1

                    isMultiTasking=false;
                otherwise

                    isMultiTasking=true;
                end
            end
        end

        function unknownTaskNames=collectUnknownTasks(~,outputTasks)
            numOutputTasks=length(outputTasks);

            unknownTaskNames=string.empty;
            numUnknownTasks=0;
            for ii=numOutputTasks:-1:1
                timingMode=outputTasks(ii).Timing.TimingMode;
                if~strcmp(timingMode,'PERIODIC')&&~strcmp(timingMode,'ASYNCHRONOUS')
                    unknownTaskNames(numUnknownTasks+1)=outputTasks(ii).Prototype.Name;
                    numUnknownTasks=numUnknownTasks+1;
                end
            end
        end

        function headers=collectFunctionHeaders(this)

            functions={this.codeDesc.getFunctionInterfaces('Output'),...
            this.codeDesc.getFunctionInterfaces('Initialize'),...
            this.codeDesc.getFunctionInterfaces('Terminate')};

            headersRemaining=0;
            for ii=1:numel(functions)
                headersRemaining=headersRemaining+length(functions{ii});
            end

            for ii=1:numel(functions)
                func=functions{ii};
                for jj=1:numel(func)
                    proto=func(jj).Prototype;
                    headers(headersRemaining)=convertCharsToStrings(proto.HeaderFile);
                    headersRemaining=headersRemaining-1;
                end
            end

            if~isempty(headers)
                headers=unique(headers);
            end
        end
    end

end
