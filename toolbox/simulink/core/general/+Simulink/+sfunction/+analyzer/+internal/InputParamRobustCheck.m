classdef InputParamRobustCheck<Simulink.sfunction.analyzer.internal.ComplianceCheck






    properties
Description
Category
    end

    methods
        function obj=InputParamRobustCheck(description,category)
            obj@Simulink.sfunction.analyzer.internal.ComplianceCheck(description,category);
        end

        function input=constructInput(obj,target)
            input.sfcnName=target.sfcnName;
            input.sfcnBlock=target.sfcnBlock;
            input.rootDir=target.rootDir;
            input.model=target.model;
            input.basereps=25;
            input.Rseed=0;
        end

        function[description,result,details]=execute(obj,input)
            description=obj.Description;
            error=0;
            try
                testReport=obj.parameterRobustCheck(input);
            catch
                error=1;
            end
            if error==1
                result=Simulink.sfunction.analyzer.internal.ComplianceCheck.FAIL;
                details={DAStudio.message('Simulink:SFunctions:ComplianceCheckInputParamRobustCheckFail',input.sfcnName)};
            else
                result=testReport.status;
                details=testReport.details;
            end
        end
    end

    methods(Access=private)


        function testReport=parameterRobustCheck(obj,input)
            testReport.status=Simulink.sfunction.analyzer.internal.ComplianceCheck.PASS;
            testReport.details='';
            reproduceMatFile=fullfile(input.rootDir,input.sfcnName,[input.sfcnName,'_param_robustness_set.mat']);
            reproduceMFile=fullfile(input.rootDir,input.sfcnName,'robustness_reproduce.m');

            if exist(reproduceMatFile,'file')==2
                data=matfile(reproduceMatFile);
                if strcmp(data.sfcnName,input.sfcnName)

                    choice=questdlg(DAStudio.message('Simulink:SFunctions:ComplianceCheckQuestionDlg',input.sfcnName),...
                    ['S-function: ',input.sfcnName],...
                    DAStudio.message('Simulink:SFunctions:ComplianceCheckYes'),...
                    DAStudio.message('Simulink:SFunctions:ComplianceCheckNo'),...
                    DAStudio.message('Simulink:SFunctions:ComplianceCheckNoAndSee'),...
                    DAStudio.message('Simulink:SFunctions:ComplianceCheckNoAndSee'));

                    switch choice
                    case DAStudio.message('Simulink:SFunctions:ComplianceCheckYes')
                        delete(data.testModelFile);
                        delete([data.testModelFile,'.autosave']);
                        delete(reproduceMatFile);
                        delete(reproduceMFile);
                    case DAStudio.message('Simulink:SFunctions:ComplianceCheckNo')
                        testReport.status=Simulink.sfunction.analyzer.internal.ComplianceCheck.WARNING;
                        testReport.details={DAStudio.message('Simulink:SFunctions:ComplianceCheckRobustCheckReportDetail',reproduceMFile)};
                        return;
                    case DAStudio.message('Simulink:SFunctions:ComplianceCheckNoAndSee')
                        edit(reproduceMFile);
                        testReport.status=Simulink.sfunction.analyzer.internal.ComplianceCheck.WARNING;
                        testReport.details={DAStudio.message('Simulink:SFunctions:ComplianceCheckRobustCheckReportDetail',reproduceMFile)};
                        return;
                    end
                end
            end
            try
                numParamsIdx=8;
                evalc(['sfSizes = ',input.sfcnName,'([],[],[],0);']);
                numParams=sfSizes(numParamsIdx);
            catch ex
                testReport.status=Simulink.sfunction.analyzer.internal.ComplianceCheck.NOTRUN;
                testReport.details={ex.message};
                return;
            end
            datestring=datestr(datetime('now'));
            datestring=regexprep(datestring,'[ :-]','_');
            testSysName=['sfcnRobustnessCheckModel_',datestring];
            testModelFile=fullfile(input.rootDir,input.sfcnName,[testSysName,'.slx']);
            new_system(testSysName);

            add_block('built-in/S-Function',[testSysName,'/sfcn1']);
            obj.createReproductionScript(reproduceMFile,reproduceMatFile);
            model=testSysName;
            sfcnBlock=[testSysName,'/sfcn1'];
            sfcnName=input.sfcnName;
            if numParams>0

                baseSet={'[]','1','0','0+1i','2+1i',...
                'inf','-inf','nan','[1.5 2 3]',...
                '[-7;2;0]','[1000 2 9;1 2 3]',...
                '[1000 2; 9 1; 2 3]','{1,2,3}',...
                '{[1:3],[4:6],[7:9]}','sparse(4,4)',};

                [~,tempstr1]=fileparts(tempname);
                bogusWkspVarName=['bogusWkspVar_',tempstr1];
                extraSet={bogusWkspVarName,'''''',''};


                for k=1:length(baseSet)
                    workSet{k}=[baseSet{k},','];%#ok<*AGROW>
                end
                for kx=(k+1):(k+length(extraSet))
                    workSet{kx}=[extraSet{kx-k},','];
                end


                datatypes={'','single','int8','uint8',...
                'int16','uint16','int32','uint32'};


                w=warning('off','all');
                warnStateRestorer=onCleanup(@()warning(w));
                for strIdx=1:length(baseSet)
                    try
                        nItems=repmat(workSet{strIdx},1,numParams);
                        nItems=nItems(1:end-1);
                        set_param(gcb,'Parameters',nItems)

                        params=nItems;
                        save(reproduceMatFile,'model','sfcnBlock','params','sfcnName','testModelFile');
                        if(strIdx==1)
                            set_param(gcb,'FunctionName',input.sfcnName);
                            save_system(testSysName,testModelFile);
                        end
                        sim(testSysName,1);
                        delete(reproduceMatFile);
                    catch ex
                        delete(reproduceMatFile);
                    end
                end
                warnStateRestorer.delete;




                sCurr=rng;
                cleanRand=onCleanup(@()rng(sCurr));
                rng('default');
                rng(input.Rseed);

                for t=1:length(datatypes)

                    if t>1
                        reps=input.basereps;

                        clear workSet;
                        for k=1:length(baseSet)
                            workSet{k}=[datatypes{t},'(',baseSet{k},'),'];
                        end
                    else
                        reps=input.basereps;
                    end

                    for k=1:reps



                        idxList=1+floor((length(workSet)-1)*rand(numParams,1));
                        paramString=[workSet{idxList}];
                        paramString=paramString(1:end-1);


                        w=warning('off','all');
                        warnStateRestorer=onCleanup(@()warning(w));

                        try
                            set_param(gcb,'Parameters',paramString);
                            params=paramString;
                            save(reproduceMatFile,'model','sfcnBlock','params','sfcnName','testModelFile');
                            obj.createReproductionScript(reproduceMFile,reproduceMatFile);
                            sim(testSysName,1);
                            delete(reproduceMatFile);
                        catch ex
                            delete(reproduceMatFile);
                        end
                        warnStateRestorer.delete;
                    end

                end
            end

            bdclose(testSysName);
        end

        function createReproductionScript(obj,reproduceMFile,reproduceMatFile)
            fid=fopen(reproduceMFile,'w');
            fwrite(fid,['% This script is used to reproduce the failure captured by S-function Robustness Checks from last run.',newline]);
            fwrite(fid,['w = warning(','''','off',''' , ''','all'');',newline]);
            fwrite(fid,['warnStateRestorer = onCleanup(@() warning(w));',newline]);
            fwrite(fid,['load(','''',reproduceMatFile,'''',');',newline]);
            fwrite(fid,['load_system(model);',newline]);
            fwrite(fid,['set_param(sfcnBlock, ''Parameters'', params);',newline]);
            fwrite(fid,'sim(model,1);');
            fclose(fid);
        end
    end

end

