classdef(Sealed)CodegenInfoBuilder<codergui.internal.MathWorksOnly











    properties(Access=private)
ReportContext
InferenceReportData
RIContributors
GenVariableTypeInfo
    end

    methods
        function obj=CodegenInfoBuilder(reportContext,inferenceReportData,contributors,genVariableTypeInfo)







            if nargin<4
                genVariableTypeInfo=false;
            end
            if isempty(inferenceReportData)
                [fcnIds,scriptIds]=codergui.evalprivate('getIncludedFunctions',reportContext.Report);
                [inferenceReportData,~]=coder.report.contrib.InferenceReportContributor.processInferenceReport(reportContext,fcnIds,scriptIds);
            end
            if isempty(contributors)
                contributors=codergui.evalprivate('discoverReportContributors','instantiate');
            end
            riContributors={};
            for c=1:numel(contributors)
                contributor=contributors{c};
                if contributor.isRelevant(reportContext)
                    riContributor=contributor.getRIContributor(reportContext);
                    if~isempty(riContributor)
                        riContributors{end+1}=riContributor;%#ok<AGROW>
                    end
                end
            end
            obj.ReportContext=reportContext;
            obj.InferenceReportData=inferenceReportData;
            obj.RIContributors=riContributors;
            obj.GenVariableTypeInfo=genVariableTypeInfo;
        end

        function reportInfo=build(obj)
            if isempty(obj.InferenceReportData)
                reportInfo=coder.ReportInfo.empty();
                return;
            end

            codeFileExtensions=[".c",".cpp",".cu",".h",".hpp",".cuh",".m",".mlx"];

            [inputFiles,inputFilesMap]=obj.getInputFiles(codeFileExtensions);



            if~isempty(obj.ReportContext.Report.inference)
                typeConverter=coder.internal.mxInfoToCoderType(obj.ReportContext.Report.inference);
            end
            fcns=obj.getFunctions(inputFilesMap);
            vars=obj.getVariables(inputFilesMap);
            functions=repmat(coder.Function,numel(fcns),1);
            fcnIdToFcnObj=containers.Map('KeyType','double','ValueType','any');
            fcnIdx=0;

            msgs=obj.getMessages();
            messages=repmat(coder.Message,numel(msgs),1);
            msgIdx=0;

            issues=obj.getCodeInsights();
            codeInsights=repmat(coder.Message,numel(issues),1);
            issueIdx=0;

            for k=keys(inputFilesMap)
                key=k{1};
                inputFile=inputFilesMap(key);
                if isa(inputFile,'coder.CodeFile')
                    [lineMap,lineStarts1]=codergui.internal.createLineMap(inputFile.Text);
                    origLineMapLength=length(lineMap);
                    offset=[];
                    if isfile(inputFile.Path)
                        fileText=matlab.internal.getCode(inputFile.Path);

                        if length(fileText)~=length(inputFile.Text)
                            inputFile.setText(fileText);

                            [lineMap,lineStarts2]=codergui.internal.createLineMap(inputFile.Text);


                            offset=zeros(1,origLineMapLength);
                            offset(lineStarts1)=[0,diff(lineStarts2-lineStarts1)];
                            offset=cumsum(offset);
                        end
                    end
                end

                if~isempty(fcns)
                    includedFcns=fcns([fcns.ScriptID]==key);
                    includedVars=vars([fcns.ScriptID]==key);
                    for i=1:numel(includedFcns)
                        fcn=includedFcns(i);
                        varObjs=coder.Variable.empty();
                        if obj.GenVariableTypeInfo
                            variable=includedVars(i);
                            varObjs=obj.getVariableObj(variable,typeConverter);
                        end
                        fcnIdx=fcnIdx+1;
                        if fcn.Specialization<0
                            fcn.Specialization=0;
                        end
                        if fcn.FunctionType==coder.report.FunctionType.Method||...
                            fcn.FunctionType==coder.report.FunctionType.Constructor
                            if fcn.ClassSpecialization<0
                                fcn.ClassSpecialization=0;
                            end
                            functions(fcnIdx)=coder.Method(fcn.FunctionName,fcn.Specialization,...
                            fcn.ClassName,fcn.ClassSpecialization,inputFile,varObjs,obj.GenVariableTypeInfo);
                        else
                            functions(fcnIdx)=coder.Function(fcn.FunctionName,fcn.Specialization,...
                            inputFile,varObjs,obj.GenVariableTypeInfo);
                        end
                        fcnIdToFcnObj(fcn.FunctionID)=functions(fcnIdx);
                        setItemLocation(functions(fcnIdx),fcn.TextStart,fcn.TextLength);
                    end
                end

                [messages,msgIdx]=processMessages(msgs,msgIdx,messages);
                [codeInsights,issueIdx]=processMessages(issues,issueIdx,codeInsights);
            end

            function[messages,idx]=processMessages(msgs,idx,messages)
                if~isempty(msgs)
                    includedMsgs=msgs([msgs.ScriptID]==key);
                    for j=1:numel(includedMsgs)
                        msg=includedMsgs(j);
                        idx=idx+1;
                        if isfield(msg,'Category')
                            category=msg.Category;
                        else
                            category='';
                        end
                        if isfield(msg,'SubCategory')
                            subCategory=msg.SubCategory;
                        else
                            subCategory='';
                        end
                        messages(idx)=coder.Message(msg.MessageID,msg.MessageType,...
                        msg.Text,inputFile,category,subCategory);
                        setItemLocation(messages(idx),msg.TextStart,msg.TextLength);
                    end
                end
            end

            function setItemLocation(item,textStart,textLength)
                if isa(inputFile,'coder.CodeFile')
                    if textStart>=0&&textLength>0

                        idx=double(textStart+[1,textLength]);
                        if~isempty(offset)
                            idx=double(idx+offset(idx));
                        end
                        lines=double(lineMap(idx));
                        cols=idx-[sum(lineMap<=lines(1)-1),sum(lineMap<=lines(2)-1)];
                    else
                        [idx,lines,cols]=deal(zeros(1,2));
                    end
                    item.setLocation(idx,lines,cols);
                end
            end

            obj.generateCallTree(fcnIdToFcnObj,inputFilesMap);

            reportInfo=coder.ReportInfo(obj.getSummary(),obj.ReportContext.Config,inputFiles,...
            obj.getGeneratedFiles(codeFileExtensions),functions,messages,codeInsights,obj.getBuildLogs());
        end
    end

    methods(Access=private)
        function[inputFiles,inputFilesMap]=getInputFiles(obj,codeFileExtensions)
            if isfield(obj.InferenceReportData,'Scripts')&&~isempty(obj.InferenceReportData.Scripts)
                scripts=obj.InferenceReportData.Scripts;
                if iscell(scripts)
                    scripts=[scripts{:}];
                end
                inputFiles=repmat(coder.File,numel(scripts),1);

                isStateflow=obj.ReportContext.IsStateflow;
                for i=1:numel(scripts)
                    script=scripts(i);
                    [~,~,ext]=fileparts(script.Path);
                    isMathWorks=startsWith(script.Path,matlabroot);
                    if ismember(ext,codeFileExtensions)||(ext==""&&isStateflow)
                        inputFiles(i)=coder.CodeFile(script.Text,script.Path,ext,isMathWorks);
                    else
                        inputFiles(i)=coder.File(script.Path,ext,isMathWorks);
                    end
                end
                inputFilesMap=containers.Map({scripts.ScriptID},num2cell(inputFiles));
            else
                inputFiles=coder.File.empty();
                inputFilesMap=containers.Map;
            end
        end



        function fcns=getFunctions(obj,inputFilesMap)
            if isfield(obj.InferenceReportData,'Functions')&&~isempty(obj.InferenceReportData.Functions)
                fcns=obj.InferenceReportData.Functions;
                if iscell(fcns)
                    fcns=[fcns{:}];
                end
                fcns=fcns(arrayfun(@(fcn)includeFcn(fcn),fcns));
            else
                fcns=[];
            end

            function result=includeFcn(fcn)
                result=obj.includeThisItem(fcn,inputFilesMap);
            end
        end



        function vars=getVariables(obj,inputFilesMap)
            vars=[];
            if isfield(obj.InferenceReportData,'Variables')&&~isempty(obj.InferenceReportData.Variables)
                vars=obj.InferenceReportData.Variables;

                fcns=obj.InferenceReportData.Functions;
                if iscell(fcns)
                    fcns=[fcns{:}];
                end

                if numel(fcns)==numel(vars)
                    vars=vars(arrayfun(@(fcn)includeVar(fcn),fcns));
                end
            end

            function result=includeVar(fcn)

                result=obj.includeThisItem(fcn,inputFilesMap);
            end
        end



        function callSites=getCallSites(obj,inputFilesMap)
            callSites=[];
            if isfield(obj.InferenceReportData,'CallSites')&&~isempty(obj.InferenceReportData.CallSites)
                callSites=obj.InferenceReportData.CallSites;

                fcns=obj.InferenceReportData.Functions;
                if iscell(fcns)
                    fcns=[fcns{:}];
                end

                if numel(fcns)==numel(callSites)
                    callSites=callSites(arrayfun(@(fcn)includeCallSite(fcn),fcns));
                end
            end

            function result=includeCallSite(fcn)

                result=obj.includeThisItem(fcn,inputFilesMap);
            end
        end



        function result=includeThisItem(obj,fcn,inputFilesMap)
            result=true;
            if fcn.ScriptID>0&&isKey(inputFilesMap,fcn.ScriptID)...
                &&(fcn.TextStart>=0||ismember(fcn.FunctionID,obj.InferenceReportData.RootFunctionIDs))
                inFile=inputFilesMap(fcn.ScriptID);
                if isa(inFile,'coder.CodeFile')&&fcn.FunctionType==coder.report.FunctionType.Constructor
                    startIndex=fcn.TextStart+1;
                    endIndex=fcn.TextStart+fcn.TextLength;
                    if strcmp(inFile.Text(startIndex:endIndex),fcn.ClassName)

                        result=false;
                    end
                end
            else

                result=false;
            end
        end



        function varObjs=getVariableObj(obj,var,typeConverter)
            varObjs=coder.Variable.empty();

            while iscell(var)
                var=[var{:}];
            end
            if isstruct(var)
                numOfVars=numel(var);
                varObjs=repmat(coder.Variable,numOfVars,1);
                for i=1:numOfVars
                    name=var(i).Name;
                    scope=obj.getVariableScope(var(i).VariableType);
                    mxInfoID=var(i).MxInfoID;
                    try
                        type=typeConverter.createCoderTypeObj(mxInfoID);
                    catch

                        type=[];
                    end
                    varObjs(i)=coder.Variable(name,scope,type);
                end
            end
        end



        function varScope=getVariableScope(~,inVarType)
            import coder.report.VariableType;
            switch inVarType
            case VariableType.Local
                varScope=char(VariableType.Local);
            case VariableType.Global
                varScope=char(VariableType.Global);
            case VariableType.Persistent
                varScope=char(VariableType.Persistent);
            case VariableType.Input
                varScope=char(VariableType.Input);
            case VariableType.Output
                varScope=char(VariableType.Output);
            case VariableType.InputOutput
                varScope=char(VariableType.InputOutput);
            otherwise
                varScope='Unknown';
                assert(false,'Unknown variable scope');
            end
        end



        function generateCallTree(obj,fcnIdToFcnObj,inputFilesMap)
            if isfield(obj.InferenceReportData,'CallSites')&&~isempty(obj.InferenceReportData.CallSites)
                callSites=obj.getCallSites(inputFilesMap);
                for k=keys(fcnIdToFcnObj)
                    fcnID=k{1};
                    callSite=callSites([callSites.Caller]==fcnID);

                    calleeIDs=unique([callSite.CallSites.Callee],'stable');
                    numOfCallees=numel(calleeIDs);
                    callees=coder.Function.empty();
                    calleesCnt=1;
                    for i=1:numOfCallees

                        if isKey(fcnIdToFcnObj,calleeIDs(i))
                            callee=fcnIdToFcnObj(calleeIDs(i));
                            callees(calleesCnt)=callee;
                            calleesCnt=calleesCnt+1;
                        end
                    end
                    fcn=fcnIdToFcnObj(fcnID);
                    fcn.setCallees(callees);
                end
            end
        end



        function msgs=getMessages(obj)
            if isfield(obj.InferenceReportData,'CoderMessages')
                coderMessages=obj.InferenceReportData.CoderMessages;
            else
                coderMessages=[];
            end
            if isfield(obj.InferenceReportData,'InferenceMessages')
                inferenceMessages=obj.InferenceReportData.InferenceMessages;
            else
                inferenceMessages=[];
            end
            if isfield(obj.InferenceReportData,'UnownedMessages')
                unownedMessages=obj.InferenceReportData.UnownedMessages;
            else
                unownedMessages=[];
            end
            msgs=cat(2,coderMessages,inferenceMessages,unownedMessages);
            if iscell(msgs)
                msgs=cat(1,msgs{:});
            end
        end



        function msgs=getCodeInsights(obj)
            totalContributors=numel(obj.RIContributors);
            msgs=cell(1,totalContributors);
            for i=1:totalContributors
                data=obj.RIContributors{i}.Data;
                if~isempty(data)
                    msgs{i}=data;
                end
            end
            msgs=vertcat(msgs{:});
        end



        function out=getBuildLogs(obj)
            buildResults=coder.report.contrib.SupplementalContentContributor.processBuildResults(obj.ReportContext);
            if~isempty(buildResults)
                if isscalar(buildResults)
                    out=coder.BuildLog(extractLog(buildResults.logs),'Target');
                else
                    out(1)=coder.BuildLog(extractLog(buildResults(1).logs),'Target');
                    out(2)=coder.BuildLog(extractLog(buildResults(2).logs),'Example');
                end
            else
                out=coder.BuildLog.empty();
            end
            function result=extractLog(logs)
                result='';
                for i=1:numel(logs)
                    result=[result,logs(i).Text,newline];%#ok<AGROW>
                end
            end
        end



        function out=getSummary(obj)
            reportType=codergui.ReportServices.getReportTypeFromContext(obj.ReportContext);
            summary=codergui.evalprivate('processReportSummary',obj.ReportContext,reportType);
            out=coder.Summary(summary.passed,summary.date,summary.outputFilePath,...
            summary.procInfo,summary.versionInfo,summary.toolchainInfo,summary.buildConfiguration,summary.toolboxLicenses);
        end



        function out=getGeneratedFiles(obj,codeFileExtensions)
            generatedFilesStruct=codergui.evalprivate('findGeneratedSource',obj.ReportContext.Report);
            if~isempty(generatedFilesStruct)
                generatedFilesCell=struct2cell(generatedFilesStruct);
                generatedFiles=cat(1,generatedFilesCell{:});
                out=repmat(coder.File,numel(generatedFiles),1);
                count=0;
                for i=1:numel(generatedFiles)
                    count=count+1;
                    generatedFilePath=generatedFiles{i};
                    [~,~,ext]=fileparts(generatedFilePath);
                    if ismember(ext,codeFileExtensions)&&isfile(generatedFilePath)
                        fileText=fileread(generatedFilePath);
                        out(i)=coder.CodeFile(fileText,generatedFilePath,ext,false);
                    else
                        out(i)=coder.File(generatedFilePath,ext,false);
                    end
                end
            else
                out=coder.File.empty();
            end
        end
    end
end

