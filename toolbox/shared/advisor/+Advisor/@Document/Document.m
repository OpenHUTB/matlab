classdef(CaseInsensitiveProperties=true,TruncatedProperties=true)Document<Advisor.Element





    properties(Access='public')
        Items=[];
        HeadItems=[];
        FramesetItem=[];
        BodyItem=[];
        Title=''
    end


    methods(Access='public')

        function this=Document
            this.FramesetItem=Advisor.Frameset;
            this.BodyItem=Advisor.Element;
            this.BodyItem.setTag('body');
        end


        function setTitle(h,title)
            h.Title=title;
        end



        function addFrameItem(this,newItem)
            if isa(newItem,'Advisor.Element')
                this.FramesetItem.addFrameItem(newItem);
            else
                DAStudio.error('Advisor:engine:MAUnsupportedItem');
            end
        end


        function addHeadItem(this,newItem)
            if isa(newItem,'Advisor.Element')
                this.HeadItems=[this.HeadItems;newItem];
            elseif ischar(newItem)
                newItem=Advisor.Text(newItem);
                this.HeadItems=[this.HeadItems;newItem];
            else
                DAStudio.error('Advisor:engine:MAUnsupportedItem');
            end
        end


        function setBodyAttribute(this,name,value)
            this.BodyItem.setAttribute(name,value);
        end


        function setFramesetAttribute(this,name,value)
            this.FramesetItem.setAttribute(name,value);
        end


        function addItem(this,newItem)
            if iscell(newItem)
                newItem=[newItem{:}];
            end

            if isa(newItem,'Advisor.Element')
                this.Items=[this.Items,newItem];
            elseif ischar(newItem)
                newItem=Advisor.Text(newItem);
                this.Items=[this.Items,newItem];
            else
                DAStudio.error('Advisor:engine:MAUnsupportedItem');
            end
        end


        function outputString=emitHTML(this)

            outputString='';
            for i=1:length(this.Items)
                outputString=[outputString,this.Items(i).emitHTML];%#ok<AGROW>
            end


            head='';
            for i=1:length(this.HeadItems)
                head=[head,this.HeadItems(i).emitHTML];%#ok<AGROW>
            end
            if~isempty(this.Title)
                temp=Advisor.Element;
                temp.setContent(this.Title);
                temp.setTag('title');
                head=[head,temp.emitHTML];
            end
            if~isempty(head)
                temp=Advisor.Element;
                temp.setContent(head);
                temp.setTag('head');
                head=temp.emitHTML;
            end


            frameSection='';
            if~isempty(this.FramesetItem.Frames)
                frameSection=this.FramesetItem.emitHTML;
            end


            this.BodyItem.setContent(outputString);
            outputString=this.BodyItem.emitHTML;


            temp=Advisor.Element;
            temp.setContent([head,frameSection,outputString]);
            temp.setTag('html');
            outputString=temp.emitHTML;
        end

    end
end

