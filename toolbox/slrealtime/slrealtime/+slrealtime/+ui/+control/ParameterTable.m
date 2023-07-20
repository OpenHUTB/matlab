classdef ParameterTable<slrealtime.internal.SLRTComponent




    properties(Access=protected)
        tgEventsTriggeringUpdateGUI=...
        {...
        'Connected',...
        'Disconnected',...
        'Loaded',...
        'Stopped',...
        'ParamChanged',...
        'ParamSetChanged',...
'CalPageChanged'...
        }
    end

    properties(Access=private,Constant)
        ParamsPathText=message('slrealtime:appdesigner:ParamsPath').getString();
        ParamsNameText=message('slrealtime:appdesigner:ParamsName').getString();
        ParamsValueText=message('slrealtime:appdesigner:ParamsValue').getString();
        ParamsTypeText=message('slrealtime:appdesigner:ParamsType').getString();
        ParamsSizeText=message('slrealtime:appdesigner:ParamsSize').getString();
        ErrorGettingValueText=message('slrealtime:appdesigner:ParamsErrorGettingValue').getString();
    end

    properties(Access=public)
Parameters



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

        ValueEditor=[]
    end

    properties(Access=private,Transient,NonCopyable)
        Grid matlab.ui.container.GridLayout

DummyFigure
    end

    methods(Access=public)
        function delete(this)
            delete(this.ValueEditor);
            delete(this.TableContextMenu);
            delete(this.DummyFigure);
            delete(this.SelectorDlgClosingListener);
            delete(this.SelectorDlg);
        end
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
            'CellEditCallback',@this.CellEdit,...
            'CellSelectionCallback',@this.CellSelection);
            this.Table.Layout.Row=1;
            this.Table.Layout.Column=1;
            this.Table.ColumnName={...
            this.ParamsPathText,...
            this.ParamsNameText,...
            this.ParamsValueText,...
            this.ParamsTypeText,...
            this.ParamsSizeText};
            this.Table.RowName={};
            this.Table.ColumnEditable=[false,false,true,false,false];




            this.Table.FontName='Helvetica';
            this.Table.FontUnits='pixels';
            this.Table.FontSize=12;



            this.DummyFigure=uifigure;
            this.DummyFigure.Visible='off';
            this.TableContextMenu=uicontextmenu(this.DummyFigure);



            this.OpenSelectorMenu=uimenu(this.TableContextMenu,...
            'MenuSelectedFcn',@(o,e)OpenSelector(this));
            this.OpenSelectorMenu.Text=message('slrealtime:appdesigner:ParameterSelector').getString();



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
        function set.Parameters(this,value)
            if isstruct(value)&&...
                length(fields(value))==2&&...
                isfield(value,'BlockPath')&&...
                isfield(value,'ParameterName')&&...
                all(cellfun(@(x)ischar(x)||isstring(x),{value.ParameterName}))


                for i=1:length(value)
                    value(i).BlockPath=slrealtime.internal.SLRTComponent.checkAndFormatBlockPath(value(i).BlockPath);
                end

                this.Table.Data=[];%#ok
                this.Parameters=value;
                this.updateGUIWrapper([]);
            else

                slrealtime.internal.throw.Error(...
                'slrealtime:appdesigner:ParamsIncorrectParameters');
            end
        end
    end

    methods(Access=public,Hidden)
        function disableControlForInvalidTarget(this)
            this.disableTable();
        end

        function updateGUI(this,evnt)
            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            if tg.isConnected()&&(tg.isLoaded()||tg.isRunning)

                try
                    if tg.getECUPage()~=tg.getXCPPage()
                        this.disableTable();
                        this.Table.Tooltip=message('slrealtime:appdesigner:DisabledDueToPageSwitchingTooltip').getString();
                        return;
                    end
                catch

                end

                if~isempty(evnt)&&isa(evnt,'slrealtime.events.TargetParamSetData')
                    forceGetParam=false;
                    try
                        if~isequal(evnt.Page,tg.getECUPage())



                            return;
                        end
                    catch




                        forceGetParam=true;
                    end
                end

                if~isempty(evnt)&&isa(evnt,'slrealtime.events.TargetParamData')







                    paramNameLevels=split(evnt.paramName,'.');
                    [evntParamName,~]=slrealtime.internal.guis.Explorer.StaticUtils.parseForIndex(paramNameLevels{1});
                end

                this.Table.Enable='on';
                this.Table.Tooltip='';

                if this.isSimulinkNormalMode()
                    set(this.TableContextMenu.Children,'Visible','off');
                else
                    set(this.TableContextMenu.Children,'Visible','on');
                end

                for nParam=1:length(this.Parameters)

                    blockpath=this.Parameters(nParam).BlockPath;
                    paramname=this.Parameters(nParam).ParameterName;

                    try
                        if~isempty(evnt)&&isa(evnt,'slrealtime.events.TargetParamData')





                            if~isequal(blockpath,evnt.blockPath)||...
                                ~(strcmp(paramname,evnt.paramName)||strcmp(paramname,evntParamName))
                                continue;
                            end
                            if strcmp(paramname,evnt.paramName)
                                value=evnt.value;
                            else
                                value=tg.getparam(blockpath,paramname);
                            end
                        elseif~isempty(evnt)&&isa(evnt,'slrealtime.events.TargetParamSetData')&&~forceGetParam



                            idx=find(strcmp(regexprep(evnt.BlockPath,newline,' '),regexprep(blockpath,newline,' ')));
                            idx2=find(strcmp(evnt.ParamName(idx),paramname));
                            if isempty(idx(idx2))
                                continue;
                            end
                            value=evnt.Value{idx(idx2)};
                        else


                            value=tg.getparam(blockpath,paramname);
                        end

                        dims=size(value);
                        sizeStr=num2str(dims(1));
                        for nDims=2:length(dims)
                            sizeStr=[sizeStr,'x',num2str(dims(nDims))];%#ok
                        end

                        if isstruct(value)
                            valueStr=['<',sizeStr,' struct>'];


                            if~isempty(this.ValueEditor)&&isvalid(this.ValueEditor.VarEditor)...
                                &&isequal(this.ValueEditor.ParamName,paramname)
                                this.ValueEditor.updateParamValueInVarEditor(value);
                            end
                        else
                            dims=size(value);
                            if length(dims)>2
                                valueStr=['<',sizeStr,' value>'];
                            else
                                valueStr=mat2str(value);
                            end
                        end

                        if isfi(value)
                            type=value.numerictype.tostringInternalFixdt;
                        else
                            type=class(value);
                        end

                    catch
                        type=[];
                        sizeStr=[];
                        valueStr=this.ErrorGettingValueText;
                    end

                    this.Table.Data{nParam,1}=slrealtime.internal.SLRTComponent.blockPathToDisplay(blockpath);
                    this.Table.Data{nParam,2}=paramname;
                    this.Table.Data{nParam,3}=valueStr;
                    this.Table.Data{nParam,4}=type;
                    this.Table.Data{nParam,5}=sizeStr;
                end
            else
                this.disableTable();
            end
        end
    end

    methods(Access=private)
        function disableTable(this)
            this.Table.Enable='off';
            this.Table.Tooltip='';
            set(this.TableContextMenu.Children,'Visible','off');
            for nParam=1:length(this.Parameters)
                this.Table.Data{nParam,1}=slrealtime.internal.SLRTComponent.blockPathToDisplay(this.Parameters(nParam).BlockPath);
                this.Table.Data{nParam,2}=this.Parameters(nParam).ParameterName;
                this.Table.Data{nParam,3}=[];
                this.Table.Data{nParam,4}=[];
                this.Table.Data{nParam,5}=[];
            end
        end

        function CellEdit(this,~,evnt)
            prevValueStr=evnt.PreviousData;
            newValueStr=evnt.NewData;

            row=evnt.Indices(1);

            if strcmp(prevValueStr,this.ErrorGettingValueText)
                this.Table.Data{row,3}=prevValueStr;
                return;
            end

            blockpath=this.Parameters(row).BlockPath;
            paramname=this.Table.Data{row,2};
            datatype=this.Table.Data{row,4};
            sizeStr=this.Table.Data{row,5};

            if strcmp(datatype,'struct')





                this.Table.Data{row,3}=prevValueStr;
                this.CellSelection([],evnt);
            else




                dimsStrs=split(sizeStr,'x');
                if length(dimsStrs)>2







                    this.Table.Data{row,3}=prevValueStr;
                    this.CellSelection([],evnt);
                else





                    orig_data=this.Table.Data;
                    orig_data{row,3}=prevValueStr;

                    try



                        try
                            dt=eval(datatype);
                            val=fi(str2num(newValueStr),dt);%#ok
                        catch
                            try
                                val=eval([datatype,'(',newValueStr,')']);
                            catch
                                try
                                    val=eval([datatype,'(''',newValueStr,''')']);
                                catch






                                    slrealtime.internal.throw.Error(...
                                    'slrealtime:appdesigner:ParamsIncorrectDataType',...
                                    datatype);
                                end
                            end
                        end



                        tg=this.tgGetTargetObject();
                        if isempty(tg),return;end
                        tg.setparam(blockpath,paramname,val);

                    catch ME
                        this.uialert(ME,'CloseFcn',...
                        @(~,~)this.Table.set('Data',orig_data));
                        return;
                    end
                end
            end
        end

        function CellSelection(this,~,evnt)
            if any(size(evnt.Indices)~=[1,2])

                return;
            end

            row=evnt.Indices(1);
            col=evnt.Indices(2);

            value=this.Table.Data{row,3};
            if strcmp(value,this.ErrorGettingValueText)
                return;
            end

            datatype=this.Table.Data{row,4};
            sizeStr=this.Table.Data{row,5};
            dimsStrs=split(sizeStr,'x');

            if col~=3||(~strcmp(datatype,'struct')&&length(dimsStrs)<=2)

                return;
            end

            tg=this.tgGetTargetObject();
            if isempty(tg),return;end

            blockpath=this.Parameters(row).BlockPath;
            paramname=this.Table.Data{row,2};

            value=tg.getparam(blockpath,paramname);

            if~isempty(this.ValueEditor)
                delete(this.ValueEditor);
            end
            this.ValueEditor=...
            slrealtime.internal.guis.Explorer.ValueEditor(...
            tg,paramname,value,blockpath,ancestor(this.Parent,'figure'));
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
