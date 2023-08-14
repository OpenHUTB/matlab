


classdef Additional<simulinkcoder.internal.wizard.QuestionBase
    methods
        function obj=Additional(env)
            id='Additional';
            topic=message('RTW:wizard:Topic_Finish').getString;
            obj@simulinkcoder.internal.wizard.QuestionBase(id,topic,env);
            obj.CountInProgress=false;

            obj.Options={};
            obj.HasBack=false;
            obj.DisplayRevertButton=true;
            obj.DisplayFinishButton=true;
            obj.SinglePane=true;
            obj.Topic=message('RTW:wizard:CodeGenComplete').getString;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
        end
        function preShow(obj)
            env=obj.Env;
            env.QuestionTopics={message('RTW:wizard:CodeGenComplete').getString};
            docLinks=simulinkcoder.internal.wizard.question.Additional.getDocLinks;
            if~env.isSubsystemBuild

                rptStr=['matlab:rtw.report.open(''',env.ModelName,''')'];
                codeInterfaceCfgStr=['matlab:simulinkcoder.internal.app.start(''',env.ModelName,''')'];
                obj.QuestionMessage=[message('SimulinkCoderApp:wizard:Question_Additional',...
                '',...
                message('RTW:wizard:ViewReport',rptStr).getString,...
                ['<p><div style="font-size: 16px;font-weight:bold">',env.Gui.getLightBulbImage...
                ,message('RTW:wizard:WhatIsNext').getString,'</div>'],...
                ['matlab:',docLinks{1}],...
                ['matlab:',docLinks{2}],...
                ['matlab:',docLinks{3}],...
                ['matlab:',docLinks{4}],...
                ['matlab:',docLinks{5}]...
                ).getString];
            end
        end

    end
    methods(Static)
        function out=getDocLinks()
            out={'helpview(fullfile(docroot,''rtw'',''helptargets.map''),''rtw_quickstart_pres_var'')',...
            'helpview(fullfile(docroot,''rtw'',''helptargets.map''),''quickstart_finish_builds'')',...
            'helpview(fullfile(docroot,''simulink'',''helptargets.map''),''quickstart_finish_configset'')',...
            'helpview(fullfile(docroot,''rtw'',''helptargets.map''),''quickstart_finish_regenerate'')',...
            'helpview(fullfile(docroot,''rtw'',''helptargets.map''),''quickstart_finish_packngo'')'};
        end
    end

end



