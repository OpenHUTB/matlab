classdef Parameters<handle



    properties
View
Fig
Layout

        AgcDialog=[];
        FfeDialog=[];
        VgaDialog=[];
        SatAmpDialog=[];
        DfeCdrDialog=[];
        CdrDialog=[];
        CtleDialog=[];
        TransparentDialog=[];
        ChannelDialog=[];
        RcTxDialog=[];
        RcRxDialog=[];
        JitterDialog=[];

        ElementDialog=[];
        DialogsAll={};
    end

    properties(Dependent)
ElementType
    end

    methods

        function obj=Parameters(view)
            if nargin==0
                view=uifigure;
            end
            obj.View=view;

            if isprop(obj.View,'ParametersFig')
                obj.Fig=obj.View.ParametersFig;
            else
                obj.Fig=obj.View;
            end
            obj.Layout=uigridlayout(obj.Fig,'RowHeight',{'1x'},'ColumnWidth',{'1x'},'Scrollable','off');

            obj.AgcDialog=uipanel(obj.Layout,'Title','','BorderType','line','Visible','on','Tag','AgcDialog');
            obj.FfeDialog=uipanel(obj.Layout,'Title','','BorderType','line','Visible','on','Tag','FfeDialog');
            obj.VgaDialog=uipanel(obj.Layout,'Title','','BorderType','line','Visible','on','Tag','VgaDialog');
            obj.SatAmpDialog=uipanel(obj.Layout,'Title','','BorderType','line','Visible','on','Tag','SatAmpDialog');
            obj.DfeCdrDialog=uipanel(obj.Layout,'Title','','BorderType','line','Visible','on','Tag','DfeCdrDialog');
            obj.CdrDialog=uipanel(obj.Layout,'Title','','BorderType','line','Visible','on','Tag','CdrDialog');
            obj.CtleDialog=uipanel(obj.Layout,'Title','','BorderType','line','Visible','on','Tag','CtleDialog');
            obj.TransparentDialog=uipanel(obj.Layout,'Title','','BorderType','line','Visible','on','Tag','TransparentDialog');
            obj.ChannelDialog=uipanel(obj.Layout,'Title','','BorderType','line','Visible','on','Tag','ChannelDialog');
            obj.RcTxDialog=uipanel(obj.Layout,'Title','','BorderType','line','Visible','on','Tag','RcTxDialog');
            obj.RcRxDialog=uipanel(obj.Layout,'Title','','BorderType','line','Visible','on','Tag','RcRxDialog');
            obj.JitterDialog=uipanel(obj.Layout,'Title','','BorderType','line','Visible','on','Tag','JitterDialog');

            obj.setDialogsAll;

            if isempty(obj.JitterDialog)||isempty(obj.JitterDialog.Children)

                for i=1:length(obj.DialogsAll)
                    obj.Layout.RowHeight{i}=0;
                end
                drawnow;

                obj.JitterDialog=serdes.internal.apps.serdesdesigner.JitterDialog(obj,obj.JitterDialog);
                obj.View.SerdesDesignerTool.Model.SerdesDesign.Jitter=obj.JitterDialog.jitter;
            end

            obj.setDialogsAll;
        end
        function setDialogsAll(obj)
            obj.DialogsAll={
            obj.AgcDialog,...
            obj.FfeDialog,...
            obj.VgaDialog,...
            obj.SatAmpDialog,...
            obj.DfeCdrDialog,...
            obj.CdrDialog,...
            obj.CtleDialog,...
            obj.TransparentDialog,...
            obj.ChannelDialog,...
            obj.RcTxDialog,...
            obj.RcRxDialog,...
            obj.JitterDialog};
        end
        function set.ElementType(obj,str)
            if strcmpi(str,getString(message('serdes:serdesdesigner:JitterParametersTitle')))
                obj.Fig.Name=getString(message('serdes:serdesdesigner:JitterParametersTab'));
            else
                obj.Fig.Name=getString(message('serdes:serdesdesigner:BlockParametersText'));
            end
            if strcmpi(str,'')
                if~isempty(obj.ElementDialog)
                    obj.ElementDialog.Panel.Visible='off';
                    obj.ElementDialog=[];
                end
                return
            elseif strcmpi(str,getString(message('serdes:serdesdesigner:AgcHdrDesc')))
                if isempty(obj.AgcDialog)||isprop(obj.AgcDialog,'Children')
                    obj.AgcDialog=serdes.internal.apps.serdesdesigner.BlockDialog(obj,obj.AgcDialog,str);
                    obj.setDialogsAll;
                end
                obj.ElementDialog=obj.AgcDialog;
            elseif strcmpi(str,getString(message('serdes:serdesdesigner:FfeHdrDesc')))
                if isempty(obj.FfeDialog)||isprop(obj.FfeDialog,'Children')
                    obj.FfeDialog=serdes.internal.apps.serdesdesigner.BlockDialog(obj,obj.FfeDialog,str);
                    obj.setDialogsAll;
                end
                obj.ElementDialog=obj.FfeDialog;
            elseif strcmpi(str,getString(message('serdes:serdesdesigner:VgaHdrDesc')))
                if isempty(obj.VgaDialog)||isprop(obj.VgaDialog,'Children')
                    obj.VgaDialog=serdes.internal.apps.serdesdesigner.BlockDialog(obj,obj.VgaDialog,str);
                    obj.setDialogsAll;
                end
                obj.ElementDialog=obj.VgaDialog;
            elseif strcmpi(str,getString(message('serdes:serdesdesigner:SatAmpHdrDesc')))
                if isempty(obj.SatAmpDialog)||isprop(obj.SatAmpDialog,'Children')
                    obj.SatAmpDialog=serdes.internal.apps.serdesdesigner.BlockDialog(obj,obj.SatAmpDialog,str);
                    obj.setDialogsAll;
                end
                obj.ElementDialog=obj.SatAmpDialog;
            elseif strcmpi(str,getString(message('serdes:serdesdesigner:DfeCdrHdrDesc')))
                if isempty(obj.DfeCdrDialog)||isprop(obj.DfeCdrDialog,'Children')
                    obj.DfeCdrDialog=serdes.internal.apps.serdesdesigner.BlockDialog(obj,obj.DfeCdrDialog,str);
                    obj.setDialogsAll;
                end
                obj.ElementDialog=obj.DfeCdrDialog;
            elseif strcmpi(str,getString(message('serdes:serdesdesigner:CdrHdrDesc')))
                if isempty(obj.CdrDialog)||isprop(obj.CdrDialog,'Children')
                    obj.CdrDialog=serdes.internal.apps.serdesdesigner.BlockDialog(obj,obj.CdrDialog,str);
                    obj.setDialogsAll;
                end
                obj.ElementDialog=obj.CdrDialog;
            elseif strcmpi(str,getString(message('serdes:serdesdesigner:CtleHdrDesc')))
                if isempty(obj.CtleDialog)||isprop(obj.CtleDialog,'Children')
                    obj.CtleDialog=serdes.internal.apps.serdesdesigner.BlockDialog(obj,obj.CtleDialog,str);
                    obj.setDialogsAll;
                end
                obj.ElementDialog=obj.CtleDialog;
            elseif strcmpi(str,getString(message('serdes:serdesdesigner:TransparentHdrDesc')))
                if isempty(obj.TransparentDialog)||isprop(obj.TransparentDialog,'Children')
                    obj.TransparentDialog=serdes.internal.apps.serdesdesigner.BlockDialog(obj,obj.TransparentDialog,str);
                    obj.setDialogsAll;
                end
                obj.ElementDialog=obj.TransparentDialog;
            elseif strcmpi(str,getString(message('serdes:serdesdesigner:ChannelHdrDesc')))
                if isempty(obj.ChannelDialog)||isprop(obj.ChannelDialog,'Children')
                    obj.ChannelDialog=serdes.internal.apps.serdesdesigner.BlockDialog(obj,obj.ChannelDialog,str);
                    obj.setDialogsAll;
                end
                obj.ElementDialog=obj.ChannelDialog;
            elseif strcmpi(str,getString(message('serdes:serdesdesigner:AnalogOutHdrDesc')))
                if isempty(obj.RcTxDialog)||isprop(obj.RcTxDialog,'Children')
                    obj.RcTxDialog=serdes.internal.apps.serdesdesigner.BlockDialog(obj,obj.RcTxDialog,str);
                    obj.setDialogsAll;
                end
                obj.ElementDialog=obj.RcTxDialog;
            elseif strcmpi(str,getString(message('serdes:serdesdesigner:AnalogInHdrDesc')))
                if isempty(obj.RcRxDialog)||isprop(obj.RcRxDialog,'Children')
                    obj.RcRxDialog=serdes.internal.apps.serdesdesigner.BlockDialog(obj,obj.RcRxDialog,str);
                    obj.setDialogsAll;
                end
                obj.ElementDialog=obj.RcRxDialog;
            elseif strcmpi(str,getString(message('serdes:serdesdesigner:JitterParametersTitle')))
                obj.ElementDialog=obj.JitterDialog;
            end
            obj.setElementDialog();
        end

        function setElementDialog(obj)
            if~isempty(obj.ElementDialog)
                obj.ElementDialog.Panel.Visible='on';
                for i=1:length(obj.DialogsAll)
                    if obj.DialogsAll{i}==obj.ElementDialog
                        obj.Layout.RowHeight{i}='1x';
                    else
                        obj.Layout.RowHeight{i}=0;
                    end
                end
                drawnow;
            end
        end

        function str=get.ElementType(obj)
            if isempty(obj.ElementDialog)
                str='';
            else
                str=obj.ElementDialog.Title.Text;
            end
        end
    end

    methods
        function systemParameterInvalid(obj,data)
            obj.SystemDialog.(data.Name)=data.Value;
        end

        function elementParameterInvalid(obj,data)
            obj.ElementDialog.(data.Name)=data.Value;
        end
    end

    events
SystemParameterChanged
ElementParameterChanged
    end
end
