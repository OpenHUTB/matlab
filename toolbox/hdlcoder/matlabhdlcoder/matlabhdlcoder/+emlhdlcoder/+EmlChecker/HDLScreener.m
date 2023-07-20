
classdef HDLScreener<handle
    properties(Access=public)
        errorCount=0;
        debugLevel=0;
        launchReport=false;
        errorCheckReport=true;
        fcnName='';
        codegenDir='';
        chkRepository=[];
        emlGeneralChecks=[];

        workListOfFiles={};

        RAMMappingEnabled=true;


        entryPointProcessed;


        currentFilePath;
        currentFunctionNode;
        currentFunctionName;
        rootTree;


        persistentVarList;
        persistentArrayVars;
        namedConstants;


        processingLHS=false;
        processingControlCondition=false;
        processingControlStmtBody=false;
        processingIsEmptyCall=false;
        processingPersistentVarInitialzationBlock=false;
        processingSubScriptContainer=false;


        unsupportedFixedPointFcns={
        {'disp','error'}
        {'get','error'}
        {'pow2','warning'}
        {'divide','warning'}
        {'subsasgn','warning'}
        {'subsref','warning'}};
    end

    methods(Access=public)
        function this=HDLScreener(filePath,codegenDir,openReport,debug,errorCheckReport)

            this.debugLevel=debug;

            this.codegenDir=codegenDir;
            this.launchReport=openReport;
            this.errorCheckReport=errorCheckReport;

            [~,b,c]=fileparts(filePath);

            if isempty(which(b))
                parts=split(filePath,filesep);
                b=char(parts(1));
            end
            if isempty(c)
                filePath=which(filePath);
            end

            this.chkRepository=emlhdlcoder.EmlChecker.CheckRepository;
            this.fcnName=b;

            this.addToWorkList(filePath);
        end

        function doIt(this,suppress_report)
            if(nargin<2)
                suppress_report=false;
            end
            this.emlGeneralChecks=coderprivate.emlscreener_kernel(this.fcnName);

            chks=this.chkRepository.finalizeChecks;
            hasErrors=this.chkRepository.hasErrors(chks);

            cgDir=this.codegenDir;

            openReport=this.launchReport;

            if(~suppress_report&&hdlismatlabmode())
                reporter=emlhdlcoder.EmlChecker.HDLCheckReporter(this.fcnName,chks);
                reporter.makehdlCheckReport(this.emlGeneralChecks,openReport,cgDir,this.errorCheckReport);
            end

            if(hasErrors)
                error(message('hdlcoder:matlabhdlcoder:bad_ir'));
            end
        end

        function addToWorkList(this,filePath)
            for i=1:length(this.workListOfFiles)
                fp=this.workListOfFiles{i};
                if strcmp(fp,filePath)

                    return;
                end
            end
            this.workListOfFiles{end+1}=filePath;
        end
    end
end
