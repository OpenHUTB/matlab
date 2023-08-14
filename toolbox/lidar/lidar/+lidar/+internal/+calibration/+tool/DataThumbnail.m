classdef DataThumbnail<handle




    properties
        Parent;
        Himage;
        UigLayout;
        OrgIndex;
        CntxtMenu;
    end

    methods
        function this=DataThumbnail(Parent,OrgIndex,idx,cbItemClicked)


            this.OrgIndex=OrgIndex;
            this.Parent=Parent;
            buildui(this,idx,cbItemClicked);
        end

        function pos=getPosition(this,idx)
            thumbnailWidth=this.Himage.Position(3);
            thumbnailHeight=this.Himage.Position(4)+...
            this.UigLayout.Padding(2)+...
            this.UigLayout.Padding(4)+...
            this.Parent.UigLayout.RowSpacing;
            pos=[1,-(idx-1)*thumbnailHeight,thumbnailWidth,thumbnailHeight];
        end

        function buildui(this,idx,cbItemClicked)
            this.UigLayout=uigridlayout(this.Parent.UigLayout,[1,1],'Tag','subuig',...
            'Scrollable','off','Padding',[10,10,10,10],...
            'Visible','off','BackgroundColor',[0,0,0],'RowHeight',{'fit'},'ColumnWidth',{220});

            this.Himage=uiimage(this.UigLayout,'ImageSource',this.Parent.Model.Datapairs(this.OrgIndex).ThumbnailImage,...
            'HorizontalAlignment','center','VerticalAlignment','center',...
            'ImageClickedFcn',cbItemClicked);

            this.UigLayout.Layout.Row=this.OrgIndex;
            this.Himage.UserData=idx;
        end

        function addCntxtMenu(this)
            if~isempty(this.CntxtMenu)&&isvalid(this.CntxtMenu)
                delete(this.CntxtMenu);
            end
            this.CntxtMenu=uicontextmenu(this.Parent.Figure);
            this.Parent.Figure.ContextMenu=this.CntxtMenu;
            this.Himage.ContextMenu=this.CntxtMenu;
            idx=length(this.Parent.Thumbnails);
            updateCntxtMenutoRemove(this,idx);
        end

        function updateCntxtMenutoRemove(this,idx)
            if~isempty(this.CntxtMenu.Children)&&isvalid(this.CntxtMenu.Children)
                delete(this.CntxtMenu.Children);
            end
            m1=uimenu(this.CntxtMenu,'Label',string(message('lidar:lidarCameraCalibrator:RemoveCM')),...
            'UserData',idx,'Callback',@(es,ev)multipleDelete(this.Parent,es,false));
            this.Himage.UserData=idx;
            this.CntxtMenu.ContextMenuOpeningFcn=this.Himage.ImageClickedFcn;
        end

        function updateCntxtMenutoRemoveAndRecalibrate(this,idx)
            if~isempty(this.CntxtMenu.Children)&&isvalid(this.CntxtMenu.Children)
                delete(this.CntxtMenu.Children);
            end
            m2=uimenu(this.CntxtMenu,'Label',...
            string(message('lidar:lidarCameraCalibrator:RemoveAndRecalibrateCM')),...
            'UserData',idx,'Callback',@(es,ev)multipleDelete(this.Parent,es,true));
            this.Himage.UserData=idx;
            this.CntxtMenu.ContextMenuOpeningFcn=this.Himage.ImageClickedFcn;
        end

        function setContextMenuEnabledState(this,state)
            if~isempty(this.CntxtMenu.Children)&&isvalid(this.CntxtMenu.Children)
                this.CntxtMenu.Children.Enable=state;
            end
        end

        function updateLabelText(this,i)

            imgFilename=dir(string(this.Parent.Model.Datapairs(this.OrgIndex).ImageFile)).name;
            ptcFilename=dir(string(this.Parent.Model.Datapairs(this.OrgIndex).PointcloudFile)).name;
            str=num2str(i)+": "+imgFilename+" & "+ptcFilename;

            thumbnailSize=[100,150];
            this.Himage.ImageSource(end-23:end,:,:)=zeros(24,thumbnailSize(2)*2,3,'uint8');
            this.Himage.ImageSource=insertText(this.Himage.ImageSource,[thumbnailSize(2),thumbnailSize(1)+1],str,'FontSize',14,'TextColor','white','BoxColor','black','AnchorPoint','Centertop');
        end

        function resetThumbnail(this)

            if(~isempty(this.UigLayout)&&isvalid(this.UigLayout))
                this.UigLayout.BackgroundColor=[0,0,0];
            end
            if(~isempty(this.Himage)&&isvalid(this.Himage))
                this.Himage.BackgroundColor=[0,0,0];
                [tf,loc]=ismember(this.Himage.UserData,this.Parent.HilightedIdx);
                if tf
                    this.Parent.HilightedIdx(loc)=[];
                end
            end
        end
    end
end
