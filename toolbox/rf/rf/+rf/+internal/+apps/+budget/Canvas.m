classdef Canvas<handle







    properties(Hidden)

View

Figure

Panel


Labels

Cascade

Layout

Width

Height

SelectedElement
    end

    properties(Dependent)
X
Scrollbar
        ScrollbarValue double
ScrollbarVisibility
    end

    properties(Constant,Hidden)
        Spacing=20
        LineWidth=2*rf.internal.apps.budget.View.PixelRatio
    end

    properties(Dependent)

CanvasRowHeight
CanvasColumnWidth

CascadeRowHeight
CascadeColumnWidth
    end

    properties(Access=private)

        pCanvasRowHeight={'1x'};
        pCanvasColumnWidth={110,'10x'};

        pCascadeRowHeight={...
        '0.5x',...
        (rf.internal.apps.budget.ElementView.IconHeight-rf.internal.apps.budget.Canvas.LineWidth)/2,...
        rf.internal.apps.budget.Canvas.LineWidth,...
        (rf.internal.apps.budget.ElementView.IconHeight-rf.internal.apps.budget.Canvas.LineWidth)/2,...
        '4x',...
        '2x',...
        '2x',...
        '2x',...
        '2x'};
        pCascadeColumnWidth={...
        '1x',...
        50,...
        100,...
        rf.internal.apps.budget.IBeam.IBeamWidth,...
        100,...
        50,...
        '1x'};
    end

    properties(Hidden)
        HighlightIdx=[]
        SelectIdx=[]
        InsertIdx=1
    end

    properties(Constant)
        InputIcon=...
        imread([fullfile('+rf','+internal','+apps','+budget'),...
        filesep,...
        'input.png'])
        OutputIcon=...
        imread([fullfile('+rf','+internal','+apps','+budget'),...
        filesep,...
        'output.png'])
    end

    events(Hidden)
ElementSelected
    end

    methods

        function self=Canvas(parent)
            self.View=parent;
            self.Figure=self.View.CanvasFig;

            createCanvas(self)
            layoutCanvas(self)

            lis=self.View.Listeners;
            if self.View.UseAppContainer
                fig=self.Figure.Figure;
            else
                fig=self.Figure;
            end
            lis.WindowMousePress=addlistener(fig,...
            'WindowMousePress',@(~,e)windowMousePress(self,e));
            lis.WindowMouseMotion=addlistener(fig,...
            'WindowMouseMotion',@(~,e)windowMouseMotion(self,e));
            lis.WindowMouseRelease=addlistener(fig,...
            'WindowMouseRelease',@(~,~)windowMouseRelease(self));
            lis.SizeChanged=addlistener(fig,...
            'SizeChanged',@(~,~)sizeChanged(self));
            self.View.Listeners=lis;
        end

        function selectElement(self,ev,elem)
            self.SelectedElement=ev;
            selectElement(ev,elem);
        end

        function unselectElement(self,ev)
            self.SelectedElement=[];
            unselectElement(ev);
        end


        function x=get.X(self)
            c=self.Cascade.Elements;
            if self.View.UseAppContainer
                x=arrayfun(@(e)getpos(e),c);
            else
                x=arrayfun(@(e)e.Panel.Position(1),c);
            end
            function pos=getpos(e)
                position=getpixelposition(e.Layout);
                pos=position(1);
            end
        end

        function rtn=get.Scrollbar(self)
            if self.View.UseAppContainer
                rtn=self.Cascade.Layout;
            else
                rtn=self.Cascade.Layout.HorizontalScrollbar;
            end
        end

        function rtn=get.ScrollbarValue(self)
            if self.View.UseAppContainer
                rtn=self.Cascade.Layout.ScrollableViewportLocation(1);
            else
                rtn=self.Cascade.Layout.HorizontalScrollbar.Value;
            end
        end

        function rtn=get.ScrollbarVisibility(self)
            if self.View.UseAppContainer

                rtn=self.Cascade.Layout.ScrollableViewportLocation;
                if rtn(1)==1&&rtn(2)==1
                    rtn='off';
                else
                    rtn='on';
                end
            else
                rtn=self.Cascade.Layout.HorizontalScrollbar.Visible;
            end
        end

        function set.Scrollbar(self,newVal)
            if self.View.UseAppContainer
                self.Cascade.Layout=newVal;
            else
                self.Cascade.Layout.HorizontalScrollbar=newVal;
            end
        end

        function set.ScrollbarValue(self,newVal)
            if self.View.UseAppContainer
                self.Cascade.Layout.ScrollableViewportLocation(1)=newVal;
            else
                self.Cascade.Layout.HorizontalScrollbar.Value=newVal;
            end
        end

        function set.ScrollbarVisibility(self,newVal)
            if self.View.UseAppContainer
            else
                self.Cascade.Layout.HorizontalScrollbar.Visible=newVal;
            end
        end

        function set.CanvasRowHeight(self,newVal)
            self.Layout.RowHeight=newVal;
            refreshLayout(self);
        end

        function set.CanvasColumnWidth(self,newVal)
            self.Layout.ColumnWidth=newVal;
            refreshLayout(self);
        end

        function set.CascadeRowHeight(self,newVal)
            self.Cascade.Layout.RowHeight=newVal;
            refreshLayout(self);
        end

        function set.CascadeColumnWidth(self,newVal)
            self.Cascade.Layout.ColumnWidth=newVal;
            refreshLayout(self);
        end

        function rtn=get.CanvasRowHeight(self)
            rtn=self.pCanvasRowHeight;
        end

        function rtn=get.CanvasColumnWidth(self)
            rtn=self.pCanvasColumnWidth;
        end

        function rtn=get.CascadeRowHeight(self)
            rtn=self.pCascadeRowHeight;
        end

        function rtn=get.CascadeColumnWidth(self)
            rtn=self.pCascadeColumnWidth;
        end


        function createCanvas(self)



            if self.View.UseAppContainer
                self.Layout=uigridlayout(...
                'Parent',self.Figure.Figure,...
                'Scrollable','on',...
                'Tag','canvasLayout',...
                'RowSpacing',0,...
                'ColumnSpacing',0,...
                'RowHeight',self.pCanvasRowHeight,...
                'ColumnWidth',self.pCanvasColumnWidth);

                self.Labels=rf.internal.apps.budget.LabelsView(self,self.Layout);
            else
                self.Panel=uipanel(...
                'Tag','canvasPanel',...
                'Parent',self.Figure,...
                'Title','',...
                'BorderType','none',...
                'Visible','on');

                self.Labels=rf.internal.apps.budget.LabelsView(self,self.Panel);
            end
            createCascade(self)
        end

        function createCascade(self)






            if self.View.UseAppContainer

                self.Cascade.Layout=uigridlayout(...
                'Tag','canvasCascadeLayout',...
                'Parent',self.Layout,...
                'Scrollable','on',...
                'RowSpacing',0,...
                'Padding',[0,0,0,0],...
                'RowHeight',self.pCascadeRowHeight,...
                'ColumnWidth',self.pCascadeColumnWidth,...
                'BackgroundColor','w',...
                'ColumnSpacing',0);
                self.Cascade.Layout.Layout.Row=1;
                self.Cascade.Layout.Layout.Column=2;

                self.Cascade.Input=uiimage(...
                'Tag','canvasCascadeInputImage',...
                'Parent',self.Cascade.Layout,...
                'BackgroundColor','w',...
                'ImageSource',self.InputIcon(:,end-7:end,:),...
                'Visible','on',...
                'HorizontalAlignment','right');

                self.Cascade.Elements=...
                rf.internal.apps.budget.ElementView.empty;

                self.Cascade.IBeam=...
                rf.internal.apps.budget.IBeam(self.Cascade.Layout,...
                'UseAppContainer',self.View.UseAppContainer);

                self.Cascade.Output=uiimage(...
                'Tag','canvasCascadeOutputImage',...
                'Parent',self.Cascade.Layout,...
                'BackgroundColor','w',...
                'ImageSource',self.OutputIcon(:,1:8,:),...
                'Visible','on',...
                'HorizontalAlignment','left');

                self.Cascade.LineIn=uipanel(...
                'Tag','canvasCascadeLineInPanel',...
                'Parent',self.Cascade.Layout,...
                'ForegroundColor','k',...
                'BackgroundColor','k',...
                'BorderType','none',...
                'Visible','on');

                self.Cascade.LineOut=uipanel(...
                'Tag','canvasCascadeLineOutPanel',...
                'Parent',self.Cascade.Layout,...
                'ForegroundColor','k',...
                'BackgroundColor','k',...
                'BorderType','none',...
                'Visible','on');
            else

                self.Cascade.Panel=uipanel(...
                'Tag','canvasCascadePanel',...
                'Parent',self.Panel,...
                'Units','pixels',...
                'ForegroundColor','k',...
                'BackgroundColor','w',...
                'Title','',...
                'BorderType','line',...
                'HighlightColor','k',...
                'Visible','on');

                self.Cascade.Input=uicontrol(...
                self.Cascade.Panel,...
                'Style','checkbox',...
                'Tag','canvasCascadeInputCheckbox',...
                'Units','pixels',...
                'BackgroundColor','w',...
                'ForegroundColor','w',...
                'CData',self.InputIcon(:,end-7:end,:),...
                'Enable','inactive',...
                'Visible','on');

                self.Cascade.Elements=...
                rf.internal.apps.budget.ElementView.empty;

                self.Cascade.IBeam=...
                rf.internal.apps.budget.IBeam(self.Cascade.Panel,...
                'UseAppContainer',self.View.UseAppContainer);

                self.Cascade.Output=uicontrol(...
                self.Cascade.Panel,...
                'Style','checkbox',...
                'Tag','canvasCascadeOutputCheckbox',...
                'Units','pixels',...
                'BackgroundColor','w',...
                'ForegroundColor','w',...
                'CData',self.OutputIcon(:,1:8,:),...
                'Enable','inactive',...
                'Visible','on');

                self.Cascade.LineIn=uicontrol(...
                self.Cascade.Panel,...
                'Style','frame',...
                'Units','pixels',...
                'ForegroundColor','k',...
                'BackgroundColor','k',...
                'Visible','on');

                self.Cascade.LineOut=uicontrol(...
                self.Cascade.Panel,...
                'Style','frame',...
                'Units','pixels',...
                'ForegroundColor','k',...
                'BackgroundColor','k',...
                'Visible','on');
            end
        end


        function layoutCanvas(self)









            layoutCascade(self)

            verticalGap=rf.internal.apps.budget.Canvas.Spacing;
            leftInset=rf.internal.apps.budget.Canvas.Spacing/2;
            topInset=rf.internal.apps.budget.Canvas.Spacing;
            minimumHeight=...
            self.Labels.Height+...
            2*rf.internal.apps.budget.Canvas.Spacing+...
            8;

            if self.View.UseAppContainer
            else

                self.Layout=...
                matlabshared.application.layout.GridBagLayout(...
                self.Panel,...
                'VerticalGap',verticalGap,...
                'HorizontalGap',0,...
                'VerticalWeights',0,...
                'HorizontalWeights',[0,1]);

                add(...
                self.Layout,self.Labels.Panel,...
                1,1,...
                'LeftInset',leftInset,...
                'MinimumWidth',self.Labels.Width+2,...
                'MinimumHeight',minimumHeight,...
                'Anchor','North')

                add(...
                self.Layout,self.Cascade.Panel,...
                1,2,...
                'Fill','Horizontal',...
                'RightInset',verticalGap,...
                'MinimumWidth',self.Cascade.Width+2,...
                'MinimumHeight',minimumHeight,...
                'Anchor','North')

                [self.Width,self.Height]=getMinimumSize(self.Layout);

                setConstraints(...
                self.Layout,...
                1,1,...
                'MaximumHeight',self.Height-55);
                setConstraints(...
                self.Layout,...
                1,2,...
                'MaximumHeight',self.Height-55);
            end
        end

        function layoutCascade(self)






            topInset=rf.internal.apps.budget.Canvas.Spacing;
            leftInset=10;


            lineWidth=rf.internal.apps.budget.Canvas.Spacing/2+1;
            lineHeight=rf.internal.apps.budget.Canvas.LineWidth;
            lineInset=topInset-lineHeight+...
            (rf.internal.apps.budget.ElementView.IconHeight+2)/2;

            if self.View.UseAppContainer

                self.Cascade.Input.Layout.Row=[2,4];
                self.Cascade.Input.Layout.Column=2;

                self.Cascade.LineIn.Layout.Row=3;
                self.Cascade.LineIn.Layout.Column=3;

                self.Cascade.IBeam.Layout.Layout.Row=[2,4];
                self.Cascade.IBeam.Layout.Layout.Column=4;

                self.Cascade.LineOut.Layout.Row=3;
                self.Cascade.LineOut.Layout.Column=5;

                self.Cascade.Output.Layout.Row=[2,4];
                self.Cascade.Output.Layout.Column=6;

                self.Cascade.Width=700;
                self.Cascade.Height=700;
            else

                self.Cascade.Layout=...
                matlabshared.application.layout.ScrollableGridBagLayout(...
                self.Cascade.Panel,...
                'VerticalGap',0,...
                'HorizontalGap',0,...
                'HorizontalWeights',[1,0,0,0,1],...
                'VerticalWeights',0);

                add(...
                self.Cascade.Layout,self.Cascade.Input,1,1,...
                'TopInset',topInset,'LeftInset',leftInset,...
                'MinimumWidth',size(self.Cascade.Input.CData,2)+1,...
                'MinimumHeight',size(self.Cascade.Input.CData,1),...
                'Anchor','NorthEast')

                add(...
                self.Cascade.Layout,self.Cascade.LineIn,1,2,...
                'TopInset',lineInset,...
                'MinimumWidth',lineWidth-1,...
                'MinimumHeight',lineHeight,...
                'MaximumHeight',lineHeight,...
                'Anchor','North')

                add(...
                self.Cascade.Layout,self.Cascade.IBeam.Panel,1,3,...
                'TopInset',topInset-4,...
                'LeftInset',-4,...
                'RightInset',-6,...
                'MinimumWidth',self.Cascade.IBeam.Width+2,...
                'MinimumHeight',self.Cascade.IBeam.Height+2,...
                'Anchor','North')

                add(...
                self.Cascade.Layout,self.Cascade.LineOut,1,4,...
                'TopInset',lineInset,...
                'MinimumWidth',lineWidth-1,...
                'MinimumHeight',lineHeight,...
                'MaximumHeight',lineHeight,...
                'Anchor','North')

                add(...
                self.Cascade.Layout,self.Cascade.Output,1,5,...
                'TopInset',topInset,...
                'LeftInset',-1,...
                'MinimumWidth',size(self.Cascade.Output.CData,2)+1+1,...
                'MinimumHeight',size(self.Cascade.Output.CData,1),...
                'Anchor','NorthWest')

                [self.Cascade.Width,self.Cascade.Height]=...
                getMinimumSize(self.Cascade.Layout);
            end
        end

        function refreshLayout(self)


            layoutCanvas(self);
        end

        function scrollbarValueChanged(self)


            if self.View.UseAppContainer
                notify(self.Scrollbar,'ScrollableViewportLocationChanged');
            else
                notify(self.Scrollbar,'ValueChanged');
            end
        end
    end

    methods(Hidden)

        function adjustButtonsForScroll(self)








            if self.View.UseAppContainer
                scrollValue=self.ScrollbarValue;
                cp=getpixelposition(self.Cascade.Layout);
                cp(1)=1;
                ts=self.View.Toolstrip;
                ip=getpixelposition(self.Cascade.IBeam.Layout);
                if ip(1)<...
                    cp(1)+...
                    scrollValue||...
                    cp(1)+cp(3)...
                    +scrollValue<...
                    ip(1)+ip(3)
                    ts.ElementGallery.Enabled=false;
                else
                    ts.ElementGallery.Enabled=true;
                end
                if~isempty(self.SelectIdx)
                    ep=getpixelposition(self.Cascade.Elements(self.SelectIdx).Layout);
                    if ep(1)+ep(3)-10<=cp(1)+scrollValue||...
...
                        cp(1)+cp(3)+scrollValue<=ep(1)+10
                        ts.DeleteBtn.Enabled=false;
                    else
                        ts.DeleteBtn.Enabled=true;
                    end
                end
            else
                scrollValue=self.ScrollbarValue;
                cp=self.Cascade.Panel.Position;
                cp(1)=1;
                ts=self.View.Toolstrip;
                ip=self.Cascade.IBeam.Panel.Position;
                if ip(1)<...
                    cp(1)+...
                    scrollValue||...
                    cp(1)+cp(3)...
                    +scrollValue<...
                    ip(1)+ip(3)
                    ts.ElementGallery.Enabled=false;
                else
                    ts.ElementGallery.Enabled=true;
                end
                if~isempty(self.SelectIdx)
                    ep=self.Cascade.Elements(self.SelectIdx).Panel.Position;
                    if ep(1)+ep(3)-10<=cp(1)+scrollValue||...
...
                        cp(1)+cp(3)+scrollValue<=ep(1)+10
                        ts.DeleteBtn.Enabled=false;
                    else
                        ts.DeleteBtn.Enabled=true;
                    end
                end
            end
        end

        function sizeChanged(self)




            self.ScrollbarValue=0;
            scrollbarValueChanged(self)
            adjustButtonsForScroll(self)
        end
    end

    methods(Hidden)

        function removeIBeam(self)


            scrollValue=self.ScrollbarValue;
            self.Cascade.IBeam.Panel.Visible='off';
            idx=3*self.InsertIdx;
            if self.View.UseAppContainer
                rf.internal.apps.budget.remove(self.Cascade.Layout,'col',self.InsertIdx+3);
            else
                remove(self.Cascade.Layout,1,idx)
                lineWidth=rf.internal.apps.budget.Canvas.Spacing/2+1;
                clean(self.Cascade.Layout)
                self.Cascade.Layout.HorizontalWeights(end)=1;
            end
            self.InsertIdx=[];
            self.ScrollbarValue=scrollValue;
            scrollbarValueChanged(self)
        end

        function addIBeam(self,idx)





            scrollValue=self.ScrollbarValue;
            topInset=rf.internal.apps.budget.Canvas.Spacing;
            lineWidth=rf.internal.apps.budget.Canvas.Spacing/2+1;
            lineHeight=rf.internal.apps.budget.Canvas.LineWidth;
            lineInset=...
            topInset-lineHeight+...
            (rf.internal.apps.budget.ElementView.IconHeight+2)/2;

            if self.View.UseAppContainer
                if~isempty(self.Cascade.Elements)
                    if strcmpi(class(self.Cascade.Elements(1)),...
                        'rf.internal.apps.budget.AntennaViewRx')...
                        &&idx==1
                        idx=2;
                    end
                end
                rf.internal.apps.budget.insert(self.Cascade.Layout,'column',3+idx);
                self.Cascade.Layout.ColumnWidth{3+idx}=self.Cascade.IBeam.IBeamWidth;

                self.Cascade.IBeam.Layout.Parent=self.Cascade.Layout;
                self.Cascade.IBeam.Layout.Layout.Row=[2,4];
                self.Cascade.IBeam.Layout.Layout.Column=3+idx;
                self.Cascade.IBeam.Layout.Visible='on';



            else
                if~isempty(self.Cascade.Elements)
                    if strcmpi(class(self.Cascade.Elements(1)),...
                        'rf.internal.apps.budget.AntennaViewRx')...
                        &&idx==1
                        idx=2;
                    end
                end
                insert(self.Cascade.Layout,'column',3*idx)
                add(...
                self.Cascade.Layout,self.Cascade.IBeam.Panel,...
                1,3*idx,...
                'TopInset',topInset-4,...
                'LeftInset',-4,...
                'RightInset',-6,...
                'MinimumWidth',self.Cascade.IBeam.Width+2,...
                'MinimumHeight',self.Cascade.IBeam.Height+2,...
                'Anchor','NorthWest')




                remove(self.Cascade.Layout,1,3*idx-1)
                if idx==1
                    h=self.Cascade.LineIn;
                else
                    h=self.Cascade.Elements(idx-1).LineOut;
                end
                add(...
                self.Cascade.Layout,h,1,3*idx-1,...
                'TopInset',lineInset,...
                'MinimumWidth',lineWidth-1,...
                'MinimumHeight',lineHeight,...
                'MaximumHeight',lineHeight,...
                'Anchor','North')
                remove(self.Cascade.Layout,1,3*idx+1)
                if idx==numel(self.Cascade.Elements)+1
                    h=self.Cascade.LineOut;
                else
                    h=self.Cascade.Elements(idx).LineIn;
                end
                add(...
                self.Cascade.Layout,h,1,3*idx+1,...
                'TopInset',lineInset,...
                'MinimumWidth',lineWidth-1,...
                'MinimumHeight',lineHeight,...
                'MaximumHeight',lineHeight,...
                'Anchor','North')
                self.Cascade.IBeam.Panel.Visible='on';
            end
            self.InsertIdx=idx;
            self.ScrollbarValue=scrollValue;
            scrollbarValueChanged(self)
        end

        function deleteRemoveElementView(self,index)



            self.Cascade.Elements(index).delete
            self.Cascade.Elements(index)=[];
            if self.View.UseAppContainer
                removeIndex=3+index;
            else
                removeIndex=3*index;
            end
            if~self.Cascade.LineOut.Visible&&~self.Cascade.Output.Visible
                self.Cascade.Output.Visible='on';
                self.Cascade.LineOut.Visible='on';
                if self.View.UseAppContainer
                    rf.internal.apps.budget.remove(self.Cascade.Layout,'col',removeIndex);
                end
            elseif~self.Cascade.LineIn.Visible&&~self.Cascade.Input.Visible
                self.Cascade.Input.Visible='on';
                self.Cascade.LineIn.Visible='on';
                if self.View.UseAppContainer
                    rf.internal.apps.budget.remove(self.Cascade.Layout,'col',removeIndex);
                else
                    remove(self.Cascade.Layout,1,removeIndex+2)
                end
            else
                if self.View.UseAppContainer
                    rf.internal.apps.budget.remove(self.Cascade.Layout,'col',removeIndex);
                else
                    remove(self.Cascade.Layout,1,removeIndex+2)
                end
            end
            if self.View.UseAppContainer
            else
                remove(self.Cascade.Layout,1,removeIndex+1)
                remove(self.Cascade.Layout,1,removeIndex)
                clean(self.Cascade.Layout)
                self.Cascade.Layout.HorizontalWeights(end)=1;
            end
        end

        function deleteElement(self,budget,index)





            scrollBarWasVisible=...
            strcmp(self.ScrollbarVisibility,'on');
            removeIBeam(self)
            unselectElement(self,self.Cascade.Elements(index))
            self.Cascade.Elements(index).Visible='off';
            if self.View.UseAppContainer
                antennaHandle=[];
                Tx=0;
                Rx=0;
                TxRx=0;
                if isa(self.Cascade.Elements(self.SelectIdx),...
                    'rf.internal.apps.budget.AntennaView')
                    antennaHandle=self.View.Parameters.AntennaDialog.getAppHandle();
                    Tx=1;
                elseif isa(self.Cascade.Elements(self.SelectIdx),...
                    'rf.internal.apps.budget.AntennaViewRx')
                    antennaHandle=self.View.Parameters.AntennaDialogRx.getAppHandle();
                    Rx=1;
                elseif isa(self.Cascade.Elements(self.SelectIdx),...
                    'rf.internal.apps.budget.AntennaViewTxRx')
                    antennaHandle=self.View.Parameters.AntennaDialogTxRx.getAppHandle();
                    TxRx=1;
                end
                if~isempty(antennaHandle)&&~strcmpi(antennaHandle(1).App.AppContainer.State,'TERMINATED')
                    antennaHandle(1).App.AppContainer.close();
                    if Tx
                        self.View.Parameters.AntennaDialog.AppHandle=[];
                    elseif Rx
                        self.View.Parameters.AntennaDialogRx.AppHandle=[];
                    elseif TxRx
                        self.View.Parameters.AntennaDialogTxRx.AppHandleTx=[];
                        self.View.Parameters.AntennaDialogRxRx.AppHandleRx=[];
                    end
                    if numel(antennaHandle)==2
                        antennaHandle(2).App.AppContainer.close();
                    end
                end
            else
drawnow
            end
            deleteRemoveElementView(self,index)
            if numel(self.Cascade.Elements)>0
                self.SelectIdx=max(1,index-1);
                selectElement(self,self.Cascade.Elements(self.SelectIdx),...
                budget.Elements(self.SelectIdx))
                self.InsertIdx=self.SelectIdx+1;
                if isa(self.Cascade.Elements(end),...
                    'rf.internal.apps.budget.AntennaView')
                    self.Cascade.Output.Visible='off';
                    self.Cascade.LineOut.Visible='off';
                elseif isa(self.Cascade.Elements(1),'rf.internal.apps.budget.AntennaViewRx')
                    self.Cascade.Input.Visible='off';
                    self.Cascade.LineIn.Visible='off';
                end
                if isa(self.Cascade.Elements(self.SelectIdx),...
                    'rf.internal.apps.budget.AntennaView')
                    self.InsertIdx=1;
                elseif isa(self.Cascade.Elements(self.SelectIdx),'rf.internal.apps.budget.AntennaViewRx')
                    self.InsertIdx=2;
                end
                antennaHandle=[];
                if isa(self.Cascade.Elements(self.SelectIdx),...
                    'rf.internal.apps.budget.AntennaView')
                    antennaHandle=self.View.Parameters.AntennaDialog.getAppHandle();
                elseif isa(self.Cascade.Elements(self.SelectIdx),...
                    'rf.internal.apps.budget.AntennaViewRx')
                    antennaHandle=self.View.Parameters.AntennaDialogRx.getAppHandle();
                elseif isa(self.Cascade.Elements(self.SelectIdx),...
                    'rf.internal.apps.budget.AntennaViewTxRx')
                    antennaHandle=self.View.Parameters.AntennaDialogTxRx.getAppHandle();
                end
                if~isempty(antennaHandle)&&any(isvalid(antennaHandle))
                    antennaHandle(1).Model.CloseController.execute(antennaHandle(1));
                    if numel(antennaHandle)==2
                        antennaHandle(2).Model.CloseController.execute(antennaHandle(2));
                    end
                end
            else
                self.SelectIdx=[];
                self.InsertIdx=1;
            end
            addIBeam(self,self.InsertIdx)
            if scrollBarWasVisible
                if~strcmp(self.ScrollbarVisibility,'on')
                    self.ScrollbarValue=0;
                end
                scrollbarValueChanged(self)
            end
        end

        function deleteAllElements(self)

            n=numel(self.Cascade.Elements);
            if~n
                return
            end
            scrollBarWasVisible=...
            strcmp(self.ScrollbarVisibility,'on');
            removeIBeam(self)
            unselectElement(self,self.Cascade.Elements(self.SelectIdx))
            for index=n:-1:1
                self.Cascade.Elements(index).Visible='off';
                deleteRemoveElementView(self,index)
            end
            self.SelectIdx=[];
            self.InsertIdx=1;
            addIBeam(self,self.InsertIdx)
            if scrollBarWasVisible
                if~strcmp(self.ScrollbarVisibility,'on')
                    self.ScrollbarValue=0;
                end
                scrollbarValueChanged(self)
            end
        end

        function insertAddElementView(self,elem,index)



            if self.View.UseAppContainer
                element=class(elem);
                if strcmpi(element,'rfantenna')
                    if strcmpi(elem.Type,'Receiver')
                        element='receiver';
                    end
                end
                switch element
                case 'amplifier'
                    elemView=rf.internal.apps.budget.AmplifierView(self,...
                    self.Cascade.Layout);
                case 'modulator'
                    elemView=rf.internal.apps.budget.ModulatorView(elem,self,...
                    self.Cascade.Layout);
                case 'nport'
                    elemView=rf.internal.apps.budget.NportView(self,...
                    self.Cascade.Layout);
                case 'rfelement'
                    elemView=rf.internal.apps.budget.RFelementView(self,...
                    self.Cascade.Layout);
                case 'rffilter'
                    elemView=rf.internal.apps.budget.FilterView(elem,self,...
                    self.Cascade.Layout);
                case 'seriesRLC'
                    elemView=rf.internal.apps.budget.seriesRLCView(self,...
                    self.Cascade.Layout);
                case 'shuntRLC'
                    elemView=rf.internal.apps.budget.shuntRLCView(self,...
                    self.Cascade.Layout);
                case 'txlineMicrostrip'
                    if contains(class(elem),'txline')
                        elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                        self.Cascade.Layout);
                    end
                case 'rfantenna'
                    elemView=rf.internal.apps.budget.AntennaView(self,...
                    self.Cascade.Layout);
                case 'receiver'
                    elemView=rf.internal.apps.budget.AntennaViewRx(self,...
                    self.Cascade.Layout);
                case 'txlineCoaxial'
                    if contains(class(elem),'txline')
                        elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                        self.Cascade.Layout);
                    end
                case 'txlineCPW'
                    if contains(class(elem),'txline')
                        elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                        self.Cascade.Layout);
                    end
                case 'txlineParallelPlate'
                    if contains(class(elem),'txline')
                        elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                        self.Cascade.Layout);
                    end
                case 'txlineTwoWire'
                    if contains(class(elem),'txline')
                        elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                        self.Cascade.Layout);
                    end
                case 'txlineRLCGLine'
                    if contains(class(elem),'txline')
                        elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                        self.Cascade.Layout);
                    end
                case 'attenuator'
                    elemView=rf.internal.apps.budget.AttenuatorView(self,...
                    self.Cascade.Layout);
                case 'txlineEquationBased'
                    if contains(class(elem),'txline')
                        elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                        self.Cascade.Layout);
                    end
                case 'txlineDelayLossless'
                    elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                    self.Cascade.Layout);
                case 'txlineDelayLossy'
                    elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                    self.Cascade.Layout);
                case 'lcladder'
                    elemView=rf.internal.apps.budget.LCLadderView(elem,self,...
                    self.Cascade.Layout);
                case 'phaseshift'
                    elemView=rf.internal.apps.budget.PhaseshiftView(self,...
                    self.Cascade.Layout);
                case 'mixerIMT'
                    elemView=rf.internal.apps.budget.MixerIMTView(self,...
                    self.Cascade.Layout);
                case 'txlineStripline'
                    if contains(class(elem),'txline')
                        elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                        self.Cascade.Layout);
                    end
                case 'powerAmplifier'
                    elemView=rf.internal.apps.budget.PowerAmplifierView(self,...
                    self.Cascade.Layout);
                otherwise
                end
            else
                switch class(elem)
                case 'amplifier'
                    elemView=rf.internal.apps.budget.AmplifierView(self,...
                    self.Cascade.Panel);
                case 'modulator'
                    elemView=rf.internal.apps.budget.ModulatorView(elem,self,...
                    self.Cascade.Panel);
                case 'nport'
                    elemView=rf.internal.apps.budget.NportView(self,...
                    self.Cascade.Panel);
                case 'rfelement'
                    elemView=rf.internal.apps.budget.RFelementView(self,...
                    self.Cascade.Panel);
                case 'rffilter'
                    elemView=rf.internal.apps.budget.FilterView(elem,self,...
                    self.Cascade.Panel);
                case 'seriesRLC'
                    elemView=rf.internal.apps.budget.seriesRLCView(self,...
                    self.Cascade.Panel);
                case 'shuntRLC'
                    elemView=rf.internal.apps.budget.shuntRLCView(self,...
                    self.Cascade.Panel);
                case 'txlineMicrostrip'
                    if contains(class(elem),'txline')
                        elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                        self.Cascade.Panel);
                    end
                case 'rfantenna'
                    elemView=rf.internal.apps.budget.AntennaView(self,...
                    self.Cascade.Panel);
                    if strcmpi(elem.Type,'Receiver')
                        elemView=rf.internal.apps.budget.AntennaViewRx(self,...
                        self.Cascade.Panel);
                    elseif strcmpi(elem.Type,'TransmitReceive')
                        elemView=rf.internal.apps.budget.AntennaViewTxRx(self,...
                        self.Cascade.Panel);
                    end
                case 'txlineCoaxial'
                    if contains(class(elem),'txline')
                        elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                        self.Cascade.Panel);
                    end
                case 'txlineCPW'
                    if contains(class(elem),'txline')
                        elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                        self.Cascade.Panel);
                    end
                case 'txlineParallelPlate'
                    if contains(class(elem),'txline')
                        elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                        self.Cascade.Panel);
                    end
                case 'txlineTwoWire'
                    if contains(class(elem),'txline')
                        elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                        self.Cascade.Panel);
                    end
                case 'txlineRLCGLine'
                    if contains(class(elem),'txline')
                        elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                        self.Cascade.Panel);
                    end
                case 'attenuator'
                    elemView=rf.internal.apps.budget.AttenuatorView(self,...
                    self.Cascade.Panel);
                case 'txlineEquationBased'
                    if contains(class(elem),'txline')
                        elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                        self.Cascade.Panel);
                    end
                case 'txlineDelayLossless'
                    elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                    self.Cascade.Panel);
                case 'txlineDelayLossy'
                    elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                    self.Cascade.Panel);

                case 'lcladder'
                    elemView=rf.internal.apps.budget.LCLadderView(elem,self,...
                    self.Cascade.Panel);
                case 'phaseshift'
                    elemView=rf.internal.apps.budget.PhaseshiftView(self,...
                    self.Cascade.Panel);
                case 'mixerIMT'
                    elemView=rf.internal.apps.budget.MixerIMTView(self,...
                    self.Cascade.Panel);
                case 'txlineStripline'
                    if contains(class(elem),'txline')
                        elemView=rf.internal.apps.budget.TxlineView(elem,self,...
                        self.Cascade.Panel);
                    end
                case 'powerAmplifier'
                    elemView=rf.internal.apps.budget.PowerAmplifierView(self,...
                    self.Cascade.Panel);

                otherwise
                end
            end
            self.Cascade.Elements=...
            [self.Cascade.Elements(1:index-1),...
            elemView,...
            self.Cascade.Elements(index:end)];

            topInset=rf.internal.apps.budget.Canvas.Spacing;
            lineWidth=rf.internal.apps.budget.Canvas.Spacing/2+1;
            lineHeight=rf.internal.apps.budget.Canvas.LineWidth;
            lineInset=topInset-lineHeight+...
            (rf.internal.apps.budget.ElementView.IconHeight+2)/2;
            layoutIdx=3*index;
            if self.View.UseAppContainer

            else
                insert(self.Cascade.Layout,'column',layoutIdx)
                insert(self.Cascade.Layout,'column',layoutIdx+1)
                insert(self.Cascade.Layout,'column',layoutIdx+2)
                add(...
                self.Cascade.Layout,elemView.Panel,1,layoutIdx+1,...
                'TopInset',topInset-5,...
                'LeftInset',-1,...
                'RightInset',-5,...
                'MinimumWidth',elemView.Width+2,...
                'MinimumHeight',elemView.Height+2,...
                'Anchor','North')




                setConstraints(...
                self.Cascade.Layout,1,layoutIdx-1,...
                'MinimumWidth',lineWidth)
                add(...
                self.Cascade.Layout,elemView.LineIn,1,layoutIdx,...
                'TopInset',lineInset,...
                'MinimumWidth',lineWidth,...
                'MinimumHeight',lineHeight,...
                'MaximumHeight',lineHeight,...
                'Anchor','North')
            end


            if strcmpi(class(elemView),'rf.internal.apps.budget.AntennaView')
                if self.View.UseAppContainer

                else
                    add(self.Cascade.Layout,elemView.LineIn,1,layoutIdx,...
                    'TopInset',lineInset,...
                    'MinimumWidth',lineWidth,...
                    'MinimumHeight',lineHeight,...
                    'MaximumHeight',lineHeight,...
                    'Anchor','North')
                end
                if~isempty(self.View.Parameters.AntennaDialog)
                    if self.View.UseAppContainer
                        rf.internal.apps.budget.setValue(self,...
                        self.View.Parameters.AntennaDialog,'TypePopup','Isotropic Radiator')
                    else
                        self.View.Parameters.AntennaDialog.TypePopup.Value=1;
                    end
                end
                self.Cascade.LineOut.Visible='off';
                self.Cascade.Output.Visible='off';
                self.Cascade.IBeam.Panel.Visible='off';
            elseif strcmpi(class(elemView),'rf.internal.apps.budget.AntennaViewRx')
                if~isempty(self.View.Parameters.AntennaDialogRx)
                    if self.View.UseAppContainer
                        rf.internal.apps.budget.setValue(self,...
                        self.View.Parameters.AntennaDialogRx,'TypePopup','Isotropic Receiver')
                    else
                        self.View.Parameters.AntennaDialogRx.TypePopup.Value=1;
                    end
                end
                self.Cascade.LineIn.Visible='off';
                self.Cascade.Input.Visible='off';
                self.Cascade.IBeam.Panel.Visible='off';
                if self.View.UseAppContainer

                else
                    add(self.Cascade.Layout,elemView.LineOut,1,layoutIdx+2,...
                    'TopInset',lineInset,...
                    'MinimumWidth',lineWidth-1,...
                    'MinimumHeight',lineHeight,...
                    'MaximumHeight',lineHeight,...
                    'Anchor','North')
                end
            elseif strcmpi(class(elemView),'rf.internal.apps.budget.AntennaViewTxRx')
                if~isempty(self.View.Parameters.AntennaDialogTxRx)
                    if self.View.UseAppContainer
                        rf.internal.apps.budget.setValue(self,...
                        self.View.Parameters.AntennaDialogTxRx,'TypePopupRx','Isotropic Receiver')
                        rf.internal.apps.budget.setValue(self,...
                        self.View.Parameters.AntennaDialogTxRx,'TypePopupTx','Isotropic Radiator')
                    else
                        self.View.Parameters.AntennaDialogTxRx.TypePopupRx.Value=1;
                        self.View.Parameters.AntennaDialogTxRx.TypePopupTx.Value=1;
                    end
                end
                add(...
                self.Cascade.Layout,elemView.LineOut,1,layoutIdx+2,...
                'TopInset',lineInset,...
                'MinimumWidth',lineWidth-1,...
                'MinimumHeight',lineHeight,...
                'MaximumHeight',lineHeight,...
                'Anchor','North')
            else
                if self.View.UseAppContainer

                else
                    add(...
                    self.Cascade.Layout,elemView.LineOut,1,layoutIdx+2,...
                    'TopInset',lineInset,...
                    'MinimumWidth',lineWidth-1,...
                    'MinimumHeight',lineHeight,...
                    'MaximumHeight',lineHeight,...
                    'Anchor','North')
                end
            end
        end

        function insertElement(self,budget,index)

            if~isempty(self.SelectIdx)
                unselectElement(self,self.Cascade.Elements(self.SelectIdx))
            end
            insertAddElementView(self,budget.Elements(index),index);


            if strcmp(self.ScrollbarVisibility,'on')
                c=self.Cascade.Elements;
                xi=arrayfun(@(p)p.Position(1)+p.Position(3),[c.LineOut]);
                xi=[c(1).LineIn.Position(1),xi];
                scrollValue=self.ScrollbarValue;
                width=rf.internal.apps.budget.ElementView.TextWidth+...
                rf.internal.apps.budget.Canvas.Spacing;
                if 1+scrollValue<=xi(index)-width


                    self.ScrollbarValue=...
                    xi(index);
                end
                scrollbarValueChanged(self)
            end

            if~self.View.UseAppContainer

drawnow
            end
            self.Cascade.Elements(index).Visible='on';
            self.SelectIdx=index;
            selectElement(self,self.Cascade.Elements(self.SelectIdx),...
            budget.Elements(self.SelectIdx))
            self.InsertIdx=self.SelectIdx+1;
            if strcmpi(class(self.Cascade.Elements(index)),'rf.internal.apps.budget.AntennaView')
                self.Cascade.Elements(index).LineOut.Visible='off';
                removeIBeam(self);
                addIBeam(self,index)
            elseif strcmpi(class(self.Cascade.Elements(index)),'rf.internal.apps.budget.AntennaViewRx')
                self.Cascade.Elements(index).LineIn.Visible='off';
                removeIBeam(self);
                index=index+1;
                addIBeam(self,index)
            end

        end

        function insertAllElements(self,budget)
            n=numel(budget.Elements);
            if n==0
                return
            end
            if~isempty(self.SelectIdx)
                unselectElement(self,self.Cascade.Elements(self.SelectIdx))
            end

            for index=1:n
                self.InsertIdx=index;
                insertAddElementView(self,budget.Elements(index),index);
                self.Cascade.Elements(index).Visible='on';
                if isa(budget.Elements(index),'rfantenna')
                    if strcmpi(budget.Elements(index).Type,'Transmitter')
                        self.Cascade.Elements(index).LineOut.Visible='off';
                    elseif strcmpi(budget.Elements(index).Type,'Receiver')
                        self.Cascade.Elements(index).LineIn.Visible='off';
                        self.Cascade.IBeam.Panel.Visible='on';
                    end
                end
            end
            self.SelectIdx=1;
            selectElement(self,self.Cascade.Elements(1),budget.Elements(1))
            self.InsertIdx=n+1;
            if self.View.UseAppContainer
                LayoutPanel='Layout';
            else
                LayoutPanel='Panel';
            end
            if~self.Cascade.IBeam.(LayoutPanel).Visible
                removeIBeam(self)
                addIBeam(self,1)
            end
            if strcmp(self.ScrollbarVisibility,'on')

                if self.View.UseAppContainer
                else
                    self.ScrollbarValue=...
                    self.Cascade.Layout.HorizontalScrollbar.Maximum;
                end
                scrollbarValueChanged(self)
            end
        end
    end

    methods(Access=private)

        function[offCanvas,pt,cp]=earlyExit(self)








            if self.View.UseAppContainer
                fig=self.Figure.Figure;
            else
                fig=self.Figure;
            end

            pt=fig.CurrentPoint;
            if self.View.UseAppContainer
                cp=getpixelposition(self.Cascade.Layout);
            else
                cp=self.Cascade.Panel.Position;
            end
            if pt(1)<cp(1)||cp(1)+cp(3)<...
                pt(1)||pt(2)<...
                cp(2)||cp(2)+cp(4)<pt(2)
                offCanvas=true;
            else
                offCanvas=false;
            end
            pt=pt-cp(1:2);
            pt(1)=pt(1)+self.ScrollbarValue;
        end

        function windowMouseMotion(self,e)



            if self.View.UseAppContainer
                fig=self.Figure.Figure;
            else
                fig=self.Figure;
            end

            if~isvalid(self)||...
                ~isvalid(self.View)||...
                ~isvalid(fig)
                return
            end

            fig.CurrentPoint=e.Point;
            [offCanvas,pt]=earlyExit(self);
            c=self.Cascade.Elements;

            if~isempty(self.HighlightIdx)

                if self.HighlightIdx~=self.SelectIdx
                    if self.View.UseAppContainer
                        c(self.HighlightIdx).Picture.Block.ImageSource=...
                        c(self.HighlightIdx).Icon;
                    else
                        c(self.HighlightIdx).Picture.Block.CData=...
                        c(self.HighlightIdx).Icon;
                    end
                    self.HighlightIdx=[];
                end
            end
            if offCanvas||...
                numel(c)<2
                return
            end
            if self.View.UseAppContainer
                ep=getpixelposition(c(1).Layout);
            else
                ep=c(1).Panel.Position;
            end

            if pt(2)<...
                ep(2)||...
                ep(2)+ep(4)<...
                pt(2)
                return
            end

            if self.View.UseAppContainer
                pos=getpixelposition(c(1).Layout);
                xc=self.X+pos(3)/2;
            else
                xc=self.X+c(1).Panel.Position(3)/2;
            end
            [~,nearest]=min(abs(xc-pt(1)));
            if nearest==self.SelectIdx
                return
            end

            if self.View.UseAppContainer
                ep=getpixelposition(c(nearest).Layout);
                if ep(1)<=pt(1)&&pt(1)<=ep(1)+ep(3)
                    c(nearest).Picture.Block.ImageSource=...
                    highlight(c(nearest),3,[180,180,180]./255);
                    self.HighlightIdx=nearest;
                else
                    c(nearest).Picture.Block.ImageSource=c(nearest).Icon;
                end
            else
                ep=c(nearest).Panel.Position;
                if ep(1)<=pt(1)&&pt(1)<=ep(1)+ep(3)
                    c(nearest).Picture.Block.CData=...
                    highlight(c(nearest),3,[180,180,180]./255);
                    self.HighlightIdx=nearest;
                else
                    c(nearest).Picture.Block.CData=c(nearest).Icon;
                end
            end
        end

        function windowMousePress(self,e)



            if self.View.UseAppContainer
                fig=self.Figure.Figure;
            else
                fig=self.Figure;
            end

            if~isvalid(self)||...
                ~isvalid(self.View)||...
                ~isvalid(fig)
                return
            end

            fig.CurrentPoint=e.Point;
            [offCanvas,pt,cp]=earlyExit(self);
            c=self.Cascade.Elements;
            if offCanvas||...
                numel(c)<...
1
                return
            end
            if self.View.UseAppContainer
                ep=getpixelposition(c(1).Picture.Layout);
            else
                ep=c(1).Panel.Position;
            end









            if self.View.UseAppContainer
                pos=getpixelposition(c(1).Picture.Layout);
                xc=self.X+pos(3)/2;
            else
                xc=self.X+c(1).Panel.Position(3)/2;
            end
            [~,nearest]=min(abs(xc-pt(1)));
            if self.View.UseAppContainer
                ep=getpixelposition(c(nearest).Layout);
            else
                ep=c(nearest).Panel.Position;
            end
            if ep(1)<=pt(1)&&pt(1)<=ep(1)+ep(3)
                if nearest~=self.SelectIdx
                    unselectElement(self,c(self.SelectIdx))
                    self.SelectIdx=nearest;
                    self.notify('ElementSelected',...
                    rf.internal.apps.budget.ElementSelectedEventData(nearest))
                end
                if~self.View.UseAppContainer
                    return
                end
            end



            xi=arrayfun(@(p)p.Position(1)+p.Position(3),[c.LineOut]);
            xi=[c(1).LineIn.Position(1),xi];
            [~,nearest]=min(abs(xi-pt(1)));
            scrollValue=self.ScrollbarValue;
            if self.View.UseAppContainer

                elementPositions=cell2mat(cellfun(@(x)getpixelposition(x),...
                arrayfun(@(x)x,[c.Layout],...
                'UniformOutput',false),...
                'UniformOutput',false));
                elementPositions=reshape(elementPositions,4,length(c));
                elementPositions=elementPositions';
                xPosition=elementPositions(:,1);

                [~,nearest]=min(abs(xPosition-pt(1)));
                if xPosition(end)+80<pt(1)
                    nearest=nearest+1;
                end
                if pt(1)>xPosition(self.SelectIdx)&&pt(1)<(xPosition(self.SelectIdx)+60)
                    return;
                end
                if nearest~=self.InsertIdx
                    removeIBeam(self)
                    addIBeam(self,nearest)
                end
            else
                if nearest~=self.InsertIdx&&...
                    1+scrollValue<=xi(nearest)&&...
                    xi(nearest)<=cp(3)-1+scrollValue
                    removeIBeam(self)
                    addIBeam(self,nearest)
                end
            end
        end

        function windowMouseRelease(self)


            if self.View.UseAppContainer
                fig=self.Figure.Figure;
            else
                fig=self.Figure;
            end


            if~isvalid(self)||...
                ~isvalid(self.View)||...
                ~isvalid(fig)
                return
            end
            adjustButtonsForScroll(self)
        end
    end
end







