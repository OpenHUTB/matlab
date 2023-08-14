classdef(CaseInsensitiveProperties=true)FormatTemplate<handle
    properties(Hidden)
    end

    properties(SetAccess=public)
        SubResultStatus;
        SubResultStatusText='';
        CheckText='';
        SubTitle='';
        FormatType;
        RefLink='';
        Information='';
        ListObj='';
        TableInfo='';
        RecAction='';
        TableTitle='';
        ColTitles='';
        UserData='';
        SubBar=true;
    end

    properties(Access=private)
        LocalStyles='';
    end

    methods(Static)
        function success=isHTML(strText)

            success=~isempty(regexp(strText,'<[^>]*>','once'))||~isempty(regexp(strText,'&#.[0-9];','once'));
        end
    end

    methods


        function FormatTemplateObj=FormatTemplate(FormatType)



            if(nargin==1)
                FormatTemplateObj.FormatType=FormatType;
                FormatTemplateObj.SubResultStatus='None';
            else
                DAStudio.error('Simulink:tools:FormatTemplateConstructorError');
            end
        end

        function set.SubResultStatus(formatTemplateObj,SubResultStatus)








            if(iscell(SubResultStatus))
                if length(SubResultStatus)>1
                    DAStudio.error('Simulink:tools:setSubResultStatusInputLength');
                else
                    SubResultStatus=SubResultStatus{1};
                end
            end
            [~,CheckStatusTypes]=enumeration('ModelAdvisor.ModelAdvisorCheckStatus');
            [ismemberflag,idx]=ismember(lower(SubResultStatus),lower(CheckStatusTypes));
            if ismemberflag
                formatTemplateObj.SubResultStatus=CheckStatusTypes{idx};
            else
                cell2table(CheckStatusTypes)
                DAStudio.error('ModelAdvisor:engine:MAInvalidInputParamType');
            end


        end

        function set.FormatType(formatTemplateObj,value)
            if(iscell(value))
                value=value{1};
            end
            [~,CheckStatusTypes]=enumeration('ModelAdvisor.ModelAdvisorFormatTemplateChoices');
            [ismemberflag,idx]=ismember(lower(value),lower(CheckStatusTypes));
            if ismemberflag
                formatTemplateObj.FormatType=CheckStatusTypes{idx};
            else
                cell2table(CheckStatusTypes)
                DAStudio.error('ModelAdvisor:engine:MAInvalidInputFormatType');
            end
        end

        function set.CheckText(formatTemplateObj,CheckText)




            if isempty(CheckText)
                return;
            end
            CheckText=convertStringsToChars(CheckText);
            if(iscell(CheckText))
                formatTemplateObj.CheckText=ModelAdvisor.Text('');
                for i=1:length(CheckText)
                    if ischar(CheckText{i})||isstring(CheckText{i})
                        formatTemplateObj.CheckText(i)=ModelAdvisor.Text(CheckText{i},{},'-html',formatTemplateObj.isHTML(CheckText{i}));
                    elseif isa(CheckText{i},'Advisor.Element')
                        formatTemplateObj.CheckText(i)=CheckText{i};
                    else
                        DAStudio.error('Simulink:tools:setCheckTextInputLength');
                    end
                end
            else
                if ischar(CheckText)
                    formatTemplateObj.CheckText=ModelAdvisor.Text(CheckText,{},'-html',formatTemplateObj.isHTML(CheckText));
                elseif isa(CheckText,'Advisor.Element')
                    formatTemplateObj.CheckText=CheckText;
                else
                    DAStudio.error('Simulink:tools:setCheckTextInputLength');
                end
            end

        end

        function set.ColTitles(formatTemplateObj,ColTitles)
            if strcmp(formatTemplateObj.FormatType,'ListTemplate')%#ok<MCSUP>
                DAStudio.error('Simulink:tools:ColTitlesListTemplate');
            elseif isempty(ColTitles)
                return;
            end

            ColTitles=convertStringsToChars(ColTitles);
            if(iscell(ColTitles))
                formatTemplateObj.ColTitles=ModelAdvisor.Text('');
                for i=1:length(ColTitles)
                    if ischar(ColTitles{i})||isstring(ColTitles{i})
                        formatTemplateObj.ColTitles(i)=ModelAdvisor.Text(ColTitles{i},{'bold'},'-html',formatTemplateObj.isHTML(ColTitles{i}));
                    elseif isa(ColTitles{i},'Advisor.Element')
                        formatTemplateObj.ColTitles(i)=ColTitles{i};
                    else
                        DAStudio.error('Simulink:tools:setColTitlesInputString');
                    end
                end
            else
                if ischar(ColTitles)
                    formatTemplateObj.ColTitles=ModelAdvisor.Text(ColTitles,{'bold'},'-html',formatTemplateObj.isHTML(ColTitles));
                elseif isa(ColTitles,'Advisor.Element')
                    formatTemplateObj.ColTitles=ColTitles;
                else
                    DAStudio.error('Simulink:tools:setColTitlesInputString');
                end
            end
        end

        function set.Information(formatTemplateObj,Information)
            if isempty(Information)
                return;
            end
            Information=convertStringsToChars(Information);
            if(iscell(Information))
                formatTemplateObj.Information=ModelAdvisor.Text('');
                for i=1:length(Information)
                    if ischar(Information{i})||isstring(Information{i})
                        formatTemplateObj.Information(i)=ModelAdvisor.Text(Information{i},{},'-html',formatTemplateObj.isHTML(Information{i}));
                    elseif isa(Information{i},'Advisor.Element')
                        formatTemplateObj.Information(i)=Information{i};
                    else
                        DAStudio.error('Simulink:tools:setInformationInputString');
                    end
                end
            else
                if ischar(Information)
                    formatTemplateObj.Information=ModelAdvisor.Text(Information,{},'-html',formatTemplateObj.isHTML(Information));
                elseif isa(Information,'Advisor.Element')
                    formatTemplateObj.Information=Information;
                else
                    DAStudio.error('Simulink:tools:setInformationInputString');
                end
            end
        end

        function set.ListObj(formatTemplateObj,ListObj)



            if strcmp(formatTemplateObj.FormatType,'TableTemplate')
                DAStudio.error('Simulink:tools:ListObjTableTemplate');
            end
            if(isempty(ListObj))
                formatTemplateObj.ListObj={};
            end
            if(iscell(ListObj))
                for inx=1:length(ListObj)
                    formatTemplateObj.ListObj{inx}=ListObj{inx};
                end
            else
                for inx=1:length(ListObj)
                    formatTemplateObj.ListObj{inx}=ListObj(inx);
                end
            end
        end

        function set.RecAction(formatTemplateObj,RecAction)



            RecAction=convertStringsToChars(RecAction);
            if(iscell(RecAction))
                formatTemplateObj.RecAction=ModelAdvisor.Text('');
                for i=1:length(RecAction)
                    if ischar(RecAction{i})||isstring(RecAction{i})
                        formatTemplateObj.RecAction(i)=ModelAdvisor.Text(RecAction{i},{},'-html',formatTemplateObj.isHTML(RecAction{i}));
                    elseif isa(RecAction{i},'Advisor.Element')
                        formatTemplateObj.RecAction(i)=RecAction{i};
                    else
                        DAStudio.error('Simulink:tools:setRecActionInputString');
                    end
                end
            else
                if ischar(RecAction)
                    formatTemplateObj.RecAction=ModelAdvisor.Text(RecAction,{},'-html',formatTemplateObj.isHTML(RecAction));
                elseif isa(RecAction,'Advisor.Element')
                    formatTemplateObj.RecAction=RecAction;
                else
                    DAStudio.error('Simulink:tools:setRecActionInputString');
                end
            end
        end

        function set.RefLink(formatTemplateObj,RefLink)
            formatTemplateObj.RefLink='';
            if(iscell(RefLink))
                for inx=1:length(RefLink)
                    if~iscell(RefLink{inx})
                        DAStudio.error('Simulink:tools:RefLinksCells');
                    end
                    if isempty(RefLink{inx})||length(RefLink{inx})==1||length(RefLink{inx})==2||...
                        (length(RefLink{inx})==4&&strcmp(RefLink{inx}{1},'matlab'))||...
                        (length(RefLink{inx})==3&&strcmpi(RefLink{inx}{1},'guideline'))||...
                        (length(RefLink{inx})==3&&strcmpi(RefLink{inx}{1},'custom'))
                        formatTemplateObj.RefLink{inx}=RefLink{inx};
                    elseif length(RefLink{inx})==4&&~strcmp(RefLink{inx}{1},'matlab')
                        DAStudio.error('Simulink:tools:RefLinksMatlabKeyword');
                    else
                        DAStudio.error('Simulink:tools:RefLinksCellLength');
                    end
                end
            else
                formatTemplateObj.RefLink{1}={RefLink};
            end

        end

        function set.SubBar(formatTemplateObj,SubBar)


            if(iscell(SubBar))
                if length(SubBar)>1
                    DAStudio.error('Simulink:tools:setSubBarInputLength');
                else
                    formatTemplateObj.SubBar=SubBar{1};
                end
            else
                formatTemplateObj.SubBar=SubBar;
            end
        end

        function set.SubResultStatusText(formatTemplateObj,SubResultStatusText)



            if(iscell(SubResultStatusText))
                formatTemplateObj.SubResultStatusText=ModelAdvisor.Text('');
                for i=1:length(SubResultStatusText)
                    if ischar(SubResultStatusText{i})
                        formatTemplateObj.SubResultStatusText(i)=ModelAdvisor.Text(SubResultStatusText{i},{},'-html',formatTemplateObj.isHTML(SubResultStatusText{i}));
                    elseif isa(SubResultStatusText{i},'Advisor.Element')
                        formatTemplateObj.SubResultStatusText(i)=SubResultStatusText{i};
                    else
                        DAStudio.error('Simulink:tools:setSubResultStatusTextInputLength');
                    end
                end
            else
                if ischar(SubResultStatusText)
                    formatTemplateObj.SubResultStatusText=ModelAdvisor.Text(SubResultStatusText,{},'-html',formatTemplateObj.isHTML(SubResultStatusText));
                elseif isa(SubResultStatusText,'Advisor.Element')
                    formatTemplateObj.SubResultStatusText=SubResultStatusText;
                else
                    DAStudio.error('Simulink:tools:setSubResultStatusTextInputLength');
                end
            end
        end

        function set.SubTitle(formatTemplateObj,SubTitle)



            SubTitle=convertStringsToChars(SubTitle);
            if(iscell(SubTitle))
                formatTemplateObj.SubTitle=ModelAdvisor.Text('');
                for i=1:length(SubTitle)
                    if ischar(SubTitle{i})||isstring(SubTitle{i})
                        formatTemplateObj.SubTitle(i)=ModelAdvisor.Text(SubTitle{i},{'bold'},'-html',formatTemplateObj.isHTML(SubTitle{i}));
                    elseif isa(SubTitle{i},'Advisor.Element')
                        formatTemplateObj.SubTitle(i)=SubTitle{i};
                    else
                        DAStudio.error('Simulink:tools:setSubTitleInputLength');
                    end
                end
            else
                if ischar(SubTitle)
                    formatTemplateObj.SubTitle=ModelAdvisor.Text(SubTitle,{'bold'},'-html',formatTemplateObj.isHTML(SubTitle));
                elseif isa(SubTitle,'Advisor.Element')
                    formatTemplateObj.SubTitle=SubTitle;
                else
                    DAStudio.error('Simulink:tools:setSubTitleInputLength');
                end
            end
        end

        function set.TableInfo(formatTemplateObj,TableInfo)
            if strcmp(formatTemplateObj.FormatType,'ListTemplate')
                DAStudio.error('Simulink:tools:TableInfoListTemplate');
            end
            if(isempty(formatTemplateObj.ColTitles))
                DAStudio.error('Simulink:tools:setTableInfoInput1');
            end
            if(iscell(TableInfo))
                if size(TableInfo,2)==length(formatTemplateObj.ColTitles)
                    formatTemplateObj.TableInfo=TableInfo;
                else
                    DAStudio.error('Simulink:tools:setTableInfoInput2',num2str(length(formatTemplateObj.ColTitles)));
                end
            else
                DAStudio.error('Simulink:tools:setTableInfoInput3');
            end


        end

        function set.TableTitle(formatTemplateObj,TableTitle)
            if strcmp(formatTemplateObj.FormatType,'ListTemplate')%#ok<MCSUP>
                DAStudio.error('Simulink:tools:TableTitleListTemplate');
            elseif isempty(TableTitle)
                return;
            end
            TableTitle=convertStringsToChars(TableTitle);
            if(iscell(TableTitle))
                formatTemplateObj.TableTitle=ModelAdvisor.Text('');
                for i=1:length(TableTitle)
                    if ischar(TableTitle{i})||isstring(TableTitle{i})
                        formatTemplateObj.TableTitle(i)=ModelAdvisor.Text(TableTitle{i},{},'-html',formatTemplateObj.isHTML(TableTitle{i}));
                    elseif isa(TableTitle{i},'Advisor.Element')
                        formatTemplateObj.TableTitle(i)=TableTitle{i};
                    else
                        DAStudio.error('Simulink:tools:setTableTitleInputLength');
                    end
                end
            else
                if ischar(TableTitle)
                    formatTemplateObj.TableTitle=ModelAdvisor.Text(TableTitle,{},'-html',formatTemplateObj.isHTML(TableTitle));
                elseif isa(TableTitle,'Advisor.Element')
                    formatTemplateObj.TableTitle=TableTitle;
                else
                    DAStudio.error('Simulink:tools:setTableTitleInputLength');
                end
            end

        end

    end

    methods(Hidden)


        function setLocalStyles(this,css)


            this.LocalStyles=Advisor.Element('style','type','text/css',...
            'scoped','scoped');
            this.LocalStyles.addContent(css);
        end
    end

    methods(Hidden,Static=true)
        [entry]=fullPathToHTML(ft,fullPath,varargin);
    end
end