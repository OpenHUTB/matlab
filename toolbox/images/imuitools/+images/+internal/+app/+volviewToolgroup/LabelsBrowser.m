

classdef LabelsBrowser<images.internal.app.imageBrowser.Thumbnails

    properties(SetAccess=protected)
        NumberOfThumbnails=0;
    end

    properties(Dependent)
LabelConfiguration
Enable
    end

    properties
LabelConfigurationInternal
        ParentPanel;
    end

    properties(Constant)
        CaptionLength=15;
    end

    events
SelectionChanged
    end

    methods

        function obj=LabelsBrowser(hParent)




            defaultBlockSize=[80,80];
            defaultThumbnailSize=[50,50];

            obj@images.internal.app.imageBrowser.Thumbnails(hParent,defaultBlockSize)
            obj.ThumbnailSize=defaultThumbnailSize;

            obj.CoalescePeriod=0;




            obj.ParentPanel=hParent;


            fig=hParent;
            fig=ancestor(fig,'figure');

            fig.WindowButtonDownFcn=@(varargin)obj.panelOnlyMouseButtonDownFcn(varargin{:});
            fig.WindowScrollWheelFcn=@(varargin)obj.mouseWheelFcn(varargin{:});
            fig.WindowKeyPressFcn=@(varargin)obj.keyPressFcn(varargin{:});


            obj.LabelConfiguration=images.internal.app.volviewToolgroup.LabelConfiguration.empty();
        end




        function set.LabelConfiguration(obj,labelConfig)
            if isempty(labelConfig)
                obj.NumberOfThumbnails=0;
            else

                if~isempty(obj.LabelConfigurationInternal)
                    if obj.LabelConfigurationInternal.NumLabels~=labelConfig.NumLabels
                        obj.setSelection(1);
                    end
                end

                obj.LabelConfigurationInternal=labelConfig;
                obj.NumberOfThumbnails=obj.LabelConfiguration.NumLabels;
            end
            obj.refreshThumbnails();

        end


        function labelConfig=get.LabelConfiguration(obj)
            labelConfig=obj.LabelConfigurationInternal;
        end


        function set.Enable(obj,state)
            state=validatestring(state,{'on','off'},mfilename,'Enable');
            obj.ParentPanel.Visible=state;
        end


        function state=get.Enable(obj)
            state=obj.ParentPanel.Visible;
        end
    end


    methods

        function updateBlockWithPlaceholder(obj,topLeftYX,imageNum)

            if~obj.ImageNumToDataInd(imageNum)

                userdata=[];
                userdata.isPlacedholder=true;
                thumbnail=obj.PlaceHolderImage;

                hImage=image(...
                'Parent',obj.hAxes,...
                'Tag','Placeholder',...
                'HitTest','off',...
                'CDataMapping','scaled',...
                'UserData',userdata,...
                'CData',thumbnail);
                obj.hImageData(end+1).hImage=hImage;
                obj.ImageNumToDataInd(imageNum)=numel(obj.hImageData);

                assert(~isempty(obj.LabelConfiguration),'Label COnfiguration is empty');
                labelName=obj.LabelConfiguration.LabelNames(imageNum);
                if strlength(labelName)>obj.CaptionLength
                    count=obj.CaptionLength-3;
                    labelName=['...',labelName{1}(end-count:end)];
                end

                obj.hImageData(end).hNameText=text(...
                obj.hAxes,...
                0,0,...
                labelName,...
                'FontSize',8,...
                'FontName','FixedWidth',...
                'Interpreter','None');
            end

            obj.repositionElements(imageNum,topLeftYX);
        end


        function updateBlockWithActual(obj,topLeftYX,imageNum)
            hImageInd=obj.ImageNumToDataInd(imageNum);
            hImage=obj.hImageData(hImageInd).hImage;

            if~strcmp(hImage.Tag,'realthumbnail')

                [thumbnail,userdata]=obj.createThumbnail(imageNum);


                hImage.CData=thumbnail;
                hImage.Tag='realthumbnail';
                userdata.isPlaceholder=false;
                hImage.UserData=userdata;
            end

            obj.repositionElements(imageNum,topLeftYX);
        end
    end


    methods

        function[thumbnail,userdata]=createThumbnail(obj,imageNum)
            if isempty(obj.LabelConfiguration)
                fullImage=obj.CorruptedImagePlaceHolder;
            else
                color=obj.LabelConfiguration.LabelColors(imageNum,:);
                fullImage=ones([obj.ThumbnailSize,3]).*reshape(im2double(color),[1,1,3]);
            end

            thumbnail=obj.resizeToThumbnail(fullImage);
            userdata=[];
        end


        function repositionElements(obj,imageNum,topLeftYX)
            hDataIdx=obj.ImageNumToDataInd(imageNum);
            hImage=obj.hImageData(hDataIdx).hImage;

            margin=5;
            hImage.YData=margin+topLeftYX(1)+obj.SelectionPatchInset...
            +obj.ThumbnailSize(1)-size(hImage.CData,1);

            xOffset=margin+obj.SelectionPatchInset;
            hImage.XData=topLeftYX(2)+xOffset;
            hImage.Visible='on';

            paddingBetweenImageAndText=10;
            posXY=[topLeftYX(2)+xOffset,...
            topLeftYX(1)+obj.ThumbnailSize(1)+paddingBetweenImageAndText+margin];
            obj.hImageData(hDataIdx).hNameText.Position=posXY;
            obj.hImageData(hDataIdx).hNameText.Visible='on';
        end

        function panelOnlyMouseButtonDownFcn(obj,varargin)

            hitObject=varargin{1}.CurrentObject;

            if isempty(hitObject)||~isvalid(hitObject)||~isgraphics(hitObject)
                return
            end

            if strcmp(hitObject.Tag,obj.ParentPanel.Tag)||strcmp(hitObject.Tag,'griddedAxes')
                obj.mouseButtonDownFcn(varargin{:});
            end

        end
    end
end

