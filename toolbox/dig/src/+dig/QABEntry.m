classdef QABEntry<matlab.mixin.SetGetExactNames
    properties
        Name{mustBeText}='';
        ActionId{mustBeText}='';
        Type{mustBeText}='QABPushButton';
        Index{mustBeInteger}=-1;
        PopupName;
        ShowText=false;
        Visible=true;
        Widget;
    end

    properties(Constant)
        Fieldnames={'Name','ActionId','Type','PopupName','ShowText','Index','Visible'};
    end

    methods
        function populateEntryFromStruct(this,s)
            for i=1:numel(this.Fieldnames)
                f=this.Fieldnames{i};
                if isfield(s,f)&&~isempty(s.(f))
                    this.(f)=s.(f);
                end
            end
        end

        function addWidget(this,parentWidget)
            widget=parentWidget.getChild(this.Name);
            if isempty(widget)
                widget=parentWidget.addChild(this.Type,this.Name);
            end

            widget.ActionId=this.ActionId;
            widget.ShowText=this.ShowText;
            widget.Index=this.Index;
            widget.Visible=this.Visible;
            if~isempty(this.PopupName)
                widget.PopupName=this.PopupName;
            end
            this.Widget=widget;
        end

        function destroyWidget(this)
            if~isempty(this.Widget)
                this.Widget.destroy();
                this.Widget=[];
            end
        end

        function toggleText(this,show)
            this.ShowText=show;
            this.Widget.ShowText=show;
        end

        function s=toStruct(this)
            s=struct;
            for i=1:numel(this.Fieldnames)
                f=this.Fieldnames{i};
                s.(f)=this.(f);
            end
        end

        function updateIndex(this,index)
            this.Index=index;
            this.Widget.Index=index;
        end
    end
end