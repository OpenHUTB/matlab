classdef HTMLLogger<UpgradeAdvisor.internal.Logger



    properties
        FileName='';
        Echo=false;
        StartTime=0;
        StopTime=0;
        AnalyzedModels={};
        ModelChangeIndices=[];
        TimingMessages=[];
        PassMessages=[];
        FailMessages=[];
        PlainMessages=[];
        FixedMessages=[];
        UnfixedMessages=[];
        SkippedCheckMessages=[];
        FixAvailableMessages=[];
        AllMessages=[];
    end

    methods

        function obj=HTMLLogger()
            obj.initialize;
        end

        function initialize(obj)

            obj.StartTime=now;


            obj.FileName='';
            obj.StopTime=0;
            obj.AnalyzedModels={};
            obj.ModelChangeIndices=[];
            obj.TimingMessages=[];
            obj.PassMessages=[];
            obj.FailMessages=[];
            obj.PlainMessages=[];
            obj.FixedMessages=[];
            obj.UnfixedMessages=[];
            obj.SkippedCheckMessages=[];
            obj.FixAvailableMessages=[];
            obj.AllMessages=[];
        end

        function showReport(obj)
            open(obj.FileName)
        end

        function setCurrentModel(obj,newModel)
            obj.AnalyzedModels{end+1}=newModel;
            obj.ModelChangeIndices(end+1)=numel(obj.AllMessages)+1;
        end

        function model=getModelForIndex(obj,index)

            ind=find(index>=obj.ModelChangeIndices);
            model=obj.AnalyzedModels{numel(ind)};
        end

        function close(obj)
            obj.StopTime=now;
        end

        function addTimingMessage(obj,message)
            obj.addNewMessage(message);
            obj.TimingMessages(end+1)=numel(obj.AllMessages);
        end

        function addFailMessage(obj,message)
            obj.addNewMessage(message);
            obj.FailMessages(end+1)=numel(obj.AllMessages);
        end

        function addSkippedCheckMessage(obj,message)
            obj.addNewMessage(message);
            obj.SkippedCheckMessages(end+1)=numel(obj.AllMessages);
        end

        function addPassMessage(obj,message)
            obj.addNewMessage(message);
            obj.PassMessages(end+1)=numel(obj.AllMessages);
        end

        function addFixedMessage(obj,message)
            obj.addNewMessage(message);
            obj.FixedMessages(end+1)=numel(obj.AllMessages);
        end

        function addUnfixedMessage(obj,message)
            obj.addNewMessage(message);
            obj.UnfixedMessages(end+1)=numel(obj.AllMessages);
        end

        function addFixAvailableMessage(obj,message)
            obj.addNewMessage(message);
            obj.FixAvailableMessages(end+1)=numel(obj.AllMessages);
        end

        function addMessage(obj,message)
            obj.addNewMessage(message);
            obj.PlainMessages(end+1)=numel(obj.AllMessages);
        end

        function addNewMessage(obj,message)
            if isempty(obj.AllMessages)
                obj.AllMessages={message};
            else
                obj.AllMessages=[obj.AllMessages;message];
            end
            if obj.Echo
                fprintf(' %s %s\n',datestr(now,31),message);
            end
        end

        function fid=getReportFileHandle(obj)
            slprjFolder=fullfile(...
            Simulink.fileGenControl('get','CacheFolder'),'slprj');
            if~exist(slprjFolder,'dir')



                DAStudio.error('SimulinkUpgradeAdvisor:automation:LoggerSlprjFolderMissing',slprjFolder);
            end
            fileTitle=[obj.AnalyzedModels{1},'_',strrep(datestr(now,31),' ','-')];
            fileTitle=[strrep(fileTitle,':','_'),'.html'];
            obj.FileName=fullfile(slprjFolder,fileTitle);
            fid=fopen(obj.FileName,'w','n','UTF-8');
        end

        function fullpath=getRootModelFullpath(obj)
            try
                fullpath=get_param(obj.AnalyzedModels{1},'filename');
            catch E %#ok<NASGU>
                fullpath=obj.AnalyzedModels{1};
            end
        end

        function generateReport(obj)
            fid=obj.getReportFileHandle;
            c1=onCleanup(@()fclose(fid));
            fprintf(fid,'<html>\n');
            fprintf(fid,'<head>\n<meta http-equiv="Content-Type" content="text/html;charset=utf-8">\n</head>\n');
            fprintf(fid,'<body>\n');

            fprintf(fid,'<h3>%s</h3>\n',DAStudio.message(...
            'SimulinkUpgradeAdvisor:automation:Summary'));

            fprintf(fid,'<p>%s</p>\n',DAStudio.message(...
            'SimulinkUpgradeAdvisor:automation:LoggerHeader',...
            obj.getRootModelFullpath,datestr(obj.StartTime,31)));

            fprintf(fid,'<p>%s</p>\n',DAStudio.message(...
            'SimulinkUpgradeAdvisor:automation:LoggerTail',datestr(now,31)));

            if numel(unique(obj.AnalyzedModels))==1
                fprintf(fid,'<p>%s</p>\n',DAStudio.message(...
                'SimulinkUpgradeAdvisor:automation:JustOneModelAnalyzed'));
            else
                fprintf(fid,'<p>%s</p>\n',DAStudio.message(...
                'SimulinkUpgradeAdvisor:automation:NumberModelsAnalyzed',...
                numel(unique(obj.AnalyzedModels))));
            end

            fprintf(fid,'<p>%s</p>\n',DAStudio.message(...
            'SimulinkUpgradeAdvisor:automation:NumberFixesApplied',...
            numel(obj.FixedMessages)));

            if~isempty(obj.SkippedCheckMessages)
                fprintf(fid,'<p>%s</p>\n',DAStudio.message(...
                'SimulinkUpgradeAdvisor:automation:SkippedChecks'));
                obj.printlist(fid,obj.SkippedCheckMessages);
            end



            fprintf(fid,'<h3>%s</h3>\n',DAStudio.message(...
            'SimulinkUpgradeAdvisor:automation:Problems'));
            if(numel(obj.FailMessages)==0)&&(numel(obj.UnfixedMessages)==0)
                fprintf(fid,'%s\n',DAStudio.message(...
                'SimulinkUpgradeAdvisor:automation:NoIssues'));
            else
                obj.printlistWithHyperLinks(fid,obj.FailMessages);
                if(numel(obj.UnfixedMessages)~=0)
                    fprintf(fid,'<p>%s.</p>\n',DAStudio.message(...
                    'SimulinkUpgradeAdvisor:automation:UnfixedHeader'));
                    obj.printlistWithHyperLinks(fid,obj.UnfixedMessages);
                end
            end


            fprintf(fid,'<h3>%s</h3>\n',DAStudio.message(...
            'SimulinkUpgradeAdvisor:automation:Details'));

            currentModelIndex=1;
            for jj=1:numel(obj.AllMessages)
                if currentModelIndex<=length(obj.ModelChangeIndices)&&...
                    jj==obj.ModelChangeIndices(currentModelIndex)
                    fprintf(fid,...
                    '<p> </p><b> <a href="matlab:open_system %s">%s</a> </b>\n',...
                    obj.getModelForIndex(jj),...
                    obj.getModelForIndex(jj));
                    currentModelIndex=currentModelIndex+1;
                end
                fprintf(fid,'<br>%s\n',obj.AllMessages{jj});
            end

            fprintf(fid,'</html>\n</body>\n');
            delete(c1);
        end

        function printlistWithHyperLinks(obj,fid,indicies)
            for jj=1:numel(indicies)
                thisModel=obj.getModelForIndex(indicies(jj));
                linkText=sprintf('<a href="matlab:upgradeadvisor %s">%s</a>',...
                thisModel,thisModel);

                fprintf(fid,'<li><b>%s</b>: %s</li>\n',...
                linkText,...
                obj.AllMessages{indicies(jj)});
            end
        end

        function printlist(obj,fid,indicies)
            for jj=1:numel(indicies)
                fprintf(fid,'<li><b>%s</b>: %s</li>\n',...
                obj.getModelForIndex(indicies(jj)),...
                obj.AllMessages{indicies(jj)});
            end
        end
    end

end






