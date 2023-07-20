classdef View<handle







    properties(Hidden)
Toolstrip
DocumentGroup
ParametersFig
Parameters
CanvasFig
Canvas
ResultsFig
Results
Listeners
PlotsFig
CurrentFigureHandle
        NumElements=0;
CompositePlotHdl
UseAppContainer
PlotCounter
    end

    properties(Dependent)
ActiveLayout
AppState
    end

    properties(Constant,Hidden)
        PPSS=get(0,'ScreenSize')
        DPSS=ismac*rf.internal.apps.budget.View.PPSS+...
        ~ismac*matlab.ui.internal.PositionUtils.getDevicePixelScreenSize
        PixelRatio=...
        rf.internal.apps.budget.View.DPSS(4)/rf.internal.apps.budget.View.PPSS(4)
        AppSize=[1366,768]*rf.internal.apps.budget.View.PixelRatio
    end

    events(Hidden)
InsertionRequested
DeletionRequested
    end

    methods

        function self=View(varargin)






            import matlab.ui.internal.*;

            s=settings;
            parser=inputParser;
            parser.addOptional('Name','',@ischar);
            parser.addParameter('Budget',rfbudget,@(x)isa(x,'rfbudget'));
            parser.addParameter('UseAppContainer',s.rf.Decaf.ActiveValue,@islogical);
            if mod(nargin,2)
                parse(parser,varargin{:});
            else
                parse(parser,'',varargin{:});
            end
            self.UseAppContainer=parser.Results.UseAppContainer;
            self.Toolstrip=rf.internal.apps.budget.Toolstrip('UseAppContainer',parser.Results.UseAppContainer);
            enableActions(self,false);
            if self.UseAppContainer

                self.DocumentGroup=FigureDocumentGroup('Tag','figureGroup');
                add(self.Toolstrip.AppContainer,self.DocumentGroup);

                self.ParametersFig=FigurePanel(...
                'Title','Element Parameters',...
                'Tag','parametersPanel');
                add(self.Toolstrip.AppContainer,self.ParametersFig);
                self.ParametersFig.Figure.AutoResizeChildren='off';

                self.CanvasFig=FigureDocument(...
                'Tag','canvasFigureDocument',...
                'Title','',...
                'DocumentGroupTag','figureGroup',...
                'Phantom',false,...
                'CanCloseFcn',@(h,e)delete(self),...
                'Tile',1,...
                'Closable',false);
                add(self.Toolstrip.AppContainer,self.CanvasFig);
                self.CanvasFig.Figure.AutoResizeChildren='off';

                self.ResultsFig=FigureDocument(...
                'Title','Results',...
                'Tag','resultsFigureDocument',...
                'DocumentGroupTag','figureGroup',...
                'Phantom',false,...
                'CanCloseFcn',@(h,e)delete(self),...
                'Tile',2,...
                'Closable',false);
                add(self.Toolstrip.AppContainer,self.ResultsFig);
                self.ResultsFig.Figure.AutoResizeChildren='off';
            else

                self.ParametersFig=figure(...
                'Name','Element Parameters',...
                'Tag','ParametersFig',...
                'NumberTitle','off',...
                'IntegerHandle','off',...
                'WindowKeyPressFcn',@(varargin)[],...
                'HandleVisibility','callback',...
                'Units','pixels',...
                'Visible','on',...
                'DeleteFcn',@(h,e)delete(self));
                self.Toolstrip.ToolGroup.addFigure(self.ParametersFig);

                self.CanvasFig=figure(...
                'Name','',...
                'NumberTitle','off',...
                'IntegerHandle','off',...
                'WindowKeyPressFcn',@(varargin)[],...
                'HandleVisibility','off',...
                'Units','pixels',...
                'Visible','on',...
                'Menubar','none',...
                'DeleteFcn',@(h,e)delete(self));
                self.Toolstrip.ToolGroup.addFigure(self.CanvasFig);

                self.ResultsFig=figure(...
                'Name','Results',...
                'NumberTitle','off',...
                'IntegerHandle','off',...
                'WindowKeyPressFcn',@(varargin)[],...
                'HandleVisibility','off',...
                'Units','pixels',...
                'Visible','on',...
                'Menubar','none',...
                'DeleteFcn',@(h,e)delete(self));
                self.Toolstrip.ToolGroup.addFigure(self.ResultsFig);
            end

            self.Parameters=rf.internal.apps.budget.Parameters(self);

            self.Canvas=rf.internal.apps.budget.Canvas(self);

            self.Results=rf.internal.apps.budget.ResultsView(self);

            disableDeleteOnTabbedFigures(self,self.ParametersFig);
            disableDeleteOnTabbedFigures(self,self.CanvasFig);
            disableDeleteOnTabbedFigures(self,self.ResultsFig);

            minWidth=...
            self.Parameters.SystemDialog.Width+...
            self.Canvas.Width+...
            rf.internal.apps.budget.ElementView.IconWidth+2;
            if self.UseAppContainer
            else
                md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                frame=md.getFrameContainingGroup(self.Toolstrip.ToolGroup.Name);
                frame.setMinimumSize(java.awt.Dimension(...
                minWidth,rf.internal.apps.budget.View.AppSize(2)))
            end

            newView(self,parser.Results.Name,parser.Results.Budget,false)
            if self.UseAppContainer
            else
                self.ParametersFig.Visible='on';
                self.CanvasFig.Visible='on';
            end
        end

        function rtn=get.ActiveLayout(self)
            matlab.internal.yield;
            rtn=self.Parameters.ElementDialog.Layout;
        end

        function rtn=get.AppState(self)
            if~isempty(self.Toolstrip)
                rtn=self.Toolstrip.AppContainer.State;
            else
                rtn=matlab.ui.container.internal.appcontainer.AppState.INITIALIZING;
            end
        end

        function varargout=delete(self,varargin)

            if self.UseAppContainer
                varargout{1}=true;
            else
                if~isempty(self.Toolstrip.ToolGroup)&&...
                    isvalid(self.Toolstrip.ToolGroup)
                    self.Toolstrip.ToolGroup.setClosingApprovalNeeded(false);
                    self.Toolstrip.ToolGroup.approveClose();
                    self.Toolstrip.ToolGroup.close();
                    drawnow;
                    delete(self.Toolstrip.ToolGroup);
                end
            end
        end
    end

    methods(Hidden)

        function newName(self,name)

            if self.UseAppContainer
                self.CanvasFig.Title=name;
            else
                self.CanvasFig.Name=name;
            end
        end

        function newBudget(self,budget)


            deleteAllElements(self.Canvas)
            insertAllElements(self.Canvas,budget)









        end

        function updateCascadeText(self,budget)



            len=numel(budget.Elements);
            dlg=self.Parameters.SystemDialog;
            for i=1:len
                ev=self.Canvas.Cascade.Elements(i);
                if self.UseAppContainer
                    valueString='Value';
                    textString='Text';
                else
                    valueString='String';
                    textString='String';
                    shrinkNameAsNeeded(ev.Picture.Name,ev.Picture.Width)
                end
                ev.StageText.ID.(textString)=sprintf('%d',i);
                ev.Picture.Name.(textString)=budget.Elements(i).Name;
                ev.StageText.Gain.(textString)=...
                sprintf('%.4g',budget.StageAvailableGain(i));
                ev.StageText.NF.(textString)=sprintf('%.4g',budget.StageNF(i));
                ev.StageText.OIP3.(textString)=sprintf('%.4g',budget.StageOIP3(i));




            end
        end

        function hideCascadeText(self,flag)


            len=numel(self.Canvas.Cascade.Elements);
            for i=1:len
                ev=self.Canvas.Cascade.Elements(i);
                if self.UseAppContainer
                    if strcmp(flag,'inactive')
                        ev.StageText.Gain.Enable='on';
                        ev.StageText.NF.Enable='on';
                        ev.StageText.OIP3.Enable='on';
                        ev.StageText.OIP2.Enable='on';
                    else
                        ev.StageText.Gain.Enable=flag;
                        ev.StageText.NF.Enable=flag;
                        ev.StageText.OIP3.Enable=flag;
                        ev.StageText.OIP2.Enable=flag;
                    end
                else
                    ev.StageText.Gain.Enable=flag;
                    ev.StageText.NF.Enable=flag;
                    ev.StageText.OIP3.Enable=flag;
                    ev.StageText.OIP2.Enable=flag;
                end
            end
        end

        function newView(self,name,budget,enable)






            if nargin<4
                enable=true;
            end

            self.NumElements=numel(budget.Elements);

            newName(self,name)

            enableActions(self,false)

            newBudget(self,budget)
            dlg=self.Toolstrip.SystemParameters;
            if~isempty(budget.InputFrequency)
                dlg.InputFrequency=budget.InputFrequency;
            end
            if~isempty(budget.AvailableInputPower)
                dlg.AvailableInputPower=budget.AvailableInputPower;
            end
            if~isempty(budget.SignalBandwidth)
                dlg.SignalBandwidth=budget.SignalBandwidth;
            end
            self.hideFigures();
            self.Toolstrip.PlotBandwidth=budget.SignalBandwidth;
            self.Toolstrip.PlotResolution=51;
            updateCascadeText(self,budget);
            if budget.AutoUpdate&&strcmpi(budget.Solver,'HarmonicBalance')
                self.Toolstrip.AutoUpdateCheckbox.Value=true;
            else
                self.Toolstrip.AutoUpdateCheckbox.Value=false;
            end
            updateResultsTable(self.Results,budget);
            self.Toolstrip.AutoUpdateCheckbox.Value=budget.AutoUpdate;
            if enable&&~isempty(budget.InputFrequency)&&...
                ~isempty(budget.AvailableInputPower)&&...
                ~isempty(budget.SignalBandwidth)

                enableActions(self,true)
                if self.NumElements~=0
                    if isa(budget.Elements(1),'rfantenna')
                        if strcmpi(budget.Elements(1).Type,'Receiver')
                            enableInputPower(self.Toolstrip,false)
                        else
                            enableInputPower(self.Toolstrip,true)
                        end
                    end
                end
            end
        end

        function updatePlots(self,budget,varargin)


            updateOnly3DPlots=0;
            if~isempty(varargin)&&varargin{1}
                updateOnly3DPlots=1;
            end
            warning('off','rf:shared:InputPower')
            tmpbudget2D=clone(budget);
            tmpbudget3D=clone(budget);
            warning('on','rf:shared:InputPower')
            tmpbudget3D.Solver='Friis';
            InFreq=budget.InputFrequency;
            BW=self.Toolstrip.PlotBandwidth;
            Res=self.Toolstrip.PlotResolution;
            tmpbudget3D.InputFrequency=linspace(InFreq-BW/2,InFreq+BW/2,Res);
            computeBudget(tmpbudget3D);
            setStatusBarMsg(self,'Updating Plots...')
            dlg=self.Parameters.SystemDialog;
            if~isempty(self.PlotsFig)
                plotstype=fields(self.PlotsFig);
            else
                plotstype=[];
            end
            for j=1:numel(plotstype)
                analysisplots=fields(self.PlotsFig.(plotstype{j}));
                for k=1:numel(analysisplots)
                    if strcmpi(analysisplots{k},'Args')
                        continue;
                    end
                    if any(strcmpi(analysisplots{k},...
                        {'Output_Second_Order_Intercept',...
                        'Output_Second_Order_Intercept_2D',...
                        'Input_Second_Order_Intercept_2D',...
                        'Input_Second_Order_Intercept',...
                        'OIP2_2D','IIP2_2D'}))&&...
                        strcmpi(budget.Solver,'Friis')
                        continue;
                    end
                    try
                        f=self.PlotsFig.(plotstype{j}).(analysisplots{k});
                        if self.UseAppContainer
                            f=f.Figure;
                        end
                        dim2=strsplit(analysisplots{k},'_');
                        dim2=strcmpi(dim2{end},'2D');
                    catch
                        f=[];
                    end
                    if~isempty(f)
                        if isvalid(f)&&~isempty(budget.Elements)
                            f.HandleVisibility='on';
                            g=groot;
                            g.CurrentFigure=f;
                            if strcmpi(plotstype(j),'Plots')
                                ax=findobj(f,'Type','axes');
                                if dim2
                                    if updateOnly3DPlots
                                        continue;
                                    end
                                    cla(ax);
                                    tailstr=' - 2D';
                                    budgetval=tmpbudget2D;
                                    rfplot(budgetval,...
                                    self.PlotsFig.(plotstype{j}).Args.(analysisplots{k}){2:end},...
                                    'Resolution',1);
                                else
                                    cla(ax);
                                    Res=1;
                                    budgetval=tmpbudget3D;
                                    tailstr=' - 3D';
                                    rfplot(budgetval,...
                                    self.PlotsFig.(plotstype{j}).Args.(analysisplots{k}){2:end});
                                end
                                if strcmpi(f.Name,'Sparameters')
                                    if strcmpi(analysisplots{k},'Sparameters')
                                        f.Name=['Sparameters','21'];
                                    else
                                        f.Name=analysisplots{k};
                                    end
                                end
                                f.Name=[f.Name,tailstr];
                                axtoolbar(ax,...
                                {'export','datacursor','rotate',...
                                'zoomin','zoomout','restoreview'});
                            elseif strcmpi(plotstype(j),'SParameterPlots')
                                cp=self.CompositePlotHdl;
                                cp.Budget=tmpbudget3D;
                                cp.generatePlot();
                                setAxesToolbar(cp);
                            end
                            f.HandleVisibility='off';
                        end
                    end
                end
            end

            setStatusBarMsg(self,'');
        end

        function addPlotFigure(self,budget,items,useString,Dim2)



            enableActions(self,false)
            warning('off','rf:shared:InputPower')
            budget=clone(budget);
            warning('on','rf:shared:InputPower')
            tagval=items.Tag;
            setStatusBarMsg(self,['Adding ',tagval,' plot']);
            if any(strcmpi(tagval,...
                {'Output Second-Order Intercept',...
                'Output Second-Order Intercept - 2D',...
                'Input Second-Order Intercept',...
                'Input Second-Order Intercept - 2D'}))&&strcmpi(budget.Solver,'Friis')
                return;
            end
            tagval=strjoin(strsplit(tagval),'_');
            tagval=strjoin(strsplit(tagval,'-'),'_');
            if strcmpi(tagval,'S_parameters')
                tagval='S21';
            end
            try
                if isempty(self.PlotsFig.Plots.(tagval))||...
                    ~isvalid(self.PlotsFig.Plots.(tagval))

                    if self.UseAppContainer
                        self.PlotsFig.Plots.(tagval)=...
                        matlab.ui.internal.FigureDocument(...
                        'DocumentGroupTag','figureGroup',...
                        'Tag',tagval,...
                        'Tile',2,'CanCloseFcn',@(src,event)self.CloseFig(),'EnableDockControls',false);
                        add(self.Toolstrip.AppContainer,self.PlotsFig.Plots.(tagval));
                    else
                        self.PlotsFig.Plots.(tagval)=...
                        figure(...
                        'HandleVisibility','off',...
                        'Visible','off',...
                        'NumberTitle','off',...
                        'IntegerHandle','off');
                        self.Toolstrip.ToolGroup.addFigure(self.PlotsFig.Plots.(tagval));
                    end
                else

                    if self.UseAppContainer
                        clf(self.PlotsFig.Plots.(tagval).Figure);
                    else
                        clf(self.PlotsFig.Plots.(tagval));
                    end
                end
            catch
                if self.UseAppContainer
                    self.PlotsFig.Plots.(tagval)=...
                    matlab.ui.internal.FigureDocument(...
                    'DocumentGroupTag','figureGroup',...
                    'Tag',tagval,...
                    'Tile',2,'CanCloseFcn',@(src,evt)self.CloseFig(),'EnableDockControls',false);
                    add(self.Toolstrip.AppContainer,self.PlotsFig.Plots.(tagval));
                else
                    self.PlotsFig.Plots.(tagval)=...
                    figure('HandleVisibility','off',...
                    'Visible','off',...
                    'NumberTitle','off',...
                    'IntegerHandle','off');
                    self.Toolstrip.ToolGroup.addFigure(self.PlotsFig.Plots.(tagval));
                end
            end
            figHandle=self.PlotsFig.Plots.(tagval);
            if self.UseAppContainer
                figDoc=figHandle;
                figHandle=figHandle.Figure;
                figHandle.AutoResizeChildren='off';
            end
            ax=axes(figHandle);


            dlg=self.Parameters.SystemDialog;
            if Dim2
                BW=self.Toolstrip.PlotBandwidth;
                Res=1;
                tailstr=' - 2D';
            else
                budget.Solver='Friis';
                BW=self.Toolstrip.PlotBandwidth;
                Res=self.Toolstrip.PlotResolution;
                tailstr=' - 3D';
            end
            figHandle.HandleVisibility='on';
            if useString
                plotType=strsplit(tagval,'_');
                if strcmpi(items.Text,'S-Parameters')
                    rfplot(...
                    budget,...
                    'Sparameters',...
                    'Parent',ax,...
                    'Bandwidth',BW,...
                    'Resolution',Res);
                    if self.UseAppContainer
                        figDoc.Title='S21';
                    else
                        figHandle.Name='S21';
                    end
                    self.PlotsFig.Plots.Args.('S21')=...
                    {budget,'Sparameters',...
                    'Parent',ax};
                else
                    rfplot(...
                    budget,...
                    plotType{1},...
                    'Parent',ax,...
                    'Bandwidth',BW,...
                    'Resolution',Res);
                    self.PlotsFig.Plots.Args.(tagval)=...
                    {budget,plotType{1},...
                    'Parent',ax};
                end
                if self.UseAppContainer
                    if~strcmpi(figDoc.Title,"")
                        figDoc.Title=[char(figDoc.Title),tailstr];
                        figHandle.Name=[char(figDoc.Title)];
                    else
                        figDoc.Title=[figHandle.Name,tailstr];
                    end
                else
                    figHandle.Name=[figHandle.Name,tailstr];
                end
            else
                BW=self.Toolstrip.PlotBandwidth;
                Res=self.Toolstrip.PlotResolution;
                rfplot(budget,...
                str2double(items.Text(2)),...
                str2double(items.Text(3)),...
                'Parent',ax,...
                'Bandwidth',BW,...
                'Resolution',Res);
                if self.UseAppContainer
                    figDoc.Title=['S',items.Text(2:3),tailstr];
                else
                    figHandle.Name=['S',items.Text(2:3),tailstr];
                end
                self.PlotsFig.Plots.Args.(tagval)={budget,str2double(items.Text(2)),...
                str2double(items.Text(3)),...
                'Parent',ax};
            end
            axtoolbar(ax,...
            {'export',...
            'datacursor',...
            'rotate',...
            'zoomin',...
            'zoomout',...
            'restoreview'});
            enableDefaultInteractivity(ax);
            figHandle.ToolBarMode='auto';
            figHandle.Visible='on';
            if self.UseAppContainer
            else
                figure(figHandle);
            end


            figHandle.HandleVisibility='off';
            setfigTile(self,figHandle);


            enableActions(self,true)
            setStatusBarMsg(self,'');
        end

        function out=CloseFig(self)
            self.PlotCounter=self.PlotCounter-1;
            out=1;
        end

        function addSParameterFigure(self,budget,items)



            enableActions(self,false)
            warning('off','rf:shared:InputPower')
            budget=clone(budget);
            warning('on','rf:shared:InputPower')
            budget.Solver='Friis';

            setStatusBarMsg(self,'Adding S-Parameters plot.');
            try
                if isempty(self.PlotsFig.SParameterPlots.(items.Tag))||...
                    ~isvalid(self.PlotsFig.SParameterPlots.(items.Tag))
                    if self.UseAppContainer

                        self.PlotsFig.SParameterPlots.(items.Tag)=...
                        matlab.ui.internal.FigureDocument('Tag',...
                        [items.Tag,'Document',num2str(length(getDocuments(self.Toolstrip.AppContainer)))],...
                        'DocumentGroupTag','figureGroup','Tile',2);

                        add(self.Toolstrip.AppContainer,self.PlotsFig.SParameterPlots.(items.Tag));
                    else

                        self.PlotsFig.SParameterPlots.(items.Tag)=...
                        figure(...
                        'HandleVisibility','off',...
                        'Visible','off',...
                        'NumberTitle','off',...
                        'IntegerHandle','off');

                        self.Toolstrip.ToolGroup.addFigure(self.PlotsFig.SParameterPlots.(items.Tag));
                    end
                else
                    clf(self.PlotsFig.SParameterPlots.(items.Tag));
                end
            catch me
                if self.UseAppContainer

                    self.PlotsFig.SParameterPlots.(items.Tag)=...
                    matlab.ui.internal.FigureDocument('Tag',...
                    [items.Tag,'Document',num2str(length(getDocuments(self.Toolstrip.AppContainer)))],...
                    'DocumentGroupTag','figureGroup','Tile',2);

                    add(self.Toolstrip.AppContainer,self.PlotsFig.SParameterPlots.(items.Tag));
                else

                    self.PlotsFig.SParameterPlots.(items.Tag)=...
                    figure(...
                    'HandleVisibility','off',...
                    'Visible','off',...
                    'NumberTitle','off',...
                    'IntegerHandle','off');

                    self.Toolstrip.ToolGroup.addFigure(self.PlotsFig.SParameterPlots.(items.Tag));
                end
            end
            figHandle=self.PlotsFig.SParameterPlots.(items.Tag);
            if self.UseAppContainer
                figHandle.Title='S-Parameters';
                figHandle=figHandle.Figure;
                figHandle.AutoResizeChildren='off';
            end


            figHandle.HandleVisibility='on';

            BW=self.Toolstrip.PlotBandwidth;

            Res=self.Toolstrip.PlotResolution;

            InFreq=budget.InputFrequency;

            freqval=linspace((InFreq-BW/2),(InFreq+BW/2),Res);
            budget.InputFrequency=freqval;
            cp=rf.internal.apps.budget.CompositePlot(self,figHandle,budget);
            self.CompositePlotHdl=cp;
            self.PlotsFig.SParameterPlots.Args.(items.Tag)={budget};

            figHandle.Name='S-Parameters';
            setAxesToolbar(cp);
            figHandle.ToolBarMode='auto';
            figHandle.Visible='on';
            figure(figHandle);


            figHandle.HandleVisibility='off';
            setfigTile(self,figHandle);
            enableActions(self,true)
            setStatusBarMsg(self,'');
        end
    end


    methods(Hidden)

        function setfigTile(self,figHandle)

            if self.UseAppContainer
            else

                matDsk=com.mathworks.mlservices.MatlabDesktopServices.getDesktop();
                atgName=self.Toolstrip.ToolGroup.Name;
                TileNum=getTileNum(self,'Results');
                if~(getTileNum(self,figHandle.Name)==TileNum)
                    matDsk.setClientLocation(figHandle.Name,atgName,...
                    com.mathworks.widgets.desk.DTLocation.create(TileNum));
                end
            end
        end

        function TileNum=getTileNum(self,Name)

            if self.UseAppContainer
            else
                matDsk=com.mathworks.mlservices.MatlabDesktopServices.getDesktop();
                presentclient=matDsk.getClient(Name,self.Toolstrip.ToolGroup.Name);
                presentclientlocation=matDsk.getClientLocation(presentclient);
                pause(0.01);
                k=0;
                while isempty(presentclientlocation)
                    presentclient=matDsk.getClient(Name,self.Toolstrip.ToolGroup.Name);
                    presentclientlocation=matDsk.getClientLocation(presentclient);
                    pause(0.01);
                    k=k+1;
                    if k==5
                        break;
                    end
                end
                if isempty(presentclientlocation)
                    TileNum=1;
                else
                    TileNum=presentclientlocation.getTile();
                end
            end
        end

        function disableDeleteOnTabbedFigures(self,fig)



            if self.UseAppContainer
            else
                drawnow;
                state=java.lang.Boolean.FALSE;
                md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;%#ok<*JAPIMATHWORKS>
                toolName=self.Toolstrip.ToolGroup.Name;
                prop=com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
                md.getClient(fig.Name,toolName).putClientProperty(prop,state);
            end
        end

        function addAction(self,type)


            enableActions(self,false)
            index=self.Canvas.InsertIdx;

            self.notify('InsertionRequested',...
            rf.internal.apps.budget.AddOrDeleteRequestedEventData(index,type))
            enableActions(self,true)
        end

        function deleteAction(self)


            enableActions(self,false)
            index=self.Canvas.SelectIdx;

            self.notify('DeletionRequested',...
            rf.internal.apps.budget.AddOrDeleteRequestedEventData(index))
            enableActions(self,true)
        end

        function enableActions(self,val)



            if val==self.Toolstrip.NewBtn.Enabled
                return;
            end

            if self.NumElements==0
                nonemptyVal=false;
            else
                nonemptyVal=val;
            end

            self.Listeners.WindowMousePress.Enabled=val;
            self.Listeners.WindowMouseMotion.Enabled=val;
            self.Listeners.WindowMouseRelease.Enabled=val;
            self.Listeners.SizeChanged.Enabled=val;

            self.Toolstrip.NewBtn.Enabled=val;
            self.Toolstrip.OpenBtn.Enabled=val;
            self.Toolstrip.SaveBtn.Enabled=nonemptyVal;

            self.Toolstrip.DeleteBtn.Enabled=nonemptyVal;

            if nonemptyVal
                self.Toolstrip.HBBtn.Enabled=~self.Toolstrip.AutoUpdateCheckbox.Value;
            else
                self.Toolstrip.HBBtn.Enabled=nonemptyVal;
            end

            self.Toolstrip.ElementGallery.Enabled=val;

            self.Toolstrip.PlotBtn2D.Enabled=nonemptyVal;
            self.Toolstrip.PlotBtn.Enabled=nonemptyVal;
            self.Toolstrip.SmithBtn.Enabled=nonemptyVal;
            self.Toolstrip.PolarBtn.Enabled=nonemptyVal;
            self.Toolstrip.DefaultLayoutBtn.Enabled=val;
            self.Toolstrip.ExportBtn.Enabled=nonemptyVal;
            self.Toolstrip.PlotBandwidthLabel.Enabled=nonemptyVal;
            self.Toolstrip.PlotBandwidthEdit.Enabled=nonemptyVal;
            self.Toolstrip.PlotBandwidthUnits.Enabled=nonemptyVal;
            self.Toolstrip.PlotResolutionLabel.Enabled=nonemptyVal;
            self.Toolstrip.PlotResolutionEdit.Enabled=nonemptyVal;

            self.Toolstrip.AutoUpdateCheckbox.Enabled=nonemptyVal;

            enableUIControls(self.Toolstrip.SystemParameters,val);
            if~isempty(self.Parameters)
                if~isempty(self.Parameters.ElementDialog)
                    enableUIControls(self.Parameters.ElementDialog,val);
                end
            end
            pause(0.1);
        end
    end


    methods(Hidden)

        function systemParameterInvalid(self,data)


            systemParameterInvalid(self.Parameters,data)
        end

        function elementParameterInvalid(self,data)

            elementParameterInvalid(self.Parameters,data)
        end

        function parameterChanged(self,data)


            if self.UseAppContainer
                valueString='Value';
                stringLabel='Text';
            else
                valueString='String';
                stringLabel='String';
            end
            if strcmpi(data.Name,'SignalBandwidth')
                self.Toolstrip.PlotBandwidth=data.Budget.SignalBandwidth;
            end
            if strcmpi(data.Name,'Name')
                nameval=data.Budget.Elements(data.Index).Name;
                ev=self.Canvas.Cascade.Elements(data.Index);
                ev.Picture.Name.(stringLabel)=nameval;
            else

                updateCascadeText(self,data.Budget)
                updatePlots(self,data.Budget);
                updateResultsTable(self.Results,data.Budget);


                UpdatedIMTProperty(self.Parameters,data.Budget);
            end

        end

        function bandwidthResolutionChanged(self,data)


            enableActions(self,false)
            enableIP2(self.Toolstrip,false);
            updatePlots(self,data.Budget,1);
            enableActions(self,true)
        end


        function elementInserted(self,data)


            self.NumElements=numel(data.Budget.Elements);
            enableIP2(self.Toolstrip,false);
            enableActions(self,false)
            insertElement(self.Canvas,data.Budget,data.Index)
            updateCascadeText(self,data.Budget)
            updatePlots(self,data.Budget);
            updateResultsTable(self.Results,data.Budget);
            enableActions(self,true)
            if isa(data.Budget.Elements(1),'rfantenna')
                if strcmpi(data.Budget.Elements(1).Type,'Receiver')
                    enableInputPower(self.Toolstrip,false)
                else
                    enableInputPower(self.Toolstrip,true)
                end
            end
            index=arrayfun(@(x)isa(x,'powerAmplifier'),data.Budget.Elements);
            if isa(data.Budget.Elements(end),'rfantenna')||...
                isa(data.Budget.Elements(1),'rfantenna')||...
                any(index)
                enableTestbench(self.Toolstrip,false);
            else
                enableTestbench(self.Toolstrip,true);
            end

        end

        function elementDeleted(self,data)

            self.NumElements=numel(data.Budget.Elements);
            enableIP2(self.Toolstrip,false);
            enableActions(self,false)

            deleteElement(self.Canvas,data.Budget,data.Index)
            if numel(data.Budget.Elements)==0
                self.hideFigures();
                enableInputPower(self.Toolstrip,true)
            else
                if isa(data.Budget.Elements(end),'rfantenna')
                    enableTestbench(self.Toolstrip,false);
                else
                    enableTestbench(self.Toolstrip,true);
                end
            end
            updateCascadeText(self,data.Budget)
            updatePlots(self,data.Budget);
            updateResultsTable(self.Results,data.Budget);
            enableActions(self,true)
            enableInputPower(self.Toolstrip,true)
            if numel(data.Budget.Elements)~=0
                if isa(data.Budget.Elements(1),'rfantenna')
                    if strcmpi(data.Budget.Elements(1).Type,'Receiver')
                        enableInputPower(self.Toolstrip,false)
                    else
                        enableInputPower(self.Toolstrip,true)
                    end
                end
            end
        end

        function selectedElement(self,data)


            ev=self.Canvas.Cascade.Elements(data.Index);
            self.Canvas.SelectedElement=ev;
            selectElement(ev,data.Element)
        end

        function disableCanvas(self,data)


            hideCascadeText(self,data.Value)
        end

        function hideFigures(self)


            [~,figHandles]=getFigNamesAndHandles(self);
            for i=1:numel(figHandles)
                figHandles{i}.Visible='off';
                figHandles{i}.delete;
            end
        end

        function iconUpdate(self,data)
            ev=self.Canvas.Cascade.Elements(data.Index);
            ev.Type=data.Value;
            if~strcmpi(data.Value,'Stripline')
                icon=imread([fullfile('+rf','+internal','+apps','+budget')...
                ,filesep,lower(data.Value),'_60.png']);
            else
                icon=imread([fullfile('+rf','+internal','+apps','+budget')...
                ,filesep,data.Value,'_60.png']);
            end
            ev.Icon=icon;
            if self.UseAppContainer
                ev.Picture.Block.ImageSource=icon;
                ev.Picture.Block.ImageSource=highlight(ev,3,[0,153,255]./255);
            else
                ev.Picture.Block.CData=icon;
                ev.Picture.Block.CData=highlight(ev,3,[0,153,255]./255);
            end
        end

        function clientActionListener(self,~,evt)


            switch(evt.EventData.EventType)
            case 'ACTIVATED'
                self.CurrentFigureHandle=evt.EventData.Client;
                self.Results.RowPicker.resetDropDown()
            case 'DEACTIVATED'
            case 'OPENED'
            case 'CLOSING'
            end
        end

        function[figName,fighandles]=getFigNamesAndHandles(self)


            figName={};
            fighandles={};
            if~isempty(self.PlotsFig)
                plotstype=fields(self.PlotsFig);
            else
                plotstype=[];
            end
            for j=1:numel(plotstype)
                analysisplots=fields(self.PlotsFig.(plotstype{j}));
                for k=1:numel(analysisplots)
                    if strcmpi(analysisplots{k},'Args')
                        continue;
                    end
                    try
                        f=self.PlotsFig.(plotstype{j}).(analysisplots{k});
                    catch
                        f=[];
                    end
                    if self.UseAppContainer&&isvalid(f)
                        f=f.Figure;
                    end
                    if isvalid(f)&&~isempty(f)
                        fighandles=[fighandles;{f}];%#ok<*AGROW> 
                        figName=[figName;{f.Name}];
                    end
                end
            end
        end


        function tileDefaultLayout(self)


            enableActions(self,false);
            numfig=0;
            figName={};
            [figName,~]=getFigNamesAndHandles(self);
            generateLayout(self,numfig)
            applyLayout(self,figName,numfig)
            enableActions(self,true);
        end

        function generateLayout(self,numfig)


            if self.UseAppContainer
                self.Toolstrip.AppContainer.DocumentGridDimensions=[1,2];
                self.CanvasFig.Tile=1;
                self.ResultsFig.Tile=2;
                self.ParametersFig.Region="left";
                self.Toolstrip.AppContainer.LeftCollapsed=0;
                self.ParametersFig.Maximized=0;
            else
                matDsk=com.mathworks.mlservices.MatlabDesktopServices.getDesktop();
                atgName=self.Toolstrip.ToolGroup.Name;
                switch numfig
                case 0
                    matDsk.setDocumentArrangement(atgName,matDsk.TILED,java.awt.Dimension(2,2));
                    matDsk.setDocumentRowSpan(atgName,0,0,2);
                    matDsk.setDocumentColumnWidths(atgName,[0.29,0.71]);
                    matDsk.setDocumentRowHeights(atgName,[0.5,0.5]);
                end
                pause(0.01);
            end
        end

        function applyLayout(self,figNames,numfig)


            if self.UseAppContainer
            else
                matDsk=com.mathworks.mlservices.MatlabDesktopServices.getDesktop();
                atgName=self.Toolstrip.ToolGroup.Name;
                matDsk.setClientLocation('Parameters',atgName,...
                com.mathworks.widgets.desk.DTLocation.create(0));
                matDsk.setClientLocation(self.CanvasFig.Name,atgName,...
                com.mathworks.widgets.desk.DTLocation.create(1));
                resultsTile=2;
                numTiles=numfig+3;
                matDsk.setClientLocation('Results',atgName,...
                com.mathworks.widgets.desk.DTLocation.create(resultsTile));
                tileNumbers=2:numTiles-1;
                tileNumbers=tileNumbers(tileNumbers~=resultsTile);
                lastTile=numel(tileNumbers);
                for i=1:numel(figNames)
                    if lastTile==0
                        tileVal=2;
                    elseif i<=lastTile
                        tileVal=tileNumbers(i);
                    else
                        tileVal=tileNumbers(lastTile);
                    end
                    matDsk.setClientLocation(figNames{i},atgName,...
                    com.mathworks.widgets.desk.DTLocation.create(tileVal));
                    pause(0.01);
                end
            end
        end

        function setStatusBarMsg(self,msg)

            if self.UseAppContainer
                self.Toolstrip.StatusLabel.Text=msg;
            else

                matDsk=com.mathworks.mlservices.MatlabDesktopServices.getDesktop();
                frame=matDsk.getFrameContainingGroup(self.Toolstrip.ToolGroup.Name);
                javaMethodEDT('setStatusText',frame,msg);
            end
        end
    end

end




function shrinkNameAsNeeded(u,targetWidth)






    fullname=u.String;
    Nchars=numel(fullname);
    if Nchars<...
        2||...
        u.Extent(3)<...
targetWidth
        return
    end




    str=[fullname(1:end-2),'...'];
    u.String=str;
    if u.Extent(3)<...
targetWidth
        u.String=fullname;
        return
    end


    Nchars=Nchars-1;


    while 1
        Nchars=Nchars-1;
        str(Nchars)='';
        u.String=str;
        if Nchars==2||...
            u.Extent(3)<...
targetWidth

            break
        end
    end
end









