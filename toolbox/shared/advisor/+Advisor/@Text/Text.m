classdef(CaseInsensitiveProperties=true)Text<Advisor.Element

    properties(Access='public')
        Hyperlink='';
        IsBold=false;
        IsItalic=false;
        IsUnderlined=false;
        IsSuperscript=false;
        IsSubscript=false;
        RetainReturn=false;
        RetainSpaceReturn=false
        ContentsContainHTML=true;
        Color='Normal';
        SpanClass='';
        title='';
    end

    properties(Access='private')
        SID={};
        SIDOpenMode=Advisor.AdvisorClickBehaviorEnum.hilight;
    end


    methods
        function set.Color(this,value)
            this.Color=Advisor.str2enum(value,'Advisor.AdvisorTextColorChoices');
        end
    end


    methods(Access='public')


        function this=Text(varargin)

            if nargin>0
                [varargin{:}]=convertStringsToChars(varargin{:});
            end

            if nargin==0
            elseif nargin==1
                this.setContent(varargin{1});
            elseif nargin>1
                this.setContent(varargin{1});
                if iscell(varargin{2})
                    settings=varargin{2};
                    for i=1:length(settings)
                        if strcmpi(settings{i},'bold')
                            this.setBold(true);
                        elseif strcmpi(settings{i},'italic')
                            this.setItalic(true);
                        elseif strcmpi(settings{i},'underline')
                            this.setUnderlined(true);
                        elseif strcmpi(settings{i},'subscript')
                            this.setSubscript(true);
                        elseif strcmpi(settings{i},'superscript')
                            this.setSuperscript(true);
                        else
                            this.setColor(settings{i});
                        end
                    end
                    n=3;
                else
                    n=2;
                end
                if mod(nargin-n+1,2)~=0
                    DAStudio.error('Advisor:engine:invalidArgPairing',...
                    'Advisor.Text');
                end
                for k=n:2:nargin
                    switch varargin{k}
                    case '-span'

                        this.setSpan(varargin{k+1});
                    case '-html'

                        this.ContentsContainHTML=varargin{k+1};
                    otherwise
                        DAStudio.error('Advisor:engine:invalidInputArgs',varargin{k});
                    end
                end
            end
        end


        function setBold(this,bool)
            this.IsBold=bool;
        end


        function setHyperlink(this,hyperlink)
            this.Hyperlink=hyperlink;
        end


        function setItalic(this,bool)
            this.IsItalic=bool;
        end


        function setRetainSpaceReturn(this,bool)
            this.RetainSpaceReturn=bool;
        end


        function setSpan(this,spanclass)
            this.SpanClass=spanclass;
        end


        function setSubscript(this,bool)
            this.IsSubscript=bool;

            if(bool)
                this.IsSuperscript=false;
            end
        end


        function setSuperscript(this,bool)
            this.IsSuperScript=bool;

            if(bool)
                this.IsSubscript=false;
            end
        end


        function setUnderlined(this,bool)
            this.IsUnderlined=bool;
        end


        function outputString=emitHTML(this)


            outputString=this.Content;



            if isempty(outputString)
                return
            end


            if~this.ContentsContainHTML
                outputString=strrep(outputString,'&','&amp;');
                outputString=strrep(outputString,'<','&lt;');
                outputString=strrep(outputString,'>','&gt;');
            end

            if this.RetainReturn
                outputString=strrep(outputString,sprintf('\n'),['<br />',sprintf('\n')]);
            end
            if this.RetainSpaceReturn
                outputString=strrep(outputString,' ','&#160;');

                outputString=strrep(outputString,sprintf('\t'),'&#160;&#160;&#160;&#160;');
                outputString=strrep(outputString,sprintf('\n'),['<br />',sprintf('\n')]);
            end


            if~strcmp(this.Color,'Normal')
                temp=Advisor.Element;
                temp.setContent(outputString);
                temp.setTag('font');
                switch(this.Color)
                case 'Pass'
                    colorName='Green';
                case 'Warn'
                    colorName='Orange';
                case 'Fail'
                    colorName='Red';
                case 'Keyword'
                    colorName='blue';
                end
                temp.setAttribute('color',colorName);
                outputString=temp.emitHTML;
            end

            if~isempty(this.Hyperlink)
                temp=Advisor.Element;
                temp.setContent(outputString);
                temp.setTag('a');
                temp.setAttribute('href',this.Hyperlink);
                if~isempty(this.title)
                    titleString=this.title;
                    titleString=strrep(titleString,'&','&amp;');
                    titleString=strrep(titleString,'<','&lt;');
                    titleString=strrep(titleString,'>','&gt;');
                    temp.setAttribute('title',titleString);
                end
                outputString=temp.emitHTML;
            elseif~isempty(this.SID)
                temp=Advisor.Element;
                temp.setContent(outputString);
                temp.setTag('a');




                sids=jsonencode(this.SID);
                sids=strrep(sids,'"','&quot');
                if this.SIDOpenMode==Advisor.AdvisorClickBehaviorEnum.hilight
                    hyperlink=['matlab: modeladvisorprivate hiliteSystem USE_MULTIPLE_SID:',sids];
                else
                    hyperlink=['matlab: modeladvisorprivate Advisor.Utils.open_system USE_MULTIPLE_SID:',sids];
                end
                temp.setAttribute('href',hyperlink);
                outputString=temp.emitHTML;
            end

            if this.IsUnderlined
                temp=Advisor.Element;
                temp.setContent(outputString);
                temp.setTag('u');
                outputString=temp.emitHTML;
            end

            if this.IsItalic
                temp=Advisor.Element;
                temp.setContent(outputString);
                temp.setTag('i');
                outputString=temp.emitHTML;
            end

            if this.IsBold
                temp=Advisor.Element;
                temp.setContent(outputString);
                temp.setTag('b');
                outputString=temp.emitHTML;
            end

            if this.IsSubscript
                temp=Advisor.Element;
                temp.setContent(outputString);
                temp.setTag('sub');
                outputString=temp.emitHTML;
            end

            if this.IsSuperscript
                temp=Advisor.Element;
                temp.setContent(outputString);
                temp.setTag('sup');
                outputString=temp.emitHTML;
            end

            if~isempty(this.SpanClass)

                if outputString(end)==sprintf('\n')
                    outputString=sprintf('<span class="%s">%s</span>\n',...
                    this.SpanClass,outputString(1:end-1));
                else
                    outputString=sprintf('<span class="%s">%s</span>\n',...
                    this.SpanClass,outputString);
                end
            end
        end


        function setColor(this,color)
            this.Color=color;
        end

    end


    methods(Hidden=true)

        function setSID(this,SID,varargin)
            if ischar(SID)
                SID={SID};
            end
            if~iscell(SID)
                DAStudio.error('Advisor:engine:InputMustBeChar');
            end
            this.SID=SID;
            if nargin>2
                this.SIDOpenMode=varargin{1};
            end
        end
    end
end
