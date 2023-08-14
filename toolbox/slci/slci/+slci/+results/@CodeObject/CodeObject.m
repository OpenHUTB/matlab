



classdef CodeObject<slci.results.SourceObject

    properties(SetAccess=protected,GetAccess=protected)


        fFileName='';
        fFilePath='';
        fLineNumber;





        fFunctionScope={};





        fCodeStr='';



        fSliceStatusMap;

        fSliceSubstatusMap;

        fVerificationImpl;



        fPrimVerSubstatus={};
        fVerSubstatus='';



        fPrimTraceSubstatus={};

    end

    methods(Access=public,Hidden=true)

        function obj=CodeObject(aFileName,aLineNum)
            if nargin<2
                DAStudio.error('Slci:results:InvalidInputArg');
            end
            [fPath,fName,fExt]=fileparts(aFileName);
            aKey=slci.results.CodeObject.constructKey(fPath,...
            [fName,fExt],...
            aLineNum);
            obj=obj@slci.results.SourceObject(aKey);
            obj.setCodeProperties(aFileName,aLineNum);
            obj.fVerificationImpl=slci.results.VerificationImpl;
        end
    end

    methods(Access=public,Hidden=true)

        function filePath=getFilePath(obj)
            filePath=obj.fFilePath;
        end

        function fileName=getFileName(obj)
            fileName=obj.fFileName;
        end

        function lineNumber=getLineNumber(obj)
            lineNumber=obj.fLineNumber;
        end

        function dummyLoc=isDummy(obj)
            dummyLoc=slci.results.CodeObject.isDummyLoc(obj.getFileName());
        end


        function aFunctionScope=getFunctionScope(obj)
            aFunctionScope=obj.fFunctionScope;
        end

        function verificationInfo=getVerificationInfo(obj)
            verificationInfo=obj.fVerificationImpl;
        end

        function slNames=getSliceNames(obj)
            verInfo=obj.getVerificationInfo();
            slNames=verInfo.getSliceNames();
        end

        function slStatuses=getSliceStatuses(obj)
            verInfo=obj.getVerificationInfo();
            slStatuses=verInfo.getSliceStatuses;
        end

        function slSubstatuses=getSliceSubstatuses(obj)
            verInfo=obj.getVerificationInfo();
            slSubstatuses=verInfo.getSliceSubstatuses();
        end

        function status=getStatusForSlice(obj,sliceName)
            verInfo=obj.getVerificationInfo();
            try
                status=verInfo.getStatusForSlice(sliceName);
            catch ex
                DAStudio.error('Slci:results:ErrorGetSliceForObject',...
                obj.getDispName(),sliceName);
            end
        end

        function status=getSubstatusForSlice(obj,sliceName)
            verInfo=obj.getVerificationInfo();
            try
                status=verInfo.getSubstatusForSlice(sliceName);
            catch ex
                DAStudio.error('Slci:results:ErrorGetSliceForObject',...
                obj.getDispName(),sliceName);
            end
        end

        function aSubstatus=getSubstatus(obj)
            aSubstatus=obj.fVerSubstatus;
        end

        function aCodeStr=getCodeString(obj)
            aCodeStr=obj.fCodeStr;
        end

    end

    methods(Access=public,Hidden=true)


        function addEngineVerSubstatus(obj,aStatus)
            verInfo=obj.getVerificationInfo();
            verInfo.addEngineSubstatus(aStatus);
        end

        function addPrimVerSubstatus(obj,aSubstatus)
            if~any(strcmp(obj.fPrimVerSubstatus,aSubstatus))
                obj.fPrimVerSubstatus{end+1}=aSubstatus;
            end
        end

        function substatusList=getPrimVerSubstatus(obj)
            substatusList=obj.fPrimVerSubstatus;
        end

        function addPrimTraceSubstatus(obj,aSubstatus)
            if~any(strcmp(obj.fPrimTraceSubstatus,aSubstatus))
                obj.fPrimTraceSubstatus{end+1}=aSubstatus;
            end
        end

        function substatusList=getPrimTraceSubstatus(obj)
            substatusList=obj.fPrimTraceSubstatus;
        end


        function computeStatus(obj,varargin)






            if slcifeature('SLCIJustification')==1
                modelName=obj.fFileName;
                if contains(modelName,'.')
                    temp=split(modelName,'.');
                    modelName=string(temp(1));
                end
                assert(nargin==2,'SLCI Configuration is not passed.');
                if nargin==2
                    conf=varargin{1};
                end

                fname=fullfile(conf.getReportFolder(),...
                [conf.getModelName(),'_justification.json']);

                if isfile(fname)
                    modelManager=slci.view.ModelManager(fname);

                    for i=1:modelManager.fManager.filters.Size
                        justification=slci.view.JustificationManager(...
                        modelManager.fMFModel,modelManager.fManager.filters(i));
                        codeLines=justification.getCodeLines();
                        codelines=split(codeLines,'-');

                        if contains(codelines(1),'.c')||contains(codelines(1),'.cpp')

                            if contains(codelines(1),':')&&contains(codelines(1),modelName)
                                temp=string(split(codelines(1),':'));
                                linelist=split(temp(2),',');
                                lines=[];

                                lines=obj.getAllLineNumbers(linelist,lines);
                                if isequal(temp(1),obj.fFileName)&&...
                                    any(isequal(lines(:),string(obj.fLineNumber)))

                                    aggSubstatus='JUSTIFIED';
                                    obj.setSubstatus(aggSubstatus);
                                    status=obj.fReportConfig.getStatus(aggSubstatus);
                                    obj.setStatus(status);
                                    return;
                                end
                            end
                        end
                    end
                end
            end

            aggSubstatus=obj.aggVerSubstatus();
            if~strcmpi(aggSubstatus,'OUT_OF_SCOPE')
                verInfo=obj.getVerificationInfo();
                if~verInfo.IsEmpty()
                    aggSubstatus=verInfo.getComputedEngineSubstatus();
                    status=verInfo.getComputedEngineStatus();
                    obj.setSubstatus(aggSubstatus);
                    obj.setStatus(status);
                    return;
                end
            end
            obj.setSubstatus(aggSubstatus);
            status=obj.fReportConfig.getStatus(aggSubstatus);
            obj.setStatus(status);

        end

        function computeTraceStatus(obj)
            obj.deriveTraceSubstatus;
            obj.setTraceStatus(obj.fReportConfig.getTraceabilityStatus(...
            obj.fTraceSubstatus));
        end


        function setEngineStatus(obj,aStatus)
            verInfo=obj.getVerificationInfo();
            verInfo.setEngineStatus(aStatus);
        end

        function addSubstatusForSlice(obj,aSliceObject,aStatus)
            verInfo=obj.getVerificationInfo();
            try
                verInfo.addSubstatusForSlice(aSliceObject.getKey(),aStatus);
            catch err
                if strcmp(err.identifier,'Slci:results:ErrorMultipleVerSubstatuses')
                    DAStudio.error('Slci:results:ErrorMultipleVerSubstatuses',...
                    obj.getKey(),aSliceObject.getKey());
                else
                    err.rethrow();
                end
            end
        end

        function addStatusForSlice(obj,aSliceObject,aStatus)
            verInfo=obj.getVerificationInfo();
            try
                verInfo.addStatusForSlice(aSliceObject.getKey(),aStatus);
            catch err
                if strcmp(err.identifier,'Slci:results:ErrorMultipleVerSubstatuses')
                    DAStudio.error('Slci:results:ErrorMultipleVerSubstatuses',...
                    obj.getKey(),aSliceObject.getKey());
                else
                    err.rethrow();
                end
            end
        end

        function addFunctionScope(obj,aFunctionScope)
            if~isempty(aFunctionScope)&&...
                ~any(strcmp(obj.fFunctionScope,aFunctionScope))
                obj.fFunctionScope{end+1}=aFunctionScope;
            end
        end

        function setFunctionScope(obj,aFunctionScopes)


            assert(isempty(obj.fFunctionScope));
            if iscell(aFunctionScopes)
                obj.fFunctionScope=aFunctionScopes;
            else
                DAStudio.error('Slci:results:InvalidInputArg');
            end
        end


        function setCodeString(obj,aCodeStr)
            aCodeStr=slci.internal.ReportUtil.abbreviateText(aCodeStr,80,1);
            obj.fCodeStr=aCodeStr;
        end


        function aDispName=getDispName(obj,datamgr)%#ok
            aDispName=[obj.getFileName(),':',num2str(obj.getLineNumber())];
            aDispName=slci.internal.encodeString(aDispName,'all','encode');
        end
    end

    methods(Access=protected)

        function lines=getAllLineNumbers(~,linelist,lines)
            for j=1:length(linelist)
                if contains(linelist(j),'-')
                    [first,second]=regexp(linelist(j),'-',...
                    'match','split');
                    for k=str2num(string(first)...
                        ):str2num(string(second))
                        lines=[lines,k];
                    end
                else
                    lines=[lines,linelist(j)];
                end
            end
        end

        function setCodeProperties(obj,fileName,lineNum)

            if isempty(fileName)||~ischar(fileName)||...
                isempty(lineNum)||~isnumeric(lineNum)
                DAStudio.error('Slci:results:InvalidInputArg');
            end

            [filePath,fileName,fileExt]=fileparts(fileName);
            obj.setFileName([fileName,fileExt]);
            obj.setFilePath(filePath);
            obj.setLineNumber(lineNum);
        end

        function setFilePath(obj,filePath)
            if~isempty(filePath)&&ischar(filePath)
                filePath=slci.results.normalizeFilePath(filePath);
                obj.fFilePath=filePath;
            end
        end

        function setSubstatus(obj,aSubstatus)

            if isKey(obj.fReportConfig.VStatusTable,aSubstatus)||...
                isempty(aSubstatus)
                obj.fVerSubstatus=aSubstatus;
            else
                DAStudio.error('Slci:results:InvalidSubstatus',aSubstatus);
            end
        end

        function setFileName(obj,aFileName)
            if isempty(aFileName)||~ischar(aFileName)
                DAStudio.error('Slci:results:InvalidFileName',obj.getKey());
            else
                obj.fFileName=aFileName;
            end
        end

        function setLineNumber(obj,aLineNumber)
            if~isnumeric(aLineNumber)
                DAStudio.error('Slci:results:InvalidLineNumber',obj.getKey());
            end
            obj.fLineNumber=aLineNumber;
        end

        function checkTraceObj(obj,aTraceObj)%#ok

            if~(isa(aTraceObj,'slci.results.ModelObject')||...
                isa(aTraceObj,'slci.results.FunctionInterfaceObject'))
                DAStudio.error('Slci:results:ErrorTraceObjects',...
                'CODEOBJECT',class(aTraceObj));
            end
        end

        deriveTraceSubstatus(obj);

    end

    methods(Static=true,Access=public,Hidden=true)


        function isDummy=isDummyLoc(fileNameWithExt)
            isDummy=strcmpi(fileNameWithExt,'FILE NOT FOUND');
        end

    end

    methods(Static=true,Access=public,Hidden=true)

        function key=constructKey(filePath,fileNameWithExt,lineNum)

            if isempty(fileNameWithExt)||~ischar(fileNameWithExt)||...
                isempty(lineNum)||~isnumeric(lineNum)
                DAStudio.error('Slci:results:InvalidInputArg');
            end

            if~isempty(filePath)
                filePath=[filePath,filesep,fileNameWithExt];
                filePath=slci.results.normalizeFilePath(filePath);
                key=[filePath,':',num2str(lineNum)];
            else

                if~slci.results.CodeObject.isDummyLoc(fileNameWithExt)
                    DAStudio.error('Slci:results:InvalidInputArg');
                else
                    key=[fileNameWithExt,':',num2str(lineNum)];
                end
            end
        end

    end


    methods(Access=protected)

        function substatus=aggVerSubstatus(obj)
            primSubstatusList=obj.getPrimVerSubstatus();
            if~isempty(primSubstatusList)
                severityList={'EMPTY_LINE',...
                'KEYWORD',...
                'COMMENT',...
                'INCLUDE',...
                'PREPROCESSOR',...
                'OPEN_BRACKET',...
                'CLOSE_BRACKET',...
                'SEMICOLON',...
                'OUT_OF_SCOPE',...
                'LOCAL_DECLARATION',...
'OPTIMIZED'
                };
                substatus=slci.internal.ReportUtil.getHeaviestSubstatus(...
                primSubstatusList,...
                severityList);
            else
                substatus='UNABLE_TO_PROCESS';
            end
        end

        function substatus=aggTraceSubstatus(obj)

            primSubstatusList=obj.getPrimTraceSubstatus();
            if~isempty(primSubstatusList)











                severityList={'EMPTY_LINE',...
                'COMMENT',...
                'KEYWORD',...
                'INCLUDE',...
                'PREPROCESSOR',...
                'OPEN_BRACKET',...
                'CLOSE_BRACKET',...
                'SEMICOLON',...
                'OUT_OF_SCOPE',...
                'VERIFICATION_FAILED_TO_VERIFY',...
                'VERIFICATION_PARTIALLY_PROCESSED',...
                'VERIFICATION_UNABLE_TO_PROCESS',...
                'VERIFICATION_MANUAL',...
                'VERIFICATION_WAW',...
                'VERIFICATION_UNEXPECTEDDEF',...
                'VERIFICATION_UNEXPECTED',...
                'LOCAL_DECLARATION',...
                'TRACED',...
                'OPTIMIZED',...
                'VERIFICATION_JUSTIFIED',...
                'JUSTIFIED',...
                };
                substatus=slci.internal.ReportUtil.getHeaviestSubstatus(...
                primSubstatusList,...
                severityList);
            else
                substatus='UNKNOWN';
            end
        end

    end

end
