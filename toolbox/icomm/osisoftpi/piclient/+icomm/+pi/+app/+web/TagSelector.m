classdef TagSelector<icomm.pi.app.Container






    properties(GetAccess=public,SetAccess=public,Dependent)
AllAvailableTags
    end

    properties(GetAccess=public,SetAccess=private,Dependent)
AvailableTags
SelectedTags
    end

    properties(GetAccess=public,SetAccess=private)
        NameFilterEditBox matlab.ui.control.EditField
        AvailableTagListBox matlab.ui.control.ListBox
        SelectedTagListBox matlab.ui.control.ListBox
        AddButton matlab.ui.control.Button
        RemoveButton matlab.ui.control.Button
        UpButton matlab.ui.control.Button
        DownButton matlab.ui.control.Button
    end

    properties(GetAccess=private,Constant)
        ButtonSize=30
    end

    properties(GetAccess=private,SetAccess=private)
AllAvailableTags_
        FilterValue string
    end

    events(ListenAccess=public,NotifyAccess=private)
SelectedTagsChanged
SelectedTagOrderChanged
    end

    methods

        function value=get.AllAvailableTags(this)
            value=this.AllAvailableTags_;
        end

        function set.AllAvailableTags(this,value)
            this.SelectedTagListBox.Items={};

            this.AllAvailableTags_=sort(convertCharsToStrings(table2array(value)));
            this.update();
        end

        function value=get.AvailableTags(this)
            value=convertCharsToStrings(this.AvailableTagListBox.Items);
        end

        function value=get.SelectedTags(this)
            value=convertCharsToStrings(this.SelectedTagListBox.Items);
        end

    end

    methods(Access=public)

        function this=TagSelector(varargin)
            container=uigridlayout(...
            'Parent',[],...
            'Padding',0);
            this@icomm.pi.app.Container(container,varargin{:});
        end

    end

    methods(Access=protected)

        function initialize(this)
            this.UiContainer.ColumnWidth={'1x'};
            this.UiContainer.RowHeight={21,'1x'};
            this.NameFilterEditBox=uieditfield('text',...
            'Parent',this.UiContainer,...
            'HorizontalAlignment','left',...
            'ValueChangingFcn',@this.onNameFilterChanged);
            lowerBox=uigridlayout(...
            'Parent',this.UiContainer,...
            'Padding',0,...
            'ColumnWidth',{'1x',this.ButtonSize,'1x'},...
            'RowHeight',{'1x'});

            this.AvailableTagListBox=uilistbox(...
            'Parent',lowerBox,...
            'Multiselect',true,...
            'Items',{},...
            'Value',{});
            buttonBox=uigridlayout(...
            'Parent',lowerBox,...
            'Padding',0,...
            'RowHeight',repmat({this.ButtonSize},1,4),...
            'ColumnWidth',{'1x'});
            this.SelectedTagListBox=uilistbox(...
            'Parent',lowerBox,...
            'Multiselect',true,...
            'Items',{},...
            'Value',{});

            this.AddButton=uibutton('push',...
            'Parent',buttonBox,...
            'Text','',...
            'ButtonPushedFcn',@this.onAddTag,...
            'Icon',fullfile(icomm.pi.internal.piclientroot,'icons','Forward_24.png'));
            this.RemoveButton=uibutton('push',...
            'Parent',buttonBox,...
            'Text','',...
            'ButtonPushedFcn',@this.onRemoveTag,...
            'Icon',fullfile(icomm.pi.internal.piclientroot,'icons','Back_24.png'));
            this.UpButton=uibutton('push',...
            'Parent',buttonBox,...
            'Text','',...
            'ButtonPushedFcn',@this.onUp,...
            'Icon',fullfile(icomm.pi.internal.piclientroot,'icons','Up_24.png'));
            this.DownButton=uibutton('push',...
            'Parent',buttonBox,...
            'Text','',...
            'ButtonPushedFcn',@this.onDown,...
            'Icon',fullfile(icomm.pi.internal.piclientroot,'icons','Down_24.png'));
        end

    end

    methods(Access=private)

        function update(this)
            if~isempty(this.FilterValue)

                validTags=contains(this.AllAvailableTags_,this.FilterValue,...
                'IgnoreCase',true);
                allAvailableTags=this.AllAvailableTags_(validTags);
            else
                allAvailableTags=this.AllAvailableTags_;
            end

            this.AvailableTagListBox.Items=cellstr(setdiff(...
            allAvailableTags,this.SelectedTags));
        end

        function onNameFilterChanged(this,~,eventData)
            this.FilterValue=eventData.Value;
            this.update();
        end

        function onAddTag(this,varargin)
            selectedTags=this.AvailableTagListBox.Value;
            if isempty(selectedTags)
                return;
            end

            this.SelectedTagListBox.Items=[...
            this.SelectedTagListBox.Items(:);...
            selectedTags(:);...
            ];
            this.update();
            this.notify('SelectedTagsChanged');
        end

        function onRemoveTag(this,varargin)
            selectedTags=this.SelectedTagListBox.Value;
            if isempty(selectedTags)
                return
            end

            this.SelectedTagListBox.Items=setdiff(...
            this.SelectedTagListBox.Items,...
            selectedTags,...
            'stable');

            this.update();
            this.notify('SelectedTagsChanged');
        end

        function onUp(this,varargin)
            if isempty(this.SelectedTagListBox.Value)
                return
            end

            this.SelectedTagListBox.ItemsData=1:numel(this.SelectedTagListBox.Items);
            restore=onCleanup(@()set(this.SelectedTagListBox,'ItemsData',[]));
            for index=sort(this.SelectedTagListBox.Value(:)','ascend')%#ok<UDIM>
                if~this.swapItemsInSelectedTagListBox(index,index-1)
                    return
                end
            end
            this.notify('SelectedTagOrderChanged');
        end

        function onDown(this,varargin)
            if isempty(this.SelectedTagListBox.Value)
                return
            end

            this.SelectedTagListBox.ItemsData=1:numel(this.SelectedTagListBox.Items);
            restore=onCleanup(@()set(this.SelectedTagListBox,'ItemsData',[]));
            for index=sort(this.SelectedTagListBox.Value(:)','descend')%#ok<UDIM>
                if~this.swapItemsInSelectedTagListBox(index,index+1)
                    return
                end
            end
            this.notify('SelectedTagOrderChanged');
        end

        function done=swapItemsInSelectedTagListBox(this,firstIndex,secondIndex)
            done=true;
            numItems=numel(this.SelectedTagListBox.Items);
            currentOrder=1:numItems;
            if any([firstIndex,secondIndex]<1)||any([firstIndex,secondIndex]>numItems)

                done=false;
                return
            end

            memory=currentOrder(firstIndex);
            currentOrder(firstIndex)=currentOrder(secondIndex);
            currentOrder(secondIndex)=memory;

            this.SelectedTagListBox.Items=this.SelectedTagListBox.Items(currentOrder);

            if any(this.SelectedTagListBox.Value==firstIndex)
                this.SelectedTagListBox.Value=[...
                setdiff(this.SelectedTagListBox.Value,firstIndex),...
                secondIndex];
            end
        end

    end

end