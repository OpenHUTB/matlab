classdef Canvas<handle

    properties
        Elements=[]

        InstancesCreated_AGC=0;
        InstancesCreated_FFE=0;
        InstancesCreated_VGA=0;
        InstancesCreated_SatAmp=0;
        InstancesCreated_DfeCdr=0;
        InstancesCreated_CDR=0;
        InstancesCreated_CTLE=0;
        InstancesCreated_Transparent=0;
        InstancesCreated_WireOrIBeam=0;
    end


    properties(Hidden)
View
Figure

Panel
Cascade
Layout
Width
Height

AxesTx
AxesRx

        ChannelIndex=2;
        IBeamTxIndex=1;
        IBeamRxIndex=2;
        SelectedTxIndex=1;
        SelectedRxIndex=1;

        isConnectionLinesVisible='on';

        isMousePressed=false;

        HighlightIdx=[]
        SelectIdx=[]
        InsertIdx=1
    end


    properties(Dependent)
PanelPositionX
    end


    properties(Constant)
        InputIconFilePath=[fullfile('+serdes','+internal','+apps','+serdesdesigner'),filesep,'input.png'];
        InputIcon=imread([fullfile('+serdes','+internal','+apps','+serdesdesigner'),filesep,'input.png']);
        OutputIconFilePath=[fullfile('+serdes','+internal','+apps','+serdesdesigner'),filesep,'output.png'];
        OutputIcon=imread([fullfile('+serdes','+internal','+apps','+serdesdesigner'),filesep,'output.png']);

        ColorSelectedForeground=[0,153,255]./255;

    end


    methods

        function obj=Canvas(parent)
            obj.View=parent;
            obj.Figure=obj.View.CanvasFig;

            obj.createCanvas();
            set(obj.Figure,'WindowButtonUpFcn',@(~,e)windowMousePress(obj,e));
            set(obj.Figure,'WindowButtonMotionFcn',@(~,e)windowMouseMotion(obj,e));
            set(obj.Figure,'SizeChangedFcn',@(~,e)sizeChanged(obj,e));
        end


        function updateChannelIndex(obj)

            drawnow;
            if numel(obj.Cascade.Elements)>0
                for i=1:numel(obj.Cascade.Elements)
                    if strcmp(obj.Cascade.Elements(i).Type,'channel')
                        obj.ChannelIndex=i;
                        return;
                    end
                end
            end
        end


        function updateSelectedTxOrRxIdx(obj)

            drawnow;
            obj.updateChannelIndex();
            if obj.SelectIdx<obj.ChannelIndex
                obj.SelectedTxIndex=obj.SelectIdx;
            elseif obj.SelectIdx>obj.ChannelIndex
                obj.SelectedRxIndex=obj.SelectIdx-obj.ChannelIndex;
            end
        end


        function updateIBeamTxOrRxIdx(obj)

            drawnow;
            obj.updateChannelIndex();
            if obj.InsertIdx<obj.ChannelIndex
                obj.IBeamTxIndex=obj.InsertIdx;
            elseif obj.InsertIdx>obj.ChannelIndex
                obj.IBeamRxIndex=obj.InsertIdx-obj.ChannelIndex;
            end
        end


        function updateAxes(obj)

            drawnow;
            if numel(obj.Cascade.Elements)>0
                for i=1:numel(obj.Cascade.Elements)
                    if strcmp(obj.Cascade.Elements(i).Type,'channel')
                        channelColumn=obj.Cascade.Elements(i).Panel.Layout.Column;
                        obj.resizeAxes(channelColumn);
                        return;
                    end
                end
            end
        end


        function resizeAxes(obj,channelColumn)

            drawnow;
            firstColumn=obj.Cascade.Input.Layout.Column;
            lastColumn=obj.Cascade.Output.Layout.Column;
            obj.AxesTx.Layout.Column=[firstColumn(1)+1,channelColumn(1)+1];
            obj.AxesRx.Layout.Column=[channelColumn(2)+1,lastColumn(1)+1];
            obj.AxesTx.Visible='on';
            obj.AxesRx.Visible='on';
        end


        function colorAxes(obj,colorTx,colorRx)

            drawnow;
            obj.AxesTx.Title.Color=colorTx;
            obj.AxesTx.XColor=colorTx;
            obj.AxesTx.YColor=colorTx;

            obj.AxesRx.Title.Color=colorRx;
            obj.AxesRx.XColor=colorRx;
            obj.AxesRx.YColor=colorRx;
        end


        function x=get.PanelPositionX(obj)
            c=obj.Cascade.Elements;
            x=arrayfun(@(e)e.Panel.Position(1),c);
        end


        function createCanvas(obj)
            panel=uipanel(obj.View.CanvasFigLayout,'Title','','BorderType','line','Visible','on');
            obj.Layout=uigridlayout(panel,...
            'RowHeight',{'1x',40,85,20,'1x'},'ColumnWidth',{'1x',70,12,'fit',12,70,'1x'},...
            'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'Scrollable','on','BackgroundColor','w');
            set(obj.Layout,'ScrollableViewportLocationChangedFcn',@(~,e)scrollbarChanged(obj,e));

            obj.createCascade();

            obj.AxesTx=axes('Parent',obj.Layout,'Box','on','XTick',[],'YTick',[],'Color','none','Visible','off','Units','pixels');
            obj.AxesRx=axes('Parent',obj.Layout,'Box','on','XTick',[],'YTick',[],'Color','none','Visible','off','Units','pixels');
            obj.AxesTx.Layout.Row=[2,4];
            obj.AxesRx.Layout.Row=[2,4];
            obj.AxesTx.Title.String='Tx';
            obj.AxesRx.Title.String='Rx';
            obj.AxesTx.Toolbar.Visible='off';
            obj.AxesRx.Toolbar.Visible='off';
            obj.colorAxes('k','k');
        end


        function createCascade(obj)
            obj.Cascade.Input=uipanel(obj.Layout,...
            'Title','',...
            'BorderType','none',...
            'Visible','on');
            obj.Cascade.Input.Layout.Row=3;
            obj.Cascade.Input.Layout.Column=2;
            obj.Cascade.InputLayout=uigridlayout(obj.Cascade.Input,...
            'RowHeight',{60,25},'ColumnWidth',{12,12,58},...
            'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'BackgroundColor','w');
            obj.Cascade.InputImage=uiimage(obj.Cascade.InputLayout,...
            'ImageSource',obj.InputIconFilePath,...
            'HorizontalAlignment','right',...
            'VerticalAlignment','top',...
            'Enable','on',...
            'Visible','on');
            obj.Cascade.InputImage.Layout.Row=1;
            obj.Cascade.InputImage.Layout.Column=3;
            obj.Cascade.Elements=serdes.internal.apps.serdesdesigner.ElementView.empty;
           obj.Cascade.IBeam=serdes.internal.apps.serdesdesigner.IBeam(obj,obj.Layout,true);
            obj.Cascade.IBeam.Panel.Layout.Row=3;
            obj.Cascade.IBeam.Panel.Layout.Column=3;
            obj.Cascade.IBeam.Panel.Visible='on';
            obj.Cascade.IBeam.setImageClickedFcn();
            obj.Cascade.Output=uipanel(obj.Layout,...
            'Title','',...
            'BorderType','none',...
            'Visible','on');
            obj.Cascade.Output.Layout.Row=3;
            obj.Cascade.Output.Layout.Column=4;
            obj.Cascade.OutputLayout=uigridlayout(obj.Cascade.Output,...
            'RowHeight',{60,25},'ColumnWidth',{58,12,12},...
            'RowSpacing',0,'ColumnSpacing',0,'Padding',[0,0,0,0],'BackgroundColor','w');
            obj.Cascade.OutputImage=uiimage(obj.Cascade.OutputLayout,...
            'ImageSource',obj.OutputIconFilePath,...
            'HorizontalAlignment','right',...
            'VerticalAlignment','top',...
            'Enable','on',...
            'Visible','on');
            obj.Cascade.OutputImage.Layout.Row=1;
            obj.Cascade.OutputImage.Layout.Column=1;
        end


        function setInputOutputLinesVisible(obj)
            obj.Cascade.Input.Visible=obj.isConnectionLinesVisible;
            obj.Cascade.Output.Visible=obj.isConnectionLinesVisible;
        end


        function selectElement(obj,index)
            obj.setSelectedElement(index);

            if index<obj.ChannelIndex

                obj.colorAxes(obj.ColorSelectedForeground,'k');
                obj.addTxIBeam();
                for i=1:numel(obj.View.Toolstrip.AddButtons)

                    button=obj.View.Toolstrip.AddButtons(i);
                    button.Description=string(message('serdes:serdesdesigner:AddTxElement',obj.View.Toolstrip.getButtonName(button)));
                end
            elseif index>obj.ChannelIndex

                obj.colorAxes('k',obj.ColorSelectedForeground);
                obj.addRxIBeam();
                for i=1:numel(obj.View.Toolstrip.AddButtons)

                    button=obj.View.Toolstrip.AddButtons(i);
                    button.Description=string(message('serdes:serdesdesigner:AddRxElement',obj.View.Toolstrip.getButtonName(button)));
                end
            else

                obj.colorAxes('k','k');
                obj.removeIBeam();
                obj.InsertIdx=-1;
                obj.View.enableInsertionActions(false);
                for i=1:numel(obj.View.Toolstrip.AddButtons)

                    button=obj.View.Toolstrip.AddButtons(i);
                    button.Description=string(message('serdes:serdesdesigner:AddElement',obj.View.Toolstrip.getButtonName(button)));
                end
            end

        end
    end


    methods(Hidden)

        function idx=getSelectIdx(obj)

            if~isempty(obj.Cascade.Elements)
                for idx=1:length(obj.Cascade.Elements)
                    if obj.Cascade.Elements(idx).IsSelected
                        return;
                    end
                end
            end
            idx=0;
        end


        function idx=getInsertIdx(obj)

            if~isempty(obj.Cascade.IBeam)&&obj.Cascade.IBeam.IsSelected
                idx=length(obj.Cascade.Elements)+1;
                return;
            end
            if~isempty(obj.Cascade.Elements)
                for idx=1:length(obj.Cascade.Elements)
                    if obj.Cascade.Elements(idx).WireOrIBeam.IsSelected
                        return;
                    end
                end
            end
            idx=-1;
        end


        function setSelectedElement(obj,idx)
            if~isempty(obj.Cascade)&&length(obj.Cascade.Elements)>=idx
                for i=1:length(obj.Cascade.Elements)
                    if i~=idx
                        obj.Cascade.Elements(i).unselectElement();
                    end
                end
                obj.Cascade.Elements(idx).selectElement(obj.View.SerdesDesignerTool.Model.SerdesDesign.Elements{idx});
            end
        end


        function removeIBeam(obj)
            if~isempty(obj.Cascade)&&obj.InsertIdx~=-1
                if~isempty(obj.Cascade.IBeam)
                    obj.Cascade.IBeam.unselectIBeam();
                end
                if~isempty(obj.Cascade.Elements)&&length(obj.Cascade.Elements)>=1
                    for idx=1:length(obj.Cascade.Elements)
                        obj.Cascade.Elements(idx).WireOrIBeam.unselectIBeam();
                    end
                end
                obj.InsertIdx=-1;
                drawnow;
            end
        end


        function addTxIBeam(obj)

            obj.updateChannelIndex();
            if obj.IBeamTxIndex<obj.ChannelIndex-1
                obj.addIBeam(obj.IBeamTxIndex);
            else

                obj.addIBeam(obj.ChannelIndex-1);
            end
        end


        function addRxIBeam(obj)

            obj.updateChannelIndex();
            if obj.ChannelIndex+obj.IBeamRxIndex>obj.ChannelIndex+1
                obj.addIBeam(obj.ChannelIndex+obj.IBeamRxIndex);
            else

                obj.addIBeam(obj.ChannelIndex+2);
            end
        end
        function addIBeam(obj,idx)

            if~isempty(obj.Cascade)
                if~isempty(obj.Cascade.IBeam)||~isempty(obj.Cascade.Elements)
                    if length(obj.Cascade.Elements)>=idx

                        if~obj.Cascade.Elements(idx).WireOrIBeam.IsSelected
                            obj.removeIBeam();
                            obj.Cascade.Elements(idx).WireOrIBeam.selectIBeam();
                        end
                    elseif length(obj.Cascade.Elements)+length(obj.Cascade.IBeam)==idx

                        if~obj.Cascade.IBeam.IsSelected
                            obj.removeIBeam();
                            obj.Cascade.IBeam.selectIBeam();
                        end
                    else
                        return;
                    end
                    if obj.AxesTx.Title.Color(2)

                        obj.IBeamTxIndex=idx;
                    elseif obj.AxesRx.Title.Color(2)

                        obj.updateChannelIndex();
                        obj.IBeamRxIndex=idx-obj.ChannelIndex;
                    end
                    obj.InsertIdx=idx;
                    obj.adjustButtonsForScroll();
                end
            end
        end


        function deleteRemoveElementView(obj,index)

            deletedColumn=obj.Cascade.Elements(index).Panel.Layout.Column;
            if deletedColumn<1
                return;
            end
            obj.Cascade.Elements(index).delete
            obj.Cascade.Elements(index)=[];

            deletedColumnCnt=0;
            for column=deletedColumn(2):-1:deletedColumn(1)

                obj.Layout.ColumnWidth(column)=[];
                deletedColumnCnt=deletedColumnCnt+1;
            end

            obj.Elements{index}.delete;
            obj.Elements(index)=[];
            if~isempty(obj.Cascade.Elements)&&length(obj.Cascade.Elements)>=index

                for i=index:length(obj.Cascade.Elements)
                    obj.Cascade.Elements(i).Panel.Layout.Column=obj.Cascade.Elements(i).Panel.Layout.Column-deletedColumnCnt;
                end
            end
            if obj.Cascade.IBeam.Panel.Layout.Column>deletedColumn

                obj.Cascade.IBeam.Panel.Layout.Column=obj.Cascade.IBeam.Panel.Layout.Column-deletedColumnCnt;
            end

            obj.Cascade.Output.Layout.Column=obj.Cascade.Output.Layout.Column-deletedColumnCnt;


            if strcmpi(obj.Layout.ColumnWidth{end},'1x')
                for i=length(obj.Layout.ColumnWidth):-1:obj.Cascade.Output.Layout.Column+1
                    if strcmpi(obj.Layout.ColumnWidth{i-1},'1x')
                        obj.Layout.ColumnWidth(i)=[];
                    end
                end
            end
        end


        function deleteElement(obj,serdesDesign,index)

            unselectElement(obj.Cascade.Elements(index));
            obj.Cascade.Elements(index).Visible='off';

            obj.deleteRemoveElementView(index);

            if numel(obj.Cascade.Elements)>0

                obj.SelectIdx=max(1,index-1);
                selectElement(obj.Cascade.Elements(obj.SelectIdx),serdesDesign.Elements{obj.SelectIdx});


                if isa(serdesDesign.Elements{obj.SelectIdx},'serdes.internal.apps.serdesdesigner.rcTx')
                    obj.InsertIdx=obj.SelectIdx;
                else
                    obj.InsertIdx=obj.SelectIdx+1;
                end
                obj.updateSelectedTxOrRxIdx();
            else
                obj.SelectIdx=[];
                obj.InsertIdx=1;
            end
            obj.addIBeam(obj.InsertIdx);


            obj.Elements=serdesDesign.Elements;

            obj.updateAxes();
        end


        function deleteAllElements(obj)

            drawnow;
            n=numel(obj.Cascade.Elements);
            if n==0
                return;
            end

            obj.removeIBeam();
            if obj.SelectIdx>0
                unselectElement(obj.Cascade.Elements(obj.SelectIdx));
            else
                obj.View.Parameters.ElementType='';
            end
            for index=n:-1:1
                obj.Cascade.Elements(index).Visible='off';
                obj.deleteRemoveElementView(index);
            end

            obj.SelectIdx=[];
            obj.InsertIdx=1;
            obj.addIBeam(obj.InsertIdx)

            obj.updateAxes();
        end


        function insertAddElementView(obj,elem,index)

            switch class(lower(elem))
            case 'serdes.internal.apps.serdesdesigner.agc'
                iconFile='agc_60.png';
            case 'serdes.internal.apps.serdesdesigner.ffe'
                iconFile='ffe_60.png';
            case 'serdes.internal.apps.serdesdesigner.vga'
                iconFile='vga_60.png';
            case 'serdes.internal.apps.serdesdesigner.satAmp'
                iconFile='satAmp_60.png';
            case 'serdes.internal.apps.serdesdesigner.dfeCdr'
                iconFile='dfeCdr_60.png';
            case 'serdes.internal.apps.serdesdesigner.cdr'
                iconFile='cdr_60.png';
            case 'serdes.internal.apps.serdesdesigner.ctle'
                iconFile='ctle_60.png';
            case 'serdes.internal.apps.serdesdesigner.transparent'
                iconFile='transparent_60.png';
            case 'serdes.internal.apps.serdesdesigner.channel'
                iconFile='channel_60.png';
            case 'serdes.internal.apps.serdesdesigner.rcTx'
                iconFile='rcTx_60.png';
            case 'serdes.internal.apps.serdesdesigner.rcRx'
                iconFile='rcRx_60.png';
            otherwise
                return;
            end
            elemView=serdes.internal.apps.serdesdesigner.BlockView(obj,obj.Layout,elem,iconFile);
            obj.Cascade.Elements=[obj.Cascade.Elements(1:index-1),...
            elemView,...
            obj.Cascade.Elements(index:end)];
            elementsColumnCnt=length(obj.Cascade.Elements)*3;

            obj.Layout.ColumnWidth{1}='1x';

            inputColumn=[2,4];
            obj.Cascade.Input.Layout.Column=inputColumn;
            obj.Layout.ColumnWidth{inputColumn(1)}=58;
            obj.Layout.ColumnWidth{inputColumn(1)+1}=12;
            obj.Layout.ColumnWidth{inputColumn(2)}=12;

            for i=1:length(obj.Cascade.Elements)
                iBeamColumnA=i*3+2;
                iBeamColumnB=i*3+3;
                elementColumn=i*3+4;
                obj.Cascade.Elements(i).Panel.Layout.Column=[iBeamColumnA,elementColumn];
                obj.Layout.ColumnWidth{iBeamColumnA}=12;
                obj.Layout.ColumnWidth{iBeamColumnB}=12;
                obj.Layout.ColumnWidth{elementColumn}=60;
            end

            iBeamColumn=elementsColumnCnt+5;
            obj.Cascade.IBeam.Panel.Layout.Column=iBeamColumn;
            obj.Layout.ColumnWidth{iBeamColumn}=24;

            outputColumn=[elementsColumnCnt+6,elementsColumnCnt+8];
            obj.Cascade.Output.Layout.Column=outputColumn;
            obj.Layout.ColumnWidth{outputColumn(1)}=12;
            obj.Layout.ColumnWidth{outputColumn(1)+1}=12;
            obj.Layout.ColumnWidth{outputColumn(2)}=58;

            obj.Layout.ColumnWidth{elementsColumnCnt+9}='1x';


            if obj.AxesTx.Title.Color(2)
                obj.IBeamTxIndex=index+1;
            elseif obj.AxesRx.Title.Color(2)
                obj.updateChannelIndex();
                obj.IBeamRxIndex=index-obj.ChannelIndex+1;
            end
        end


        function isUnique=isUniqueName(~,serdesDesign,index)
            isUnique=true;
            if~isempty(serdesDesign)&&...
                ~isempty(serdesDesign.Elements)&&...
                index>0&&index<=numel(serdesDesign.Elements)
                name=serdesDesign.Elements{index}.Name;
                for i=1:numel(serdesDesign.Elements)
                    if i~=index
                        if strcmpi(name,serdesDesign.Elements{i}.Name)
                            isUnique=false;
                            return;
                        end
                    end
                end
            end
        end


        function setUniqueName(obj,serdesDesign,index)
            if~isempty(serdesDesign)&&index>0&&index<=numel(serdesDesign.Elements)
                name=serdesDesign.Elements{index}.Name;
                postfix=1;
                while~obj.isUniqueName(serdesDesign,index)
                    postfix=postfix+1;
                    serdesDesign.Elements{index}.Name=strcat(name,int2str(postfix));
                end
                if~isempty(serdesDesign.Elements{index}.BlockName)
                    serdesDesign.Elements{index}.BlockName=serdesDesign.Elements{index}.Name;
                end
            end
        end


        function insertElement(obj,serdesDesign,index)
            obj.setUniqueName(serdesDesign,index);

            obj.AxesTx.Visible='off';
            obj.AxesRx.Visible='off';


            if~isempty(obj.SelectIdx)
                unselectElement(obj.Cascade.Elements(obj.SelectIdx))
            end
            obj.insertAddElementView(serdesDesign.Elements{index},index);
            obj.Cascade.Elements(index).Visible='on';

            obj.SelectIdx=index;
            selectElement(obj.Cascade.Elements(obj.SelectIdx),...
            serdesDesign.Elements{obj.SelectIdx});

            obj.SelectIdx=index;
            obj.updateSelectedTxOrRxIdx();

            obj.InsertIdx=obj.SelectIdx+1;
            obj.addIBeam(obj.InsertIdx);
            obj.Elements=serdesDesign.Elements;

            obj.updateAxes();
        end


        function unselectAllElements(obj)
            if~isempty(obj.Cascade)&&~isempty(obj.Cascade.Elements)
                for i=1:length(obj.Cascade.Elements)
                    unselectElement(obj.Cascade.Elements(i));
                end

                obj.updateChannelIndex();
                obj.SelectIdx=NaN;
            end
        end


        function insertAllElements(obj,serdesDesign)
            n=numel(serdesDesign.Elements);
            if n==0
                obj.Elements=serdesDesign.Elements;
                return
            end

            obj.AxesTx.Visible='off';
            obj.AxesRx.Visible='off';

            if~isempty(obj.SelectIdx)
                unselectElement(obj.Cascade.Elements(obj.SelectIdx))
            end
            for index=1:n
                obj.insertAddElementView(serdesDesign.Elements{index},index);
                obj.Cascade.Elements(index).Visible='on';
            end

            for index=1:n
                selectElement(obj.Cascade.Elements(index),serdesDesign.Elements{index});
                unselectElement(obj.Cascade.Elements(index));
            end

            obj.SelectIdx=1;
            selectElement(obj.Cascade.Elements(1),serdesDesign.Elements{1})
            obj.InsertIdx=n+1;
            obj.colorAxes(obj.ColorSelectedForeground,'k');
            obj.updateChannelIndex();
            obj.InsertIdx=obj.ChannelIndex-1;
            obj.addIBeam(obj.InsertIdx);
            obj.IBeamTxIndex=obj.InsertIdx;
            obj.IBeamRxIndex=2;

            c=obj.Cascade.Elements;
            if numel(c)<1
                return
            end
            if~isnan(obj.SelectIdx)
                unselectElement(c(obj.SelectIdx));
            end
            obj.SelectIdx=obj.InsertIdx;
            obj.SelectedTxIndex=obj.InsertIdx;
            obj.SelectedRxIndex=1;
            drawnow;
            obj.Elements=serdesDesign.Elements;
            obj.notify('ElementSelected',serdes.internal.apps.serdesdesigner.ElementSelectedEventData(obj.SelectIdx));


            obj.updateAxes();
        end


        function sizeChanged(obj,e)

            obj.adjustButtonsForScroll();
        end


        function scrollbarChanged(obj,e)
            obj.adjustButtonsForScroll();
        end


        function adjustButtonsForScroll(obj)
            drawnow;
            if obj.SelectIdx==obj.ChannelIndex
                obj.View.enableInsertionActions(false);
                obj.View.Toolstrip.DeleteBtn.Enabled=false;
                return;
            end

            canvasItems=obj.Layout.Children;
            isVisible=obj.Layout.isInScrollView(canvasItems);
            toolstrip=obj.View.Toolstrip;
            canvasPosition=obj.Layout.Parent.Position;
            scrollPosition=obj.Layout.ScrollableViewportLocation;
            for i=1:length(canvasItems)
                if strcmpi(canvasItems(i).Type,'uipanel')
                    if canvasItems(i)==obj.Cascade.IBeam.Panel

                        if obj.Cascade.IBeam.IsSelected

                            if~isVisible(i)

                                obj.View.enableInsertionActions(false);
                            else

                                ibeamPosition=canvasItems(i).Position;
                                visible=scrollPosition(1)<ibeamPosition(1)+2*ibeamPosition(3)/3&&...
                                scrollPosition(1)>ibeamPosition(1)+ibeamPosition(3)/3-canvasPosition(3);
                                obj.View.enableInsertionActions(visible);
                            end
                        end
                    elseif length(canvasItems(i).Children.Children)==2

                        element=[];
                        for j=1:length(obj.Cascade.Elements)
                            if all(canvasItems(i).Position==obj.Cascade.Elements(j).Panel.Position)
                                element=obj.Cascade.Elements(j);
                                break;
                            end
                        end
                        if isempty(element)
                            continue;
                        end
                        elementPosition=element.Panel.Position;
                        blockPosition=element.Layout.Children(2).Position;
                        ibeamPosition=element.WireOrIBeam.Panel.Position;
                        if element.WireOrIBeam.IsSelected

                            if~isVisible(i)

                                obj.View.enableInsertionActions(false);
                            else

                                visible=scrollPosition(1)<elementPosition(1)+2*ibeamPosition(3)/3&&...
                                scrollPosition(1)>elementPosition(1)+ibeamPosition(3)/3-canvasPosition(3);
                                obj.View.enableInsertionActions(visible);
                            end
                        end
                        if element.IsSelected

                            if~isVisible(i)||...
                                strcmpi(element.Type,'rcTx')||...
                                strcmpi(element.Type,'rcRx')
                                toolstrip.DeleteBtn.Enabled=false;
                            else

                                visible=scrollPosition(1)<elementPosition(1)+ibeamPosition(3)+blockPosition(3)&&...
                                scrollPosition(1)>elementPosition(1)+ibeamPosition(3)-canvasPosition(3);
                                toolstrip.DeleteBtn.Enabled=visible;
                            end
                        end
                    end
                end
            end
        end
    end


    events(Hidden)
ElementSelected
    end


    methods(Access=private)

        function windowMouseMotion(obj,e)
            if~isvalid(obj)||~isvalid(obj.View)||~isvalid(obj.Figure)
                return;
            end

            obj.Figure.CurrentPoint=e.Point;

            pt=obj.Figure.CurrentPoint;
            c=obj.Cascade.Elements;
            if numel(c)<2
                return;
            end

            drawnow;
            if~isempty(obj.HighlightIdx)

                if obj.HighlightIdx~=obj.SelectIdx&&numel(c)>=obj.HighlightIdx
                    c(obj.HighlightIdx).Picture.Block.ImageSource=c(obj.HighlightIdx).Icon;
                end
                obj.HighlightIdx=[];
            end

            if isempty(obj.Layout)||~isvalid(obj.Layout)||isempty(obj.Layout.ScrollableViewportLocation)

                return;
            end
            if obj.Layout.ScrollableViewportLocation(1)~=1

                pt(1)=pt(1)+obj.Layout.ScrollableViewportLocation(1)-1;
            end
            if obj.Layout.ScrollableViewportLocation(2)~=1

                pt(2)=pt(2)+obj.Layout.ScrollableViewportLocation(2)-1;
            end

            ep=c(1).Panel.Position;
            ep(2)=ep(2)+25;
            ep(4)=ep(4)-25;
            if pt(2)<ep(2)||ep(2)+ep(4)<pt(2)
                return
            end
            xc=obj.PanelPositionX+c(1).Panel.Position(3)/2;
            [~,nearest]=min(abs(xc-pt(1)));
            if nearest==obj.SelectIdx
                return
            end

            ep=c(nearest).Panel.Position;
            ep(1)=ep(1)+24;
            ep(3)=ep(3)-24;
            if ep(1)<=pt(1)&&pt(1)<=ep(1)+ep(3)
                c(nearest).Picture.Block.ImageSource=highlight(c(nearest),3,[180,180,180]./255);
                obj.HighlightIdx=nearest;
            else
                c(nearest).Picture.Block.ImageSource=c(nearest).Icon;
            end
        end


        function windowMousePress(obj,e)
            if obj.View.isBusyClickingBlock()||obj.View.isBusyClickingCanvas()
                return;
            end
            obj.View.setBusyClickingCanvas(true);
            obj.isMousePressed=true;

            if~isvalid(obj)||~isvalid(obj.View)||~isvalid(obj.Figure)
                return;
            end

            c=obj.Cascade.Elements;
            if numel(c)<1
                return;
            end

            if~(obj.SelectIdx>0)
                obj.View.Parameters.ElementType='';
            end

            pt=obj.Figure.CurrentPoint;
            if obj.Layout.ScrollableViewportLocation(1)~=1

                pt(1)=pt(1)+obj.Layout.ScrollableViewportLocation(1)-1;
            end
            if obj.Layout.ScrollableViewportLocation(2)~=1

                pt(2)=pt(2)+obj.Layout.ScrollableViewportLocation(2)-1;
            end

            obj.updateChannelIndex();
            x=pt(1);
            y=pt(2);
            if obj.isInAxes(obj.AxesTx,x,y)

                if~obj.AxesTx.Title.Color(2)

                    obj.colorAxes(obj.ColorSelectedForeground,'k');
                    obj.addTxIBeam();
                    if obj.SelectedTxIndex>0&&obj.SelectedTxIndex~=obj.SelectIdx

                        if obj.SelectIdx>0
                            unselectElement(c(obj.SelectIdx));
                        end

                        obj.SelectIdx=obj.SelectedTxIndex;
                        obj.notify('ElementSelected',serdes.internal.apps.serdesdesigner.ElementSelectedEventData(obj.SelectIdx))
                    end
                    obj.View.enableInsertionActions(true);
                    for i=1:numel(obj.View.Toolstrip.AddButtons)

                        button=obj.View.Toolstrip.AddButtons(i);
                        button.Description=string(message('serdes:serdesdesigner:AddTxElement',obj.View.Toolstrip.getButtonName(button)));
                    end
                end
            elseif obj.isInAxes(obj.AxesRx,x,y)

                if~obj.AxesRx.Title.Color(2)

                    obj.colorAxes('k',obj.ColorSelectedForeground);
                    obj.addRxIBeam();
                    if obj.SelectedRxIndex>0&&obj.SelectedRxIndex+obj.ChannelIndex~=obj.SelectIdx

                        if obj.SelectIdx>0
                            unselectElement(c(obj.SelectIdx))
                        end

                        obj.SelectIdx=obj.SelectedRxIndex+obj.ChannelIndex;
                        obj.notify('ElementSelected',serdes.internal.apps.serdesdesigner.ElementSelectedEventData(obj.SelectIdx))
                    end
                    obj.View.enableInsertionActions(true);
                    for i=1:numel(obj.View.Toolstrip.AddButtons)

                        button=obj.View.Toolstrip.AddButtons(i);
                        button.Description=string(message('serdes:serdesdesigner:AddRxElement',obj.View.Toolstrip.getButtonName(button)));
                    end
                end
            elseif obj.AxesTx.Title.Color(3)||obj.AxesRx.Title.Color(3)

                obj.colorAxes('k','k');
                obj.removeIBeam();
                obj.InsertIdx=-1;
                obj.updateChannelIndex();
                if obj.ChannelIndex~=obj.SelectIdx

                    if obj.SelectIdx>0
                        unselectElement(c(obj.SelectIdx));
                    end

                    obj.SelectIdx=obj.ChannelIndex;
                    obj.notify('ElementSelected',serdes.internal.apps.serdesdesigner.ElementSelectedEventData(obj.SelectIdx));
                end
                obj.View.enableInsertionActions(false);
                for i=1:numel(obj.View.Toolstrip.AddButtons)

                    button=obj.View.Toolstrip.AddButtons(i);
                    button.Description=string(message('serdes:serdesdesigner:AddElement',obj.View.Toolstrip.getButtonName(button)));
                end
            elseif~(obj.SelectIdx>0)
                obj.updateChannelIndex();
                obj.SelectIdx=obj.ChannelIndex;
                obj.notify('ElementSelected',serdes.internal.apps.serdesdesigner.ElementSelectedEventData(obj.SelectIdx));
            end
            obj.adjustButtonsForScroll();
            obj.View.setBusyClickingCanvas(false);
        end


        function isInside=isInAxes(~,axes,x,y)
            isInside=x>=axes.Position(1)+12&&x<=axes.Position(1)+12+axes.Position(3)&&...
            y>=axes.Position(2)+10&&y<=axes.Position(2)+10+axes.Position(4);
        end
    end
end
