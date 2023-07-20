




classdef EmitterDb<sldv.code.internal.EmitterDb

    methods




        function obj=EmitterDb(varargin)
            obj.extractAnalysisInfo(varargin{:});
        end





        function covStruct=getCodeCoverageInfo(obj,blockHandle,~)
            covStruct=struct([]);
            sfunctionName=get_param(blockHandle,'FunctionName');
            if obj.CoverageInfos.isKey(sfunctionName)
                covStruct=obj.CoverageInfos(sfunctionName);
            else
                tmpDir=tempname;
                cleanupDir=onCleanup(@()sldv.code.internal.removeDir(tmpDir));
                dbFile=sldv.code.sfcn.internal.extractSFcnDb(sfunctionName,tmpDir);
                if~isempty(dbFile)
                    traceabilityData=codeinstrum.internal.TraceabilityData(dbFile);


                    options=internal.cxxfe.instrum.InstrumOptions.load(traceabilityData);
                    options.FunEntry=1;
                    options.save(traceabilityData);

                    traceabilityData.computeShortestUniquePaths();
                    covStruct=struct('codeTr',traceabilityData);
                    obj.CoverageInfos(sfunctionName)=covStruct;


                    traceabilityData.close();
                    clear('cleanupDir');
                end
            end
        end





        function moduleH=getModuleHandle(~,slHandle,~)
            moduleH=bdroot(slHandle);
        end




        function codeKind=getCodeKind(~)
            codeKind='sfcn';
        end
    end

    methods(Access=protected)




        function extractAnalysisInfo(obj,varargin)
            obj.CodeDb=sldv.code.sfcn.internal.InstanceDb();

            obj.CoverageInfos=containers.Map('KeyType','char','ValueType','any');

            testComp=Sldv.Token.get.getTestComponent();
            opts=testComp.activeSettings;

            obj.AnalysisMode=sldv.code.CodeAnalyzer.getAnalysisModeFromOptions(opts);

            if strcmp(opts.SFcnSupport,'on')
                analysisInfo=testComp.analysisInfo;
                analyzedModelName=get_param(analysisInfo.analyzedModelH,'Name');

                model=analysisInfo.designModelH;
                if model~=analysisInfo.analyzedModelH
                    obj.OriginalModel=get_param(model,'Name');
                end


                sldv.code.sfcn.modelAnalysis(analyzedModelName,opts,'testComponent',testComp,'compileModel',false);

                loader=sldv.code.sfcn.internal.CodeInfoLoader();
                obj.CodeDb=loader.loadCodeDb(model,opts);
            end
        end
























        function[analysis,info]=getEntryInfoFromHandle(obj,slHandle)

            analysis=[];
            info=[];

            if obj.CodeDb.hasInfo()

                functionName=get_param(slHandle,'FunctionName');

                checksum=sldv.code.sfcn.getSFcnChecksum(functionName);

                if~isempty(checksum)
                    blockObject=get_param(slHandle,'Object');
                    blockInfo=sldv.code.sfcn.SFunctionInstanceInfo(checksum);
                    blockInfo.setInstanceIdFromHandle(slHandle);

                    testComp=Sldv.Token.get.getTestComponent();
                    sldvOptions=testComp.activeSettings;
                    getParameterValues=~strcmp(sldvOptions.Parameters,'on');

                    blockInfo.setPortsFromRuntimeObject(blockObject.RuntimeObject,getParameterValues);

                    if~isempty(obj.OriginalModel)
                        modelName=get_param(bdroot(slHandle),'Name');
                        blockInfo.updateModelName(modelName,obj.OriginalModel);
                    end

                    [analysis,info]=obj.CodeDb.getAnalysisInfo(functionName,blockInfo,obj.AnalysisMode);
                end
            end
        end
    end

    methods(Static=true)

        function isComplex=isComplexPort(port)
            isComplex=strcmp(port.Complexity,'Complex');
        end



        function compatible=checkComplexPortOrParameter(blockHandle)
            compatible=true;

            rtObj=get_param(blockHandle,'RuntimeObject');
            numInputs=rtObj.NumInputPorts;
            for ii=1:numInputs
                inputPort=rtObj.InputPort(ii);
                if~inputPort.IsBus&&sldv.code.sfcn.internal.EmitterDb.isComplexPort(inputPort)
                    compatible=false;
                    return
                end
            end

            numOutputs=rtObj.NumOutputPorts;
            for ii=1:numOutputs
                outputPort=rtObj.OutputPort(ii);
                if~outputPort.IsBus&&sldv.code.sfcn.internal.EmitterDb.isComplexPort(outputPort)
                    compatible=false;
                    return
                end
            end

            numRtPrms=rtObj.NumRuntimePrms;
            for ii=1:numRtPrms
                rtPrm=rtObj.RuntimePrm(ii);
                if sldv.code.sfcn.internal.EmitterDb.isComplexPort(rtPrm)
                    compatible=false;
                    return
                end
            end

            numDlgPrms=rtObj.NumDialogPrms;
            for ii=1:numDlgPrms
                dlgPrm=rtObj.DialogPrm(ii);
                if sldv.code.sfcn.internal.EmitterDb.isComplexPort(dlgPrm)
                    compatible=false;
                    return
                end
            end
        end

    end
end


