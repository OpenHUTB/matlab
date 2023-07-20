

























classdef LVDataBrowser<handle

    properties(Access=private)

        DataList cell={};



SelectedIndex
    end

    properties(Access=private)

        ParentFigure matlab.ui.Figure


        DefaultText matlab.ui.control.Label


        ListItemHandle matlab.ui.control.ListBox


        DeleteMenu matlab.ui.container.Menu
    end

    properties(Constant,Hidden)



        ITEMWIDTH=19;
    end

    properties(Dependent,Hidden)

SeletectedItem
    end

    properties

        IsMeasurementTools=false;


        IsWaitState=false;
    end

    events

RequestToDelete


RequestToChangeSelection
    end

    methods



        function this=LVDataBrowser(parentFig)
            this.ParentFigure=parentFig;


            this.ParentFigure.WindowButtonDownFcn=...
            @(src,evt)this.respondToUserInterction();


            this.createDefaultText();
            this.createListItem();
            this.createContextMenu();

            this.resize();
        end


        function insert(this,entry)

            this.DataList{end+1}=entry;

            this.ListItemHandle.Items{end+1}=entry;
            this.ListItemHandle.Visible=true;


            this.ListItemHandle.Value=entry;
            this.SelectedIndex=numel(this.ListItemHandle.Items);


            this.DefaultText.Visible=false;
        end


        function resize(this)

            pos=this.ParentFigure.Position;
            if any(pos(3:4)<=0)

                return;
            end
            this.ListItemHandle.Position=[0,0,pos(3),pos(4)];
            this.DefaultText.Position=[10,pos(4)*0.85,pos(3)-20,40];
        end


        function reset(this)

            this.ListItemHandle.Items={};
            this.DataList={};
            this.SelectedIndex=[];

            this.ListItemHandle.Visible=false;

            this.DefaultText.Visible=true;
        end


        function remove(this,entry)


            idx=find(strcmp(this.ListItemHandle.Items,entry));

            if isempty(idx)
                return;
            end


            this.ListItemHandle.Items(idx)=[];

            if isequal(idx,this.SelectedIndex)

                this.SelectedIndex=numel(this.ListItemHandle.Items);
            elseif this.SelectedIndex>idx

                this.SelectedIndex=this.SelectedIndex-1;
            end


            this.ListItemHandle.Value=...
            this.ListItemHandle.Items{this.SelectedIndex};
        end


        function set(this,TF)

            this.ListItemHandle.Enable=TF;
        end


        function setVisibility(this,TF)

            this.ListItemHandle.Enable=TF;
            this.IsWaitState=~TF;

            if TF
                this.createContextMenu();
            else
                delete(this.DeleteMenu);
            end
        end

    end




    methods

        function item=get.SeletectedItem(this)

            if isempty(this.SelectedIndex)
                item=[];
            else
                item=this.ListItemHandle.Items{this.SelectedIndex};
            end
        end
    end




    methods(Access=private)

        function createDefaultText(this)

            position=[10,this.ParentFigure.Position(4)*0.85,...
            this.ParentFigure.Position(3)-20,40];

            this.DefaultText=uilabel('Parent',this.ParentFigure,...
            'WordWrap','on','Visible',true,...
            'Text',getString(message('lidar:lidarViewer:DataBrowserDefaultText')),...
            'FontColor',[0.45,0.45,0.45]);

            if any(position<=0)
                return;
            end

            this.DefaultText.Position=position;
        end


        function createListItem(this)

            this.ListItemHandle=uilistbox('Parent',this.ParentFigure,...
            'Visible','off',...
            'Items',{},...
            'Tag','lvDataBrowser',...
            'BackgroundColor',[0.94,0.94,0.94],...
            'FontSize',12);
        end


        function createContextMenu(this)

            cMenuHandle=uicontextmenu(this.ParentFigure);


            this.DeleteMenu=uimenu(cMenuHandle,'Text',...
            getString(message('lidar:lidarViewer:DeleteData')),...
            'Callback',@(~,~)requestToDelete(this),...
            'Tag','deleteCmenuDB');

            this.ListItemHandle.ContextMenu=cMenuHandle;
        end


        function setSelectedItem(this,idx)




            msg=getString(message('lidar:lidarViewer:WarningOnDataToggling'));


            TF=uiconfirm(this.ParentFigure,msg,...
            getString(message('lidar:lidarViewer:ConfirmAction')),...
            'Options',{getString(message('MATLAB:uistring:popupdialogs:Yes')),...
            getString(message('MATLAB:uistring:popupdialogs:No'))});

            if strcmp(TF,...
                getString(message('MATLAB:uistring:popupdialogs:Yes')))
                this.SelectedIndex=idx;
                this.IsMeasurementTools=false;


                evt=lidar.internal.lidarViewer.events.DataBrowserInfoEventData(this.SeletectedItem);
                notify(this,'RequestToChangeSelection',evt);
            else

            end
            pause(1);
            this.ListItemHandle.Value=this.SeletectedItem;
        end


        function requestToDelete(this)



            [~,~,idx]=getMouseClickInfo(this);

            if idx>numel(this.ListItemHandle.Items)

                return;
            end


            evt=lidar.internal.lidarViewer.events.DataBrowserInfoEventData(...
            this.ListItemHandle.Items{idx});
            notify(this,'RequestToDelete',evt);

            if~isempty(this.SelectedIndex)&&~strcmp(this.ListItemHandle.Value,...
                this.ListItemHandle.Items{this.SelectedIndex})
                this.ListItemHandle.Value=...
                this.ListItemHandle.Items{this.SelectedIndex};
            end
        end


        function respondToUserInterction(this)


            if this.IsWaitState
                return;
            end

            switch this.ParentFigure.SelectionType
            case 'alt'
                this.respondToRightClick();
            case 'normal'
                this.respondToNormalClick();
            end
        end


        function respondToRightClick(this)


            [bottomMostPos,mousePos,~]=this.getMouseClickInfo();

            if mousePos(2)<bottomMostPos&&this.DeleteMenu.Visible

                this.DeleteMenu.Visible='off';
            elseif mousePos(2)>bottomMostPos&&~this.DeleteMenu.Visible

                this.DeleteMenu.Visible='on';
            end

            if mousePos(2)>bottomMostPos




                this.ListItemHandle.Value=...
                this.ListItemHandle.Items{this.SelectedIndex};
            end
        end


        function respondToNormalClick(this)


            [bottomMostPos,mousePos,idx]=this.getMouseClickInfo();

            if mousePos(2)>bottomMostPos
                if idx<=numel(this.ListItemHandle.Items)&&idx>0...
                    &&idx~=this.SelectedIndex
                    this.setSelectedItem(idx)
                end
            end
        end


        function[bottomMostPos,mousePos,idx]=getMouseClickInfo(this)



            mousePos=get(this.ParentFigure,'CurrentPoint');


            bottomMostPos=this.ListItemHandle.Position(4)-...
            this.ITEMWIDTH*numel(this.ListItemHandle.Items);


            idx=ceil((this.ListItemHandle.Position(4)-mousePos(2))/...
            this.ITEMWIDTH);
        end
    end
end