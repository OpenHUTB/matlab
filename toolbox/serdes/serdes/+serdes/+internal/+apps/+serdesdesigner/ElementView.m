classdef ElementView<handle&matlab.mixin.Heterogeneous

    properties
Canvas
Panel
Picture
StageText
WireOrIBeam
Layout
Width
Height

BlockType
        IsSelected=false;
    end


    properties(Dependent)
Visible
    end


    properties(Constant)
        IconHeight=60
        IconWidth=60
        TextWidth=62
        TextHeight=20
        FontSize=7+ispc*1+ismac*4
        BackGround1=[.85,.85,.85];
        BackGround2=[.945,.945,.945];
    end


    methods

        function obj=ElementView(canvas,parentPanel,blockType,~)
            obj.Canvas=canvas;
            obj.BlockType=blockType;

            switch class(lower(blockType))
            case 'serdes.internal.apps.serdesdesigner.agc'
                canvas.InstancesCreated_AGC=canvas.InstancesCreated_AGC+1;
                tag=strcat('AGC:',int2str(canvas.InstancesCreated_AGC));
            case 'serdes.internal.apps.serdesdesigner.ffe'
                canvas.InstancesCreated_FFE=canvas.InstancesCreated_FFE+1;
                tag=strcat('FFE:',int2str(canvas.InstancesCreated_FFE));
            case 'serdes.internal.apps.serdesdesigner.vga'
                canvas.InstancesCreated_VGA=canvas.InstancesCreated_VGA+1;
                tag=strcat('VGA:',int2str(canvas.InstancesCreated_VGA));
            case 'serdes.internal.apps.serdesdesigner.satAmp'
                canvas.InstancesCreated_SatAmp=canvas.InstancesCreated_SatAmp+1;
                tag=strcat('Saturating Amplifier:',int2str(canvas.InstancesCreated_SatAmp));
            case 'serdes.internal.apps.serdesdesigner.dfeCdr'
                canvas.InstancesCreated_DfeCdr=canvas.InstancesCreated_DfeCdr+1;
                tag=strcat('DFE/CDR:',int2str(canvas.InstancesCreated_DfeCdr));
            case 'serdes.internal.apps.serdesdesigner.cdr'
                canvas.InstancesCreated_CDR=canvas.InstancesCreated_CDR+1;
                tag=strcat('CDR:',int2str(canvas.InstancesCreated_CDR));
            case 'serdes.internal.apps.serdesdesigner.ctle'
                canvas.InstancesCreated_CTLE=canvas.InstancesCreated_CTLE+1;
                tag=strcat('CTLE:',int2str(canvas.InstancesCreated_CTLE));
            case 'serdes.internal.apps.serdesdesigner.transparent'
                canvas.InstancesCreated_Transparent=canvas.InstancesCreated_Transparent+1;
                tag=strcat('Transparent:',int2str(canvas.InstancesCreated_Transparent));
            case 'serdes.internal.apps.serdesdesigner.channel'
                tag='Channel:1';
            case 'serdes.internal.apps.serdesdesigner.rcTx'
                tag='AnalogOut:1';
            case 'serdes.internal.apps.serdesdesigner.rcRx'
                tag='AnalogIn:1';
            end

            obj.createElementView(parentPanel,tag)
        end


        function val=get.Visible(obj)
            val=obj.Panel.Visible;
        end


        function set.Visible(obj,val)
            obj.Panel.Visible=val;
        end


        function createElementView(obj,parentPanel,tag)
            obj.Panel=uipanel(parentPanel,...
            'Title','',...
            'BorderType','none',...
            'Visible','on');
            obj.Panel.Layout.Row=3;
            obj.Layout=uigridlayout(obj.Panel,...
            'RowHeight',{85},'ColumnWidth',{24,60},...
            'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'BackgroundColor','w');

            obj.createPicture(tag)

            obj.Visible='off';
        end


        function createPicture(obj,tag)
            allowImageClickedFcn=~strcmpi(tag,'Channel:1')&&~strcmpi(tag,'AnalogIn:1');
            obj.WireOrIBeam=serdes.internal.apps.serdesdesigner.IBeam(obj.Canvas,obj.Layout,allowImageClickedFcn);
            obj.WireOrIBeam.Panel.Layout.Row=1;
            obj.WireOrIBeam.Panel.Layout.Column=1;
            obj.WireOrIBeam.setImageClickedFcn();

            obj.Picture.Panel=uipanel(obj.Layout,...
            'Title','',...
            'BorderType','none',...
            'Visible','on');
            obj.Picture.Panel.Layout.Row=1;
            obj.Picture.Panel.Layout.Column=2;
            obj.Picture.Layout=uigridlayout(obj.Picture.Panel,...
            'RowHeight',{29,2,29,25},'ColumnWidth',{60},...
            'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'BackgroundColor','w');

            obj.Picture.Block=uiimage(obj.Picture.Layout,...
            'Tag',tag,...
            'HorizontalAlignment','right',...
            'VerticalAlignment','top',...
            'Enable','on',...
            'Visible','on');
            obj.Picture.Block.Layout.Row=[1,3];
            obj.Picture.Block.Layout.Column=1;

            obj.Picture.Name=uilabel(obj.Picture.Layout,...
            'HorizontalAlignment','center',...
            'VerticalAlignment','center',...
            'Text','',...
            'Enable','on',...
            'BackgroundColor','w',...
            'Visible','on');
            obj.Picture.Name.Layout.Row=4;
            obj.Picture.Name.Layout.Column=1;
        end


        function unselectElement(obj)
            obj.IsSelected=false;
            obj.Picture.Block.ImageSource=obj.Icon;

            obj.Canvas.View.Parameters.ElementType='';

            obj.Canvas.View.Toolstrip.DeleteBtn.Description=string(message('serdes:serdesdesigner:DeleteElement'));
        end


        function selectElement(obj,elem)

            elementIdx=-1;
            for i=1:length(obj.Canvas.Cascade.Elements)
                if obj.Canvas.Cascade.Elements(i)==obj
                    elementIdx=i;
                    break;
                end
            end

            obj.Canvas.SelectIdx=elementIdx;
            obj.Canvas.updateSelectedTxOrRxIdx();
            obj.IsSelected=true;
            obj.Picture.Block.ImageSource=obj.highlight(3,obj.Canvas.ColorSelectedForeground);
            obj.Canvas.View.Parameters.ElementType=elem.getHeaderDescription();
        end


        function out=highlight(obj,width,clr)
            if isempty(obj.Icon)
                out=obj.Icon;
                for i=1:3
                    out(1:width,:,i)=NaN;
                    out(end-width+1:end,:,i)=NaN;
                    out(:,1:width,i)=NaN;
                    out(:,end-width+1:end,i)=NaN;
                end
            else
                out=obj.Icon;
                c=uint8(round(clr*255));
                for i=1:3
                    out(1:width,:,i)=c(i);
                    out(end-width+1:end,:,i)=c(i);
                    out(:,1:width,i)=c(i);
                    out(:,end-width+1:end,i)=c(i);
                end
            end
        end
    end
end
