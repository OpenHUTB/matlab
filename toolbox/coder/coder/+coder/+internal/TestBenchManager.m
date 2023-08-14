



classdef TestBenchManager<handle
    properties(Access=public)

        EntryPointData;

        ExecutionConfig;
    end
    properties(Access=private)

        TestRunMode;

        ErrorMsgStruct;
    end

    methods(Access=private)



        function this=TestBenchManager()
            this.EntryPointData=containers.Map();
        end

    end

    methods(Static)


        function obj=getInstance()
            persistent uniqueInstance
            if isempty(uniqueInstance)
                obj=coder.internal.TestBenchManager();
                uniqueInstance=obj;
            else
                obj=uniqueInstance;
            end
        end





        function captureFunctionTypes(tbd,callerVarargin)
            function t=getType(arg)
                try
                    t=coder.typeof(arg);
                catch me
                    t=coderprivate.makeCause(me);
                end
            end
            types=tbd.EntryPointTypes;
            nin=numel(callerVarargin);

            if~tbd.EntryPointCalled&&nin>0
                types=[types,cellfun(@getType,callerVarargin(1:nin),'UniformOutput',false)];
                tbd.EntryPointTypes=types;
                tbd.EntryPointCalled=true;
            end

            ntypes=numel(types);



            if nin~=ntypes
                ME=MException('Coder:common:TestBenchvariadically','');
                tbd.EntryPointTypes{max(nin,ntypes)}=coderprivate.makeCause(ME);
                return;
            end

            for i=1:ntypes
                try
                    type=types{i};
                    if~type.contains(callerVarargin{i})
                        tbd.EntryPointTypes{i}=type.union(callerVarargin{i});
                    end
                catch ME
                    if isa(type,'coder.Type')||isa(type,'coder.type.Base')
                        tbd.EntryPointTypes{i}=coderprivate.makeCause(ME);
                    end
                end
            end
        end
    end

    methods(Access=public)


        function reset(this,aTestRunMode)
            function remove(file)
                if~isempty(file)
                    clear(file);
                    delete(file);
                    dirty=true;
                end
            end
            this.ErrorMsgStruct=[];
            if nargin>1
                this.TestRunMode=aTestRunMode;
            else
                this.TestRunMode='';
            end
            dirty=false;
            keys=this.EntryPointData.keys();
            data=this.EntryPointData.values();
            for i=1:numel(data)
                tbd=data{i};
                remove(tbd.getInterceptorFile());
                remove(tbd.getIntercepteeFile());
                this.EntryPointData.remove(keys{i});
            end
            if dirty
                rehash;
            end
        end



        function setErrorMsgStruct(this,aMsgStruct)
            this.ErrorMsgStruct=aMsgStruct;
        end



        function msgstruct=getErrorMsgStruct(this)
            msgstruct=this.ErrorMsgStruct;
        end



        function env=getExecutionConfig(this)
            env=this.ExecutionConfig;
        end



        function is=istesting(this,aTestRunMode)
            if nargin==1||isempty(aTestRunMode)
                is=strcmpi(this.TestRunMode,'compiled');
            elseif strcmpi(aTestRunMode,'any')
                is=any(strcmpi(this.TestRunMode,{'compiled','original'}));
            else
                is=strcmpi(this.TestRunMode,aTestRunMode);
            end
        end



        function setEntryPointCalled(this,name)
            tbd=this.EntryPointData(name);
            tbd.EntryPointCalled=true;
        end




        function msgText=sanitizeMessage(this,entryPointFile,msgText)
            [~,entryPointName,~]=fileparts(entryPointFile);
            if~this.EntryPointData.isKey(entryPointName)
                return;
            end
            tbd=this.EntryPointData(entryPointName);
            intercepteeFile=tbd.getIntercepteeFile();
            [~,intercepteeName,~]=fileparts(intercepteeFile);


            msgText=strrep(msgText,intercepteeFile,entryPointFile);

            msgText=strrep(msgText,intercepteeName,entryPointName);
        end



        function interceptForInference(this,entryPointFile)
            [path,name,extWithDot]=fileparts(entryPointFile);
            if isempty(path)
                path=pwd;
            end


            if this.EntryPointData.isKey(name)
                error(message('Coder:FE:TestBenchEPDuplicate',name));
            end




            shadow=fullfile(path,[name,'.',mexext()]);
            if isfile(shadow)
                error(message('Coder:FE:TestBenchEPShadow',name,shadow));
            end


            intercepteeFileSrc=fullfile(path,[name,extWithDot]);
            intercepteeFilePath=tempname(path);
            [~,intercepteeFcnName]=fileparts(intercepteeFilePath);
            intercepteeFileDst=fullfile(path,[intercepteeFcnName,extWithDot]);
            copyfile(intercepteeFileSrc,intercepteeFileDst);


            interceptorMexFileSrc=which('coder.internal.testBenchGetTypes');
            interceptorMexFileDst=fullfile(path,[name,'.',mexext()]);
            copyfile(interceptorMexFileSrc,interceptorMexFileDst);


            tbd=coder.internal.TestBenchData(intercepteeFileSrc);
            tbd.setInterceptorFile(interceptorMexFileDst);
            tbd.setIntercepteeFile(intercepteeFileDst);
            this.EntryPointData(name)=tbd;
        end











        function interceptForExecution(this,entryPointFile,mexFcnFile,...
            tbExecCfg)
            [entryPointPath,entryPointName,extWithDot]=fileparts(entryPointFile);
            if isempty(entryPointPath)
                entryPointPath=pwd;
            end
            intercepteeFileSrc=fullfile(entryPointPath,[entryPointName,extWithDot]);
            [mexFcnPath,mexFcnName,~]=fileparts(mexFcnFile);
            if isempty(mexFcnPath)
                mexFcnPath=pwd;
            end



            if ispc
                compare=@strcmpi;
            else
                compare=@strcmp;
            end
            if tbExecCfg.isMexInEntryPointPath()&&~compare(entryPointPath,mexFcnPath)
                error(message('Coder:FE:TestBenchMexFcnEpPathsDiffer',...
                mexFcnFile,entryPointFile));
            end


            if strcmp(entryPointName,mexFcnName)
                error(message('Coder:FE:TestBenchMexFcnEpNamesSame',...
                entryPointName,mexFcnName));
            end


            if~tbExecCfg.isEntryPointCompiled()
                return;
            end




            [bMultipleEntryPoints,epProperties]=...
            this.getEntryPointSignature(entryPointName,mexFcnFile,tbExecCfg);
            tbExecCfg.setHasMultipleEntryPoints(bMultipleEntryPoints);




            shadow=fullfile(entryPointPath,[entryPointName,'.',mexext()]);
            if isfile(shadow)
                error(message('Coder:FE:TestBenchEPShadow',entryPointName,shadow));
            end


            this.ExecutionConfig=this.createExecutionConfig(mexFcnName,tbExecCfg);
            interceptorMexFileSrc=which('coder.internal.testBenchRedirect');
            interceptorMexFileDst=fullfile(entryPointPath,[entryPointName,'.',mexext()]);
            copyfile(interceptorMexFileSrc,interceptorMexFileDst,'f');


            tbd=coder.internal.TestBenchData(intercepteeFileSrc);
            tbd.setInterceptorFile(interceptorMexFileDst);
            tbd.ConstantInputs=logical(epProperties.ConstantInputs);
            tbd.NumberOfOutputs=int32(epProperties.NumberOfOutputs);
            tbd.ActualEntryPointToCall=epProperties.ActualEntryPointToCall;

            logFcn=char(tbExecCfg.getLogFcnName(entryPointName));
            if~isempty(logFcn)
                tbd.LogFcnName=logFcn;
                [tbd.InputLogIndices,tbd.OutputLogIndices]=tbExecCfg.getInputOutputLogIndices(entryPointName);
                tbd.OutputParamCount=int32(tbExecCfg.getOutputParamCount(entryPointName));
            end

            this.EntryPointData(entryPointName)=tbd;
        end



        function tbd=getEntryPointData(this,name)
            tbd=this.EntryPointData(name);
        end



        function file=getEntryPointFile(this,name)
            tbd=this.EntryPointData(name);
            file=tbd.getEntryPointFile();
        end



        function types=retrieveFunctionTypes(this,name)
            tbd=this.EntryPointData(name);
            types=tbd.getTypes();
        end



        function allhits=retrieveAllFunctionHits(this)
            allhits=containers.Map();
            keys=this.EntryPointData.keys();
            data=this.EntryPointData.values();
            for i=1:numel(data)
                tbd=data{i};
                allhits(keys{i})=tbd.getCalled();
            end
        end


        function alltypes=retrieveAllFunctionTypes(this)
            alltypes=containers.Map();
            keys=this.EntryPointData.keys();
            data=this.EntryPointData.values();
            for i=1:numel(data)
                tbd=data{i};
                alltypes(keys{i})=tbd.getTypes();
            end
        end


        function idpNames=getInputNames(this,entryPointName)
            function name=varargname()
                varargidx=varargidx+1;
                name=sprintf('varargin{%d}',varargidx);
            end
            function saveName(name)
                idx=idx+1;
                idpNames{idx}=name;
            end

            entryPointFile=this.getEntryPointFile(entryPointName);
            types=this.retrieveFunctionTypes(entryPointName);
            nInputs=numel(types);
            idpNames=cell(nInputs,1);
            T=mtree(entryPointFile,'-file');
            entryPointFcn=T.root;
            assert(strcmp(entryPointFcn.kind,'FUNCTION'));
            inputVar=entryPointFcn.Ins;
            idx=0;
            varargidx=0;
            while~inputVar.isnull()&&idx<nInputs
                if inputVar.iskind('ID')
                    varName=inputVar.string();
                else
                    assert(inputVar.iskind('NOT'));
                    varName='~';
                end
                if strcmp(varName,'varargin')
                    varName=varargname();
                end
                saveName(varName);
                inputVar=inputVar.Next;
            end
            while idx<nInputs
                saveName(varargname());
            end
        end
    end

    methods(Static,Access=private)









        function[bMultipleEntryPoints,epProperties]=...
            getEntryPointSignature(entryPointName,mexFcnFile,tbExecCfg)
            project=coder.internal.Project;
            props=project.getMexFcnProperties(mexFcnFile);
            if isempty(props)
                error(message('Coder:FE:TestBenchMexFcnNotValid',mexFcnFile));
            end
            entryPointNames={props.EntryPoints(:).Name};


            actEPName=tbExecCfg.getActualEntryPointToCall(entryPointName);
            if isempty(actEPName)
                epName=entryPointName;
            else
                epName=actEPName;
            end
            if(isfield(props,'IsPolymorphic')&&~isempty(props.IsPolymorphic))
                epProperties=props.EntryPoints(1);
                epProperties.ActualEntryPointToCall=epName;
                bMultipleEntryPoints=false;
                return
            end
            indices=strcmp(epName,entryPointNames);
            if~any(indices)
                error(message('Coder:FE:TestBenchEpNotFoundInMexFcn',...
                mexFcnFile,entryPointName));
            end
            epProperties=props.EntryPoints(indices);
            epProperties.ActualEntryPointToCall=actEPName;
            bMultipleEntryPoints=numel(entryPointNames)>1;
        end



        function S=createExecutionConfig(mexFcnName,tbExecConfig)
            S=struct();
            S.MexFcnName=char(mexFcnName);
            S.HasMultipleEntryPoints=logical(tbExecConfig.getHasMultipleEntryPoints());
            S.SuppressOutput=logical(tbExecConfig.getSuppressOutput());
        end

    end
    methods(Static,Access=public)


        function[msgText,stack]=executeTestBench(testBenchResource,suppressOutput)
            function msgText=makeMessage(ME)
                if testBenchResource.isSynthetic()
                    msgID='Coder:FE:TestBenchAdHocEvalError';
                    x=coderprivate.msgSafeException(msgID);
                else
                    msgID='Coder:FE:TestBenchEvalError';
                    x=coderprivate.msgSafeException(msgID,testBenchFcn);
                end

                x=x.addCause(coderprivate.makeCause(ME));
                msgText=x.getReport();
            end
            msgText='';
            stack=[];
            oldpwd=pwd();
            path=testBenchResource.getTestBenchPath();
            testBenchFcn=testBenchResource.getTestBenchFunction();
            try
                if~isempty(path)
                    cd(path);
                end
                project=coder.internal.Project();

                try
                    classmeta=meta.class.fromName(testBenchFcn);
                    if isempty(classmeta)
                        nargin(testBenchFcn);
                    end
                    suite=matlab.unittest.TestSuite.fromFile(which(testBenchFcn));


                    assert(~isempty(suite));
                    project.feval(['try, tbc = run(',testBenchFcn,'); catch ME, tbc = ME; clearvars ME; end']);
                    [result,stack]=project.feval('emlcprivate(''evalTestBenchResult'',tbc);');
                    project.feval('clearvars tbc;');
                catch
                    evalCmd=testBenchFcn;


                    if nargin>1&&suppressOutput
                        evalCmd=[evalCmd,';'];
                    end

                    [result,stack]=project.feval(evalCmd);
                end
                if~isempty(result)
                    ME=coderprivate.msgSafeException(result{:});
                    msgText=makeMessage(ME);
                end
            catch ME
                msgText=makeMessage(ME);
            end
            cd(oldpwd);
        end








        function[upToDate,resolvedFunctions,outOfDateIdx]=verifyResolvedFunctions(mexFcnFile)
            project=coder.internal.Project;
            props=project.getMexFcnProperties(mexFcnFile);
            if isempty(props)
                upToDate=false;
                return;
            end
            if~isfield(props,'ResolvedFunctions')
                upToDate=false;
                return;
            end
            if~strcmp(props.Version,version)
                upToDate=false;
                return;
            end
            resolvedFunctions=props.ResolvedFunctions;
            outOfDateIdx=project.verifyResolvedFunction(resolvedFunctions);
            upToDate=isempty(outOfDateIdx);
        end
    end
end
