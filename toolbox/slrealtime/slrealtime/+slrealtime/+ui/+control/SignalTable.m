classdef SignalTable<slrealtime.internal.SLRTComponent




    properties(Access=protected)
        tgEventsTriggeringUpdateGUI=...
        {...
        'Connected',...
        'Disconnected',...
        'Loaded',...
        'Starting',...
'Stopped'...
        }
    end

    methods(Access=public)
        function delete(this)
            if~isempty(this.InstrumentAddedToTargetName)
                try
                    tg=this.tgGetTargetObject(this.InstrumentAddedToTargetName);
                    if isempty(tg),return;end
                    tg.removeInstrument(this.Instrument);
                catch
                end
            end
            delete(this.TableContextMenu);
            delete(this.DummyFigure);
            delete(this.SelectorDlgClosingListener);
            delete(this.SelectorDlg);
        end
    end

    properties(Access=private,Constant)
        SignalText=message('slrealtime:appdesigner:SigsSignal').getString()
        ValueText=message('slrealtime:appdesigner:SigsValue').getString()
        EnabledText=message('slrealtime:appdesigner:SigsEnabled').getString()
        SignalTypeText=message('slrealtime:appdesigner:UnsupportedSignalType').getString()
        NotAvailText=['<',message('slrealtime:appdesigner:SigsNotAvail').getString(),'>']
    end

    properties(Access=public)
Signals



FontName
FontSize
FontWeight
FontAngle
        RowStriping=true
        TableForegroundColor=[0,0,0]
        TableBackgroundColor=[1,1,1;0.94,0.94,0.94]
    end

    properties(Access={?slrealtime.internal.SLRTComponent},Transient,NonCopyable)
        Table matlab.ui.control.Table

        TableContextMenu matlab.ui.container.ContextMenu
        OpenSelectorMenu matlab.ui.container.Menu
    end

    properties(Access=private,Transient,NonCopyable)
        Grid matlab.ui.container.GridLayout

DummyFigure

Instrument
        InstrumentAddedToTargetName=[]
    end

    methods(Access=protected)
        function setup(this)


            tableWidth=500;
            tableHeight=200;



            this.Grid=uigridlayout(this,[1,1],...
            'Padding',0,'RowSpacing',0,'ColumnSpacing',0);
            this.Grid.ColumnWidth={'1x'};
            this.Grid.RowHeight={'1x'};



            this.Table=uitable(this.Grid,...
            'CellEditCallback',@this.CellEdit);
            this.Table.Layout.Row=1;
            this.Table.Layout.Column=1;
            this.Table.ColumnName={...
            this.SignalText;...
            this.ValueText;...
            this.EnabledText};
            this.Table.RowName={};
            this.Table.ColumnEditable=[false,false,true];
            this.Table.ColumnWidth={'auto','auto',61};




            this.Table.FontName='Helvetica';
            this.Table.FontUnits='pixels';
            this.Table.FontSize=12;



            this.DummyFigure=uifigure;
            this.DummyFigure.Visible='off';
            this.TableContextMenu=uicontextmenu(this.DummyFigure);



            this.OpenSelectorMenu=uimenu(this.TableContextMenu,...
            'MenuSelectedFcn',@(o,e)OpenSelector(this));
            this.OpenSelectorMenu.Text=message('slrealtime:appdesigner:SignalSelector').getString();



            this.Position=[100,100,tableWidth,tableHeight];
            this.FontName=this.Table.FontName;
            this.FontSize=this.Table.FontSize;
            this.FontWeight=this.Table.FontWeight;
            this.FontAngle=this.Table.FontAngle;
        end

        function update(this)
            if this.firstUpdate
                this.firstUpdate=false;



                if isempty(this.GetTargetNameFcnH)
                    this.initTarget([]);
                end
            end

            this.Table.FontName=this.FontName;
            this.Table.FontSize=this.FontSize;
            this.Table.FontWeight=this.FontWeight;
            this.Table.FontAngle=this.FontAngle;
            this.Table.RowStriping=this.RowStriping;
            this.Table.ForegroundColor=this.TableForegroundColor;
            this.Table.BackgroundColor=this.TableBackgroundColor;

            if this.isDesignTime()

                this.Table.Enable='on';
            else

                this.TableContextMenu.Parent=ancestor(this.Parent,'figure');
                this.Table.ContextMenu=this.TableContextMenu;
                delete(this.DummyFigure);
                this.DummyFigure=[];
            end
        end
    end

    methods
        function set.Signals(this,value)

            if this.isSimulinkNormalMode()
                tg=this.tgGetTargetObject();
                if isempty(tg)||tg.isRunning()
                    return;
                end
            end

            if isstruct(value)&&...
                length(fields(value))==2&&...
                isfield(value,'BlockPath')&&...
                isfield(value,'PortIndex')&&...
                all(cellfun(@(x)isnumeric(x),{value.PortIndex}))


                for i=1:length(value)
                    if value(i).PortIndex==-1
                        value(i).BlockPath=convertStringsToChars(value(i).BlockPath);
                        if~ischar(value(i).BlockPath)

                            slrealtime.internal.throw.Error(...
                            'slrealtime:appdesigner:InvalidSignalName');
                        end
                    else
                        value(i).BlockPath=slrealtime.internal.SLRTComponent.checkAndFormatBlockPath(value(i).BlockPath);
                    end
                end

                this.Table.Data=[];%#ok
                this.Signals=value;
                this.updateGUIWrapper([]);
            else

                slrealtime.internal.throw.Error(...
                'slrealtime:appdesigner:SigsIncorrectSignals');
            end
        end
    end

    methods(Access=public,Hidden)
        function disableControlForInvalidTarget(this)
            this.disableTable();
        end

        function updateGUI(this,~)



            if isempty(this.Table.Data)
                for nSig=1:length(this.Signals)
                    if this.Signals(nSig).PortIndex==-1

                        this.Table.Data{nSig,1}=this.Signals(nSig).BlockPath;
                    else

                        this.Table.Data{nSig,1}=[slrealtime.internal.SLRTComponent.blockPathToDisplay(this.Signals(nSig).BlockPath),':',num2str(this.Signals(nSig).PortIndex)];
                    end
                    this.Table.Data{nSig,2}=[];
                    this.Table.Data{nSig,3}=true;
                end
            end






            if~isempty(this.InstrumentAddedToTargetName)
                try
                    tg=this.tgGetTargetObject(this.InstrumentAddedToTargetName);
                    if isempty(tg),return;end

                    tg.removeInstrument(this.Instrument);
                catch


                end
                this.InstrumentAddedToTargetName=[];
            end

            tg=this.tgGetTargetObject();
            if isempty(tg),return;end




            if tg.isConnected()&&(tg.isLoaded()||tg.isRunning)
                this.Table.Enable='on';

                if this.isSimulinkNormalMode()
                    set(this.TableContextMenu.Children,'Visible','off');
                else
                    set(this.TableContextMenu.Children,'Visible','on');
                end

                this.Instrument=slrealtime.Instrument();
                this.Instrument.RemoveOnStop=true;
                this.Instrument.connectCallback(@this.signalsCallback);

                for nSig=1:length(this.Signals)
                    blockpath=this.Signals(nSig).BlockPath;
                    portindex=this.Signals(nSig).PortIndex;
                    if this.Table.Data{nSig,3}
                        if portindex==-1

                            this.Instrument.addSignal(blockpath);
                        else

                            this.Instrument.addSignal(blockpath,portindex);
                        end
                    end
                    this.Table.Data{nSig,2}=[];
                end

                try
                    this.InstrumentAddedToTargetName=this.GetTargetNameFcnH();
                    outStr=evalc('tg.addInstrument(this.Instrument)');
                    if~isempty(outStr)
                        outStr=strrep(outStr,char(8),'');






                        tg.removeInstrument(this.Instrument);
                        outStrs=split(outStr,newline);
                        for outStrIdx=1:numel(outStrs)
                            idxs=strfind(outStrs{outStrIdx},"'");
                            if numel(idxs)==2
                                signame=outStrs{outStrIdx}(idxs(1)+1:idxs(2)-1);
                                evalc('this.Instrument.removeSignal(signame)');

                                tableIdx=find(strcmp(this.Table.Data(:,1),signame));
                                if~isempty(tableIdx)&&numel(tableIdx)==1
                                    this.Table.Data{tableIdx,2}=this.NotAvailText;
                                end
                            end
                        end
                        evalc('tg.addInstrument(this.Instrument)');

                        warningText=message('slrealtime:appdesigner:SigsNameMultResolve',outStr).getString();
                        this.uiwarning(warningText);
                    end
                catch ME
                    this.uialert(ME);
                    return;
                end
            else
                this.disableTable();
            end
        end
    end

    methods(Access=private)
        function disableTable(this)
            this.Table.Enable='off';
            set(this.TableContextMenu.Children,'Visible','off');
            for nSig=1:length(this.Signals)
                if this.Signals(nSig).PortIndex==-1

                    this.Table.Data{nSig,1}=this.Signals(nSig).BlockPath;
                else

                    this.Table.Data{nSig,1}=[slrealtime.internal.SLRTComponent.blockPathToDisplay(this.Signals(nSig).BlockPath),':',num2str(this.Signals(nSig).PortIndex)];
                end
                this.Table.Data{nSig,2}=[];


            end
        end

        function CellEdit(this,~,~)

            if this.isSimulinkNormalMode()
                tg=this.tgGetTargetObject();
                if isempty(tg)||tg.isRunning()
                    return;
                end
            end

            this.updateGUIWrapper([]);
        end

        function signalsCallback(this,~,evnt)
            try
                for nSig=1:length(this.Signals)
                    if~this.Table.Data{nSig,3},continue;end

                    try
                        if this.Signals(nSig).PortIndex==-1

                            [time,data]=this.Instrument.getCallbackDataForSignal(evnt,this.Signals(nSig).BlockPath);
                        else

                            [time,data]=this.Instrument.getCallbackDataForSignal(evnt,this.Signals(nSig).BlockPath,this.Signals(nSig).PortIndex);
                        end
                    catch
                        this.Table.Data{nSig,2}=this.NotAvailText;
                        continue;
                    end

                    if~isempty(time)
                        try
                            if length(time)>1
                                if ndims(data)<=2
                                    data=data(end,:);
                                else
                                    data=(data(:,:,end));
                                end
                            end

                            if iscell(data)
                                dataStr=data{1};
                            elseif ischar(data)||isstring(data)
                                dataStr=convertStringsToChars(data);
                            else
                                dataStr=mat2str(data);
                            end
                        catch
                            dataStr=['<',this.SignalTypeText,'>'];
                        end

                        if~strcmp(this.Table.Data{nSig,2},dataStr)
                            this.Table.Data{nSig,2}=dataStr;
                        end
                    end
                end
            catch ME



                if~strcmp(ME.identifier,'MATLAB:class:InvalidHandle')
                    rethrow(ME);
                end
            end
        end
    end




    properties(Access={?slrealtime.internal.SLRTComponent})
SelectorDlg
SelectorDlgClosingListener
    end

    methods(Access=public,Hidden)
        function OpenSelector(this,varargin)
            function cb(this)

                this.SelectorDlg=[];
                delete(this.SelectorDlgClosingListener);
                this.SelectorDlgClosingListener=[];
            end

            if isempty(this.SelectorDlg)



                if nargin>1




                    sourceFile=varargin{1};
                    tg=[];
                else




                    sourceFile=[];
                    tg=this.tgGetTargetObject();
                    if isempty(tg),return;end
                end

                fig=ancestor(this.Parent,'figure');
                pos=fig.Position;

                this.SelectorDlg=slrealtime.internal.SignalAndParameterTableSelector(tg,this,sourceFile);
                this.SelectorDlg.UIFigure.Position(1)=pos(1)+this.Position(1);
                this.SelectorDlg.UIFigure.Position(2)=pos(2)+this.Position(2);

                this.SelectorDlgClosingListener=addlistener(this.SelectorDlg,'Closing',@(o,e)cb(this));
            else



                figure(this.SelectorDlg.UIFigure);
            end
        end
    end
end
