classdef(CaseInsensitiveProperties=true)Element<handle&matlab.mixin.Heterogeneous&matlab.mixin.Copyable

    properties(Access='public')
        Content='';
        Tag='';
        IsSingletonTag=false;
        TagAttributes=cell(0,2);
        CollapsibleMode='none';
        HiddenContent=[];
    end

    properties(Hidden=true)
        DefaultCollapsibleState='expanded';
    end


    methods(Access='private')
    end


    methods(Access='public')


        function this=Element(varargin)

            if nargin>0
                if mod(nargin-1,2)~=0
                    DAStudio.error('Advisor:engine:invalidArgPairing',...
                    'Advisor.Element');
                end


                this.Tag=varargin{1};


                if nargin>1
                    attributes=varargin(2:end);
                    for n=1:2:length(attributes)
                        if~ischar(attributes{n})||~ischar(attributes{n+1})
                            DAStudio.error('Advisor:engine:invalidInputArgs','Advisor.Element');
                        end

                        this.setAttribute(lower(attributes{n}),attributes{n+1});
                    end
                end
            end
        end


        function addContent(this,newContent)
            if iscell(newContent)
                newContent=[newContent{:}];
            end


            if ischar(this.Content)
                this.Content=Advisor.Text(this.Content);
            end

            if isa(newContent,'Advisor.Element')
                this.Content=[this.Content;newContent'];
            elseif ischar(newContent)
                newContent=Advisor.Text(newContent);
                this.Content=[this.Content;newContent];
            else
                DAStudio.error('Advisor:engine:MAUnsupportedItem');
            end
        end






        function result=isequal(element1,element2)
            result=false;
            if isa(element1,'Advisor.Element')&&isa(element2,'Advisor.Element')
                if length(element1)~=length(element2)
                    return;
                end
                for idx=1:length(element1)
                    result=strcmp(element1(idx).emitHTML,element2(idx).emitHTML);
                    if~result
                        break;
                    end
                end
            end
        end


        function outputString=emitHTML(this)
            persistent lb;
            if isempty(lb)
                lb=sprintf('\n');
            end


            tagAttributes='';
            if~isempty(this.TagAttributes)
                for i=1:size(this.TagAttributes,1)
                    tagAttributes=[tagAttributes,' ',...
                    this.TagAttributes{i,1},'="',...
                    this.TagAttributes{i,2},'"'];%#ok<AGROW>
                end
            end

            if this.IsSingletonTag
                outputString=['<',this.Tag,tagAttributes,' />',lb];
            else

                if ischar(this.Content)
                    contentString=[this.Content,lb];
                else
                    contentString='';
                    for i=1:length(this.Content)
                        contentString=[contentString,this.Content(i).emitHTML];%#ok<AGROW>
                    end
                end

                outputString=['<',this.Tag,tagAttributes,'>',lb,contentString,'</',this.Tag,'>'];
            end


            if~isempty(outputString)
                outputString=[outputString,lb];
            end
        end


        function setAttribute(this,attribute,value,varargin)
            if isempty(this.TagAttributes)
                index=[];
            else
                index=find(strcmp(attribute,this.TagAttributes(:,1)));
            end
            if isempty(index)
                this.TagAttributes{end+1,1}=attribute;
                this.TagAttributes{end,2}=value;
            else
                if nargin>3&&strcmpi(varargin{1},'append')
                    this.TagAttributes{index,2}=[this.TagAttributes{index,2},' ',value];
                else
                    this.TagAttributes{index,2}=value;
                end
            end
        end


        function setCollapsibleMode(this,mode)
            this.CollapsibleMode=mode;
        end


        function setContent(this,content)
            if ischar(content)||isa(content,'Advisor.Element')
                this.Content=content;
            else
                DAStudio.error('Advisor:engine:MAContentMustBeString');
            end
        end


        function setDefaultCollapsibleState(this,state)
            this.DefaultCollapsibleState=state;
        end


        function setTag(this,tagName)
            this.Tag=tagName;
        end

    end


    methods(Access='public',Sealed=true)

        function setHiddenContent(this,Item)
            if iscell(Item)
                Item=[Item{:}];
            end

            if isa(Item,'Advisor.Element')
                this.HiddenContent=Item';
            elseif ischar(Item)
                this.HiddenContent=Advisor.Text(Item);
            else
                DAStudio.error('Advisor:engine:MAUnsupportedItem');
            end
        end
    end


    methods
        function set.DefaultCollapsibleState(this,value)
            this.DefaultCollapsibleState=Advisor.str2enum(value,'Advisor.AdvisorDefaultCollapsibleStateEnum');
        end
        function set.CollapsibleMode(this,value)
            this.CollapsibleMode=Advisor.str2enum(value,'Advisor.AdvisorCollapsibleModeEnum');
        end
    end

end