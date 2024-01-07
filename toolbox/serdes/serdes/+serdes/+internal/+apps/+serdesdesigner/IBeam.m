classdef IBeam<handle

    properties
        IconFilePath=[];
        Icon=[];

        Icon_Wire=[fullfile('+serdes','+internal','+apps','+serdesdesigner'),filesep,'Wire.png'];
        Icon_IBeam=[fullfile('+serdes','+internal','+apps','+serdesdesigner'),filesep,'WireAndIBeam.png'];

Canvas

Panel
Picture

Layout
        IsSelected=true;

        AllowImageClickedFcn=true;
    end


    properties(Dependent)
Visible
    end


    methods

        function obj=IBeam(canvas,parentPanel,allowImageClickedFcn)
            obj.Canvas=canvas;
            if~isempty(allowImageClickedFcn)
                obj.AllowImageClickedFcn=allowImageClickedFcn;
            end

            canvas.InstancesCreated_WireOrIBeam=canvas.InstancesCreated_WireOrIBeam+1;
            tag=strcat('WireOrIBeam:',int2str(canvas.InstancesCreated_WireOrIBeam));

            obj.createIBeam(parentPanel,tag);
        end


        function createIBeam(obj,parentPanel,tag)
            obj.Panel=uipanel(parentPanel,...
            'Title','',...
            'BorderType','none',...
            'BackgroundColor','w',...
            'Visible','on');
            obj.Panel.Layout.Row=2;
            obj.Layout=uigridlayout(obj.Panel,'RowHeight',{85},'ColumnWidth',{24,24},'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0]);
            obj.Layout.BackgroundColor='w';

            obj.createPicture(tag)
            obj.IsSelected=false;
        end


        function createPicture(obj,tag)
            obj.Picture.Panel=uipanel(obj.Layout,...
            'Title','',...
            'BorderType','none',...
            'ForegroundColor','w',...
            'BackgroundColor','w',...
            'Visible','on');
            obj.Picture.Panel.Layout.Row=1;
            obj.Picture.Panel.Layout.Column=1;
            obj.Picture.Layout=uigridlayout(obj.Picture.Panel,'RowHeight',{29,2,29,25},'ColumnWidth',{24,24},'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0]);
            obj.Picture.IBeam=uiimage(obj.Picture.Layout,...
            'ImageSource',obj.Icon_IBeam,...
            'Tag',tag,...
            'BackgroundColor','w',...
            'HorizontalAlignment','right',...
            'VerticalAlignment','top',...
            'ScaleMethod','stretch',...
            'Enable','on',...
            'Visible','on');
            obj.Picture.IBeam.Layout.Row=[1,3];
            obj.Picture.IBeam.Layout.Column=1;

            obj.Picture.Wire=uiimage(obj.Picture.Layout,...
            'ImageSource',obj.Icon_Wire,...
            'Tag',tag,...
            'BackgroundColor','w',...
            'HorizontalAlignment','right',...
            'VerticalAlignment','top',...
            'ScaleMethod','stretch',...
            'Enable','on',...
            'Visible','on');
            obj.Picture.Wire.Layout.Row=[1,3];
            obj.Picture.Wire.Layout.Column=2;

            obj.Picture.Name=uilabel(obj.Picture.Layout,...
            'HorizontalAlignment','center',...
            'VerticalAlignment','center',...
            'Text','',...
            'Enable','on',...
            'BackgroundColor','w',...
            'Visible','on');
            obj.Picture.Name.Layout.Row=4;
            obj.Picture.Name.Layout.Column=[1,2];
        end


        function setImageClickedFcn(obj)

            if obj.AllowImageClickedFcn
                if isempty(obj.Picture.IBeam.ImageClickedFcn)
                    set(obj.Picture.IBeam,'ImageClickedFcn',@(h,e)selectIBeam(obj));
                end
                if isempty(obj.Picture.Wire.ImageClickedFcn)
                    set(obj.Picture.Wire,'ImageClickedFcn',@(h,e)selectIBeam(obj));
                end
            end
        end


        function val=get.Visible(obj)
            val=obj.Panel.Visible;
        end
        function set.Visible(obj,val)
            obj.Panel.Visible=val;
        end


        function val=get.IsSelected(obj)
            val=obj.IsSelected;
        end
        function set.IsSelected(obj,val)
            if obj.IsSelected~=val

                obj.IsSelected=val;
                if obj.IsSelected
                    obj.showWiresAndIBeam();
                else
                    obj.showWiresOnly();
                end
            end
        end


        function showWiresAndIBeam(obj)
            obj.Picture.Layout.ColumnWidth={24,0};
        end
        function showWiresOnly(obj)

            obj.Picture.Layout.ColumnWidth={0,24};
        end


        function unselectIBeam(obj)
            obj.IsSelected=false;
        end
        function selectIBeam(obj)
            if obj.IsSelected
                return;
            end

            ibeamIdx=-1;
            if obj.Canvas.Cascade.IBeam==obj

                ibeamIdx=length(obj.Canvas.Cascade.Elements)+1;
            else
                for i=1:length(obj.Canvas.Cascade.Elements)
                    if obj.Canvas.Cascade.Elements(i).WireOrIBeam==obj

                        ibeamIdx=i;
                        break;
                    end
                end
            end

            obj.Canvas.removeIBeam();
            obj.Canvas.InsertIdx=ibeamIdx;
            obj.Canvas.updateIBeamTxOrRxIdx();
            obj.Canvas.adjustButtonsForScroll();
            obj.IsSelected=true;
        end
    end
end
