classdef SolverProfilerRuleClass<handle
    properties(SetAccess=private)
Model
RuleSet
RuleFigHandle
    end

    methods


        function SPRule=SolverProfilerRuleClass(mdl)
            SPRule.Model=mdl;
            SPRule.RuleSet=SPRule.initializeRuleSet();
            SPRule.RuleFigHandle=[];
        end


        function delete(SPRule)
            if~isempty(SPRule.RuleFigHandle)&&isvalid(SPRule.RuleFigHandle)
                SPRule.RuleFigHandle.delete;
            end
        end


        function ruleSet=initializeRuleSet(SPRule)

            loc=[pwd,'/spinfo/'];
            try

                fileName=['rule_for_',SPRule.Model];
                load([loc,fileName]);
                ruleSet=customRules.ruleSet;
                clear(fileName);
            catch
                loc=[matlabroot,'/toolbox/simulink/sl_solver_profiler/+solverprofiler/data/'];
                load([loc,'defaultRules']);
                ruleSet=defaultRules;
                clear defaultRules;
            end
        end


        function openRuleWindow(SPRule)
            if~isempty(SPRule.RuleFigHandle)&&isvalid(SPRule.RuleFigHandle)
                figure(SPRule.RuleFigHandle);
            else
                SPRule.RuleFigHandle=SPRule.launchNewWindow();
            end
        end


        function ruleSet=getRuleSet(SPRule)
            ruleSet=SPRule.RuleSet;
        end


        function setRuleSet(SPRule,ruleSet)
            SPRule.RuleSet=ruleSet;
        end


        function fHandle=getRuleFigHandle(SPRule)
            fHandle=SPRule.RuleFigHandle;
        end


        function h=launchNewWindow(SPRule)

            try
                h=figure(double(intmax*rand));
            catch
                h=figure;
            end

            set(h,'MenuBar','none','ToolBar','none','NumberTitle','off',...
            'Name',['Rule Set: ',SPRule.Model],'Resize','on',...
            'HandleVisibility','off','DeleteFcn',@SPRule.closeCallback);






            screenSize=get(0,'ScreenSize');
            Dlgx=screenSize(1)+screenSize(3)/4;
            Dlgy=screenSize(2)+screenSize(4)/4;
            DlgLength=screenSize(3)/2;
            DlgHeight=screenSize(4)/2;
            h.Position=[Dlgx,Dlgy,DlgLength,DlgHeight];

            button(h,SPRule.DAGetString('restoreDefault'),...
            [0.750,0.91,0.200,0.06],@SPRule.resetRules);

            panel1=panel(h,[0.02,0.655,0.96,0.245],...
            SPRule.DAGetString('suggestionWhenHang'));

            rule=SPRule.RuleSet(1);
            checkbox(panel1,rule.enabled,[0.028,0.724,0.023,0.148],...
            {@SPRule.checkboxCallback,1},1);
            text(panel1,SPRule.DAGetString('exceptionToSteps'),...
            [0.070,0.713,0.600,0.174]);
            edit(panel1,rule.value,[0.865,0.677,0.078,0.240],...
            {@SPRule.editCallback,1},1);
            text(panel1,'%',[0.952,0.745,0.021,0.152]);

            rule=SPRule.RuleSet(2);
            checkbox(panel1,rule.enabled,[0.028,0.419,0.023,0.148],...
            {@SPRule.checkboxCallback,2},2);
            text(panel1,SPRule.DAGetString('zcToSteps'),...
            [0.070,0.412,0.700,0.179]);
            edit(panel1,rule.value,[0.865,0.365,0.078,0.240],...
            {@SPRule.editCallback,2},2);
            text(panel1,'%',[0.952,0.426,0.021,0.152]);

            rule=SPRule.RuleSet(3);
            checkbox(panel1,rule.enabled,[0.028,0.124,0.023,0.148],...
            {@SPRule.checkboxCallback,3},3);
            text(panel1,SPRule.DAGetString('resetToSteps'),...
            [0.070,0.112,0.600,0.176]);
            edit(panel1,rule.value,[0.865,0.071,0.078,0.240],...
            {@SPRule.editCallback,3},3);
            text(panel1,'%',[0.952,0.133,0.021,0.152]);

            panel2=panel(h,[0.02,0.195,0.96,0.445],...
            SPRule.DAGetString('suggestionOverEntire'));

            rule=SPRule.RuleSet(4);
            checkbox(panel2,rule.enabled,[0.028,0.812,0.023,0.143],...
            {@SPRule.checkboxCallback,4},4);
            text(panel2,SPRule.DAGetString('thereAreDAE'),[0.070,0.820,0.600,0.110]);

            rule=SPRule.RuleSet(5);
            checkbox(panel2,rule.enabled,[0.028,0.664,0.023,0.143],...
            {@SPRule.checkboxCallback,5},5);
            text(panel2,SPRule.DAGetString('thereAreCoupling'),[0.070,0.667,0.600,0.110]);

            rule=SPRule.RuleSet(6);
            checkbox(panel2,rule.enabled,[0.028,0.513,0.023,0.143],...
            {@SPRule.checkboxCallback,6},6);
            text(panel2,SPRule.DAGetString('resetToSteps'),...
            [0.070,0.521,0.600,0.110]);
            edit(panel2,rule.value,[0.866,0.509,0.082,0.131],...
            {@SPRule.editCallback,6},6);
            text(panel2,'%',[0.958,0.490,0.021,0.131]);

            rule=SPRule.RuleSet(7);
            checkbox(panel2,rule.enabled,[0.028,0.353,0.023,0.143],...
            {@SPRule.checkboxCallback,7},7);
            text(panel2,SPRule.DAGetString('exceptionOneSecond'),...
            [0.070,0.362,0.700,0.110]);
            edit(panel2,rule.value,[0.866,0.360,0.082,0.131],...
            {@SPRule.editCallback,7},7);

            rule=SPRule.RuleSet(8);
            checkbox(panel2,rule.enabled,[0.028,0.198,0.023,0.143],...
            {@SPRule.checkboxCallback,8},8);
            text(panel2,SPRule.DAGetString('zcOneSecond'),...
            [0.070,0.209,0.700,0.110]);
            edit(panel2,rule.value,[0.866,0.195,0.082,0.131],...
            {@SPRule.editCallback,8},8);

            rule=SPRule.RuleSet(9);
            checkbox(panel2,rule.enabled,[0.028,0.034,0.023,0.143],...
            {@SPRule.checkboxCallback,9},9);
            text(panel2,SPRule.DAGetString('maxStepPercent'),...
            [0.070,0.044,0.600,0.110]);
            edit(panel2,rule.value,[0.866,0.040,0.082,0.131],...
            {@SPRule.editCallback,9},9);
            text(panel2,'%',[0.958,0.020,0.021,0.131]);

            panel3=panel(h,[0.02,0.04,0.96,0.135],...
            SPRule.DAGetString('customRule'));

            rule=SPRule.RuleSet(10);
            checkbox(panel3,rule.enabled,[0.028,0.380,0.023,0.34],{@SPRule.checkboxCallback,10},10);
            edit(panel3,rule.value,[0.083,0.242,0.847,0.628],{@SPRule.editCallback,10},10);
            button(panel3,'...',[0.940,0.290,0.036,0.580],{@SPRule.browse});



            contextMenu=uicontextmenu(h);
            h.UIContextMenu=contextMenu;





            function hObj=panel(h,pos,title)
                hObj=uipanel(h,'FontSize',10,'Position',pos,'Title',title);
            end

            function hObj=checkbox(h,val,pos,callback,id)
                hObj=uicontrol(h,'Style','checkbox','Unit',...
                'Normalized','Value',val,'Position',pos,...
                'Callback',callback,'Tag',num2str(id));
            end

            function hObj=edit(h,val,pos,callback,id)
                hObj=uicontrol(h,'Style','edit','String',val,...
                'Unit','Normalized','FontSize',10,'Position',pos,...
                'Callback',callback,'Tag',num2str(id));
            end

            function hObj=text(h,str,pos)
                hObj=uicontrol(h,'Style','text','FontSize',10,...
                'String',str,'Unit','Normalized','Position',pos,...
                'HorizontalAlignment','left');
            end

            function hObj=button(h,str,pos,callback)
                hObj=uicontrol(h,'Style','pushbutton','String',str,...
                'Unit','Normalized','Position',pos,'Callback',callback);
            end
        end

        function updateWindow(SPRule)
            h=SPRule.RuleFigHandle;
            if~isvalid(h)
                return;
            end

            for i=1:length(SPRule.RuleSet)
                hObj=findobj(h,'Style','checkbox','Tag',num2str(i));
                hObj.Value=SPRule.RuleSet(i).enabled;
                hObj=findobj(h,'Style','edit','Tag',num2str(i));
                if~isempty(hObj)
                    hObj.String=SPRule.RuleSet(i).value;
                end
            end
        end

        function checkboxCallback(SPRule,src,~,id)
            SPRule.RuleSet(id).enabled=src.Value;
        end

        function hMsgBox=editCallback(SPRule,src,~,id)
            if id<=6||id==9
                try
                    value=eval(src.String);
                    if value<0||value>100
                        hMsgBox=SPRule.popMsgBox('',SPRule.DAGetString('ruleValuesOutRange'),...
                        'ruleValuesOutRange');
                        src.String=SPRule.RuleSet(id).value;
                        return;
                    end
                catch
                    hMsgBox=SPRule.popMsgBox('',SPRule.DAGetString('ruleValuesOutRange'),...
                    'ruleValuesOutRange');
                    if isvalid(src)
                        src.String=SPRule.RuleSet(id).value;
                    end
                    return;
                end

            elseif id==7||id==8

                try
                    value=eval(src.String);
                    if value<0
                        hMsgBox=SPRule.popMsgBox('',...
                        SPRule.DAGetString('ruleValuesShouldBePositive'),...
                        'ruleValueShouldBePositive');
                        src.String=SPRule.RuleSet(id).value;
                        return;
                    end
                catch
                    hMsgBox=SPRule.popMsgBox('',SPRule.DAGetString('ruleValuesShouldBePositive'),...
                    'ruleValueShouldBePositive');
                    if isvalid(src)
                        src.String=SPRule.RuleSet(id).value;
                    end
                    return;
                end

            else

                if~isvalid(src),return;end
                fullPath=src.String;
                if isempty(fullPath)
                    return;
                end


                if~strcmp(fullPath(end-1:end),'.m')
                    strWrongFileType=SPRule.DAGetString('customRuleWrongFileType');
                    hMsgBox=SPRule.popMsgBox('',strWrongFileType,'customRuleWrongFileType');
                    SPRule.RuleSet(id).value=[];
                    return;
                end


                if exist(fullPath,'file')~=2
                    strWrongFileType=SPRule.DAGetString('customRuleFileNotExist');
                    hMsgBox=SPRule.popMsgBox('',strWrongFileType,'customRuleFileNotExist');
                    SPRule.RuleSet(id).value=[];
                    return;
                end

            end
            SPRule.RuleSet(id).value=src.String;
        end

        function closeCallback(SPRule,~,~)

            if SPRule.RuleSet(10).enabled
                hObj=findobj(SPRule.RuleFigHandle,'Style','edit','Tag','10');
                if isempty(hObj.String)
                    SPRule.RuleSet(10).enabled=false;
                end
            end

            fileName=['rule_for_',SPRule.Model];
            customRules.ruleSet=SPRule.RuleSet;
            customRules.tag='SPRule';%#ok<STRNU>



            try
                if(exist('spinfo','dir')==0)
                    mkdir spinfo;
                end
                loc=[pwd,'/spinfo/'];
                save([loc,fileName],'customRules');
            catch
            end
        end

        function resetRules(SPRule,~,~)
            loc=[matlabroot,'/toolbox/simulink/sl_solver_profiler/+solverprofiler/data/'];
            load([loc,'defaultRules']);
            SPRule.RuleSet=defaultRules;
            clear defaultRules;
            SPRule.updateWindow();
        end

        function browse(SPRule,~,~)
            [filename,pathname]=uigetfile('*.m');

            if filename==0
                return;
            end

            if~strcmp(filename(end-1:end),'.m')
                strWrongFileType=SPRule.DAGetString('customRuleWrongFileType');
                SPRule.popMsgBox('',strWrongFileType,'customRuleWrongFileType');
                SPRule.browse();
                return;
            end
            fHandle=SPRule.RuleFigHandle;
            if isvalid(fHandle)
                hObj=findobj(fHandle,'Style','edit','Tag','10');
                if~isempty(hObj)
                    hObj.String=[pathname,filename];
                end
            end
            SPRule.RuleSet(10).value=[pathname,filename];
        end

    end

    methods(Static)

        function value=DAGetString(key)
            value=DAStudio.message(['Simulink:solverProfiler:',key]);
        end

        function CSH(~,~)
            helpview(fullfile(docroot,'toolbox','simulink','helptargets.map'),...
            'ruleSetWindow');
        end


        function hf=popMsgBox(identifier,message,tag)
            if~isempty(identifier)
                hf=msgbox([identifier,'. ',message],identifier);
            else
                hf=msgbox(message);
            end
            set(hf,'tag',tag);
            setappdata(hf,'DisplayMessage',message);
        end
    end

end
