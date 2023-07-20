function varargout=configCheckReportHelper(function_name,varargin)





    [varargout{1:nargout}]=feval(function_name,varargin{1:end});









    function checkResult=readModelAdvisorCheckReport(modelName,varargin)%#ok

        if length(varargin)==1

            block_name=varargin{1};
        else

            block_name=rtwprivate('getSourceSubsystemName',modelName);
            if~isempty(block_name)
                modelName=bdroot(block_name);
            end
        end

        checkResult.result='Not run';
        checkResult.generateTime=0;
        checkResult.MA_SanityCheckReportFileName='';


        cs=getActiveConfigSet(modelName);
        op=cs.get_param('ObjectivePriorities');
        cm=DAStudio.CustomizationManager;
        if isfield(cm.get,'ObjectiveCustomizer')
            objManager=cm.ObjectiveCustomizer;
            if objManager.initialized==true
                for i=1:length(op)
                    op{i}=objManager.IDToNameHash.get(op{i});
                end
            end
        end
        bCheckMdlBeforeBuild=~strcmpi(get_param(cs,'CheckMdlBeforeBuild'),'off');

        if~bCheckMdlBeforeBuild

            checkResult.op=op;
            return;
        end



        if isempty(block_name)
            mdladv=Simulink.ModelAdvisor.getModelAdvisor(modelName);
        else

            mdladv=Simulink.ModelAdvisor.getModelAdvisor(block_name);
        end

        if~isa(mdladv,'Simulink.ModelAdvisor')
            checkResult.op=op;
            return;
        else
            cgObj=mdladv.getTaskObj('com.mathworks.cgo.group');
        end

        if~isa(cgObj,'ModelAdvisor.Group')
            MA_SanityCheckReportFileName='';
            reportStruct=[];
        else
            MA_SanityCheckReportFileName=modeladvisorprivate('modeladvisorutil2','GetReportNameForTaskNode',cgObj);
            reportStruct=modeladvisorprivate('modeladvisorutil2','getNodeSummaryInfo',cgObj);

        end


        failCt=0;
        warnCt=0;
        passCt=0;
        generateTime=0;
        if~isempty(MA_SanityCheckReportFileName)&&exist(MA_SanityCheckReportFileName,'file')&&~isempty(reportStruct)
            if isfield(reportStruct,'failCt')
                failCt=reportStruct.failCt;
            end
            if isfield(reportStruct,'warnCt')
                warnCt=reportStruct.warnCt;
            end
            if isfield(reportStruct,'passCt')
                passCt=reportStruct.passCt;
            end
            if isfield(reportStruct,'generateTime')
                generateTime=reportStruct.generateTime;
            end
        end
        if(failCt==0&&warnCt==0&&passCt==0)
            checkResult.result='Not run';
            MA_SanityCheckReportFileName='';
        elseif(failCt==0&&warnCt==0)
            checkResult.result='All passed';
        else
            checkResult.result='';
            checkResult.result=sprintf('Passed (%d),',passCt);
            if(warnCt>1)
                checkResult.result=sprintf('%s Warnings (%d),',checkResult.result,warnCt);
            else
                checkResult.result=sprintf('%s Warning (%d),',checkResult.result,warnCt);
            end
            if(failCt>1)
                checkResult.result=sprintf('%s Errors (%d)',checkResult.result,failCt);
            else
                checkResult.result=sprintf('%s Error (%d)',checkResult.result,failCt);
            end
        end
        checkResult.op=op;
        checkResult.generateTime=generateTime;
        checkResult.MA_SanityCheckReportFileName=MA_SanityCheckReportFileName;




        function[resultText,resultColor]=xlateCheckResult(result)%#ok
            switch result
            case 'Passed'
                resultText='Passed';
                resultColor='green';
            case 'Failed'
                resultText='issues identified';
                resultColor='red';
            case 'NotRun'
                resultText='Not run';
                resultColor='orange';
            case{'Warning','NotPassed'}
                resultText='issues identified';
                resultColor='orange';
            case 'Unspecified'
                resultText='Unspecified';
                resultColor='orange';
            otherwise
                assert(false);
            end





            function str=formatGenerateTimeString(generateTime)%#ok
                if generateTime~=0
                    str=datestr(generateTime,'ddd mmm dd HH:MM:SS yyyy');
                else
                    str='';
                end



