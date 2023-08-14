classdef GerberExport<handle
    properties
Writer
Services
CurrentService
ServiceToUse
Connectors
CurrentConnector
ConnectorToUse

Parent
ParentLayout

WriterPanel
WriterGridLayout
WriterDialog

ServicesPanel
ServicesGridLayout
ServicesDropDownTitle
ServicesDropDown
ServicesDialog

ConnectorsPanel
ConnectorsGridLayout
ConnectorsDropDownTitle
ConnectorsDropDown
ConnectorsSubDropDownTitle
ConnectorsSubDropDown
ConnectorsDialog
TabGroup
WriterTab
ServicesTab
ConnectorsTab

PCBStackObject

OKBtn
CancelBtn

PrevConnector

        AllConnectorsType={'Coax_RG11',...
        'Coax_RG174',...
        'Coax_RG58',...
        'Coax_RG59',...
        'IPX_Jack_LightHorse',...
        'IPX_Plug_LightHorse',...
        'MMCX_Cinch',...
        'MMCX_Samtec',...
        'SMA',...
        'SMA_Cinch',...
        'SMA_Multicomp',...
        'SMAEdge',...
        'SMAEdge_Cinch',...
        'SMAEdge_Samtec',...
        'SMAEdge_Amphenol',...
        'SMAEdge_Linx',...
        'SMB_Johnson',...
        'SMB_Pasternack',...
        'SMC_Pasternack',...
        'SMCEdge_Pasternack',...
        'Semi_020',...
        'Semi_034',...
        'Semi_047',...
        'Semi_118'};
        AllServices={'AdvancedCircuitsWriter',...
        'CircuitPeopleWriter',...
        'DirtyPCBsWriter',...
        'EuroCircuitsWriter',...
        'GerbLookWriter',...
        'GerberViewerWriter',...
        'MayhewWriter',...
        'OSHParkWriter',...
        'PCBWayWriter',...
        'ParagonWriter',...
        'SeeedWriter',...
        'SunstoneWriter',...
        'ZofzWriter'};
        Update=0
BrowseButton
        Filename='Untitled';
    end
    methods
        function self=GerberExport(Parent)
            self.Parent=Parent;
            self.Parent.HandleVisibility='off';

            createServicesandConnectors(self);
            createGerberExportDialog(self);
        end

        function delete(self)
            self.Parent.delete;
            for i=1:numel(self.ServiceToUse)
                self.ServiceToUse{i}.delete;
            end

            for i=1:numel(self.ConnectorToUse)
                self.ConnectorToUse{i}.delete;
            end

            if~isempty(self.Writer)
                self.Writer.delete;
            end
            if~isempty(self.PCBStackObject)
                self.PCBStackObject.delete;
            end
        end

        function createServicesandConnectors(self)
            self.Writer=PCBWriter;
            self.ServiceToUse={PCBServices.AdvancedCircuitsWriter,...
            PCBServices.CircuitPeopleWriter,...
            PCBServices.DirtyPCBsWriter,...
            PCBServices.EuroCircuitsWriter,...
            PCBServices.GerbLookWriter,...
            PCBServices.GerberViewerWriter,...
            PCBServices.MayhewWriter,...
            PCBServices.OSHParkWriter,...
            PCBServices.PCBWayWriter,...
            PCBServices.ParagonWriter,...
            PCBServices.SeeedWriter,...
            PCBServices.SunstoneWriter,...
            PCBServices.ZofzWriter};
            for i=1:numel(self.ServiceToUse)
                self.ServiceToUse{i}.PostWriteFcn=[];
            end

            self.ConnectorToUse={PCBConnectors.Coax_RG11,...
            PCBConnectors.Coax_RG174,...
            PCBConnectors.Coax_RG58,...
            PCBConnectors.Coax_RG59,...
            PCBConnectors.IPX_Jack_LightHorse,...
            PCBConnectors.IPX_Plug_LightHorse,...
            PCBConnectors.MMCX_Cinch,...
            PCBConnectors.MMCX_Samtec,...
            PCBConnectors.SMA,...
            PCBConnectors.SMA_Cinch,...
            PCBConnectors.SMA_Multicomp,...
            PCBConnectors.SMAEdge,...
            PCBConnectors.SMAEdge_Cinch,...
            PCBConnectors.SMAEdge_Samtec,...
            PCBConnectors.SMAEdge_Amphenol,...
            PCBConnectors.SMAEdge_Linx,...
            PCBConnectors.SMB_Johnson,...
            PCBConnectors.SMB_Pasternack,...
            PCBConnectors.SMC_Pasternack,...
            PCBConnectors.SMCEdge_Pasternack,...
            PCBConnectors.Semi_020,...
            PCBConnectors.Semi_034,...
            PCBConnectors.Semi_047,...
            PCBConnectors.Semi_118};
        end

        function createGerberExportDialog(self)
            self.ParentLayout=uigridlayout(self.Parent);
            self.Parent.Name='Gerber Export';
            self.TabGroup=uitabgroup(self.ParentLayout);

            self.WriterTab=uitab(self.TabGroup,'Title','PCB Writer');
            self.ServicesTab=uitab(self.TabGroup,'Title','PCB Service');
            self.ConnectorsTab=uitab(self.TabGroup,'Title','PCB Connector');
            createWriterPanel(self);
            createServicesPanel(self)
            createConnectorsPanel(self)
            setPosition(self,self.TabGroup,1,[1,4]);
            self.ParentLayout.RowHeight={525};
            self.ParentLayout.ColumnWidth={'fit','fit','fit','fit'};


            self.OKBtn=uibutton(self.ParentLayout,'Text','OK','ButtonPushedFcn',@(src,evt)OKcallback(self));
            self.OKBtn.Layout.Row=2;self.OKBtn.Layout.Column=3;
            self.CancelBtn=uibutton(self.ParentLayout,'Text','Cancel','ButtonPushedFcn',@(src,evt)hideSettingsDialog(self));
            self.CancelBtn.Layout.Row=2;self.CancelBtn.Layout.Column=4;

            self.Parent.Position(3:4)=[450,585];
            self.Parent.Position(1:2)=[100,100];
            hideSettingsDialog(self);
            self.Parent.Resize='off';
            self.Parent.CloseRequestFcn=@(src,evt)hideSettingsDialog(self);
            usedefaultconn=findall(self.WriterPanel,'Type','uicheckbox','tag','UseDefaultConnector');
            valuechanged(self,usedefaultconn);
        end

        function createWriterPanel(self)
            layout=uigridlayout(self.WriterTab);
            self.WriterPanel=uipanel(layout);
            layout.RowHeight={'1x'};
            layout.ColumnWidth={'1x'};
            layout.Padding=[0,0,0,10];
            setPosition(self,self.WriterPanel,1,1);
            self.WriterPanel.Title='PCB Writer';
            self.WriterGridLayout=uigridlayout(self.WriterPanel);
            layout=self.WriterGridLayout;
            layout.RowHeight=[25,25,25,25,25];
            layout.ColumnWidth=[125,16,95,110];

            props=properties(self.Writer);
            props=props(4:end);
            props=[{'Filename'};props];
            uicomp={'edit','checkbox','edit','edit','edit','edit','edit',...
            'dropdown','checkbox'};
            values=getPropertyValues(self,self.Writer);
            self.WriterDialog=em.internal.pcbDesigner.createDialog(self,layout,props,uicomp,...
            '',[{'untitled'},values(4:end)]);
            self.WriterDialog.Tag='Writer';
            setPosition(self,self.WriterDialog,[1,9],[1,4])
            self.BrowseButton=uibutton(self.WriterDialog,'Text','Browse','ButtonPushedFcn',...
            @(src,evt)getFile(self,src,evt),'Tag','ServicesFileBrowse');
            setPosition(self,self.BrowseButton,1,4)
        end

        function value=getPropertyValues(self,obj)
            props=properties(obj);
            props(strcmpi(props,'Files'))=[];
            props(strcmpi(props,'Filename'))=[];
            props(strcmpi(props,'PostWriteFcn'))=[];
            value=cell(1,length(props));
            for i=1:numel(props)
                if strcmpi(props{i},'Soldermask')
                    value{i}={{'none','neither','top','bottom','both'},'both'};
                else
                    value{i}=obj.(props{i});
                end

                specialProperties={'AddThermals','VerticalGroundStrips',...
                'ExtendBoardProfile','FillGroundSide'};

                if any(strcmpi(props{i},specialProperties))
                    value{i}=logical(obj.(props{i}));
                end

            end
        end

        function hideSettingsDialog(self)
            self.Parent.Visible='off';
            updateProperties(self,self.ServicesDropDown,[]);
            updateProperties(self,self.ConnectorsDropDown,[]);
            updateWriterProperties(self)
            updateOkButtonState(self)
            self.notify('DialogClosed');
        end

        function showSettingsDialog(self)
            self.Parent.Visible='on';
            self.Parent.WindowStyle='modal';
        end

        function createServicesPanel(self)
            layout=uigridlayout(self.ServicesTab);
            self.ServicesPanel=uipanel(layout);
            layout.RowHeight={'1x'};
            layout.ColumnWidth={'1x'};
            layout.Padding=[0,0,0,10];

            self.ServicesPanel.Title='PCB Services';
            self.ServicesGridLayout=uigridlayout(self.ServicesPanel);
            layout=self.ServicesGridLayout;
            layout.RowHeight=[25,25,25,25,25];
            layout.ColumnWidth=[150,16,95,110];

            self.ServicesDropDownTitle=uilabel(layout,'Text','Services:','FontWeight','bold',...
            'HorizontalAlignment','right');
            setPosition(self,self.ServicesDropDownTitle,1,1);
            self.AllServices={'AdvancedCircuitsWriter',...
            'CircuitPeopleWriter',...
            'DirtyPCBsWriter',...
            'EuroCircuitsWriter',...
            'GerbLookWriter',...
            'GerberViewerWriter',...
            'MayhewWriter',...
            'OSHParkWriter',...
            'PCBWayWriter',...
            'ParagonWriter',...
            'SeeedWriter',...
            'SunstoneWriter',...
            'ZofzWriter'};
            self.ServicesDropDown=uidropdown(layout,'Items',self.AllServices,...
            'Value',self.AllServices{1},'tag','Services','ValueChangedFcn',@(src,evt)self.updateProperties(src,evt));
            setPosition(self,self.ServicesDropDown,1,[3,4])
            self.CurrentService=self.ServicesDropDown.Value;
            prop=properties(PCBServices.(self.CurrentService));
            prop(strcmpi(prop,'Files'))=[];
            prop(strcmpi(prop,'PostWriteFcn'))=[];
            prop(strcmpi(prop,'Filename'))=[];
            uicomp={'edit','edit','edit','edit','checkbox','edit','checkbox',...
            'edit','edit','checkbox','checkbox','checkbox'};
            units={};
            self.ServicesDialog=em.internal.pcbDesigner.createDialog(self,layout,prop,uicomp,...
            '',getPropertyValues(self,PCBServices.(self.CurrentService)));
            self.ServicesDialog.Tag='Services';
            setPosition(self,self.ServicesDialog,[2,15],[1,4]);
        end

        function getFile(self,src,evt)
            dir=uigetdir('','Select a folder');
            if~(isnumeric(dir)&&dir==0)
                ef=findobj(self.WriterPanel,'Type','uieditfield','tag','Filename');
                ef.Value=dir;
                valuechanged(self,ef);
            end

        end

        function createConnectorsPanel(self)
            layout=uigridlayout(self.ConnectorsTab);
            self.ConnectorsPanel=uipanel(layout);
            layout.RowHeight={'1x'};
            layout.ColumnWidth={'1x'};
            layout.Padding=[0,0,0,10];

            self.ConnectorsPanel.Title='PCB Connectors';

            self.ConnectorsGridLayout=uigridlayout(self.ConnectorsPanel);
            layout=self.ConnectorsGridLayout;
            layout.RowHeight=[25,25,25,25];
            layout.ColumnWidth={150,16,95,'1x'};
            layout.Scrollable='on';

            self.ConnectorsDropDownTitle=uilabel(layout,'Text','Connectors:','FontWeight','bold',...
            'HorizontalAlignment','right');
            setPosition(self,self.ConnectorsDropDownTitle,1,1);
            AllConnectors={'Coax','IPX','MMCX','SMA','SMAEdge','SMB','SMC','Coaxial Cable'};
            self.ConnectorsDropDown=uidropdown(layout,'Items',AllConnectors,...
            'Value',AllConnectors{1},'tag','Connectors','ValueChangedFcn',@(src,evt)self.updateSubDropDown(src,evt));
            setPosition(self,self.ConnectorsDropDown,1,[3,4])
            self.ConnectorsSubDropDownTitle=uilabel(layout,'Text',"Connectors' Type:",'FontWeight','bold',...
            'HorizontalAlignment','right');
            setPosition(self,self.ConnectorsSubDropDownTitle,2,1)
            ddown=updateSubDropDown(self,[],[]);
            self.ConnectorsSubDropDown=ddown;
            self.CurrentConnector=self.ConnectorsSubDropDown.Value;
            setPosition(self,self.ConnectorsSubDropDown,3,[2,3])
            prop=properties(PCBConnectors.(self.CurrentConnector));
            uicomp={'uilabel'};
            uicomps=repmat(uicomp,1,7);

            writeuicomp={'edit'};
            uicomps=[uicomps,repmat(writeuicomp,1,length(prop)-7)];
            specialProperties={'AddThermals','VerticalGroundStrips',...
            'ExtendBoardProfile','FillGroundSide'};
            for i=1:numel(uicomps)
                if any(strcmpi(prop{i},specialProperties))
                    uicomps{i}='checkbox';
                end
            end
            units={};
            self.ConnectorsDialog=em.internal.pcbDesigner.createDialog(self,...
            layout,prop,uicomps,'',getPropertyValues(self,PCBConnectors.(self.CurrentConnector)));
            setPosition(self,self.ConnectorsDialog,[3,14],[1,4]);
        end

        function setViaDiameter(self,val)
            if~isempty(val)
                for i=1:numel(self.ServiceToUse)
                    self.ServiceToUse{i}.DefaultViaDiam=val;
                end
            end
            updateProperties(self,self.ServicesDropDown,-1);
        end

        function setFeedDiameter(self,FeedDiameter)
            props={'PinDiameter','PinHoleDiameter','SignalLineWidth'};
            for i=1:numel(self.ConnectorToUse)
                propsval=properties(self.ConnectorToUse{i});
                if any(strcmpi(propsval,props{1}))
                    self.ConnectorToUse{i}.(props{1})=FeedDiameter;
                elseif any(strcmpi(propsval,props{2}))
                    self.ConnectorToUse{i}.(props{2})=FeedDiameter;
                elseif any(strcmpi(propsval,props{3}))
                    self.ConnectorToUse{i}.(props{3})=FeedDiameter;
                end
            end
            self.Update=1;
            updateProperties(self,self.ConnectorsDropDown,-1);
        end

        function ddown=updateSubDropDown(self,src,evt)
            self.Update=1;
            if~isempty(self.ConnectorsSubDropDown)
                self.ConnectorsSubDropDown.delete;
            end
            switch self.ConnectorsDropDown.Value
            case 'Coax'
                self.ConnectorsSubDropDown=uidropdown(self.ConnectorsGridLayout,'Items',...
                {'Coax_RG11','Coax_RG174','Coax_RG58','Coax_RG59'},...
                'Value','Coax_RG174','tag','Connectors','ValueChangedFcn',...
                @(src,evt)self.updateProperties(self.ConnectorsSubDropDown,evt));
                self.CurrentConnector=self.ConnectorsSubDropDown.Value;

            case 'IPX'
                self.ConnectorsSubDropDown=uidropdown(self.ConnectorsGridLayout,'Items',...
                {'IPX_Jack_LightHorse','IPX_Plug_LightHorse'},'Value','IPX_Jack_LightHorse','tag','Connectors','ValueChangedFcn',...
                @(src,evt)self.updateProperties(self.ConnectorsSubDropDown,evt));
                self.CurrentConnector=self.ConnectorsSubDropDown.Value;

            case 'MMCX'
                self.ConnectorsSubDropDown=uidropdown(self.ConnectorsGridLayout,'Items',...
                {'MMCX_Cinch','MMCX_Samtec'},'Value','MMCX_Cinch','tag','Connectors','ValueChangedFcn',...
                @(src,evt)self.updateProperties(self.ConnectorsSubDropDown,evt));
                if~isempty(src)
                    self.updateProperties(src,evt)
                end
            case 'SMA'
                self.ConnectorsSubDropDown=uidropdown(self.ConnectorsGridLayout,'Items',...
                {'SMA','SMA_Cinch','SMA_Multicomp'},'Value','SMA','tag','Connectors','ValueChangedFcn',...
                @(src,evt)self.updateProperties(self.ConnectorsSubDropDown,evt));

            case 'SMAEdge'
                self.ConnectorsSubDropDown=uidropdown(self.ConnectorsGridLayout,'Items',...
                {'SMAEdge','SMAEdge_Cinch','SMAEdge_Samtec','SMAEdge_Amphenol','SMAEdge_Linx'},...
                'Value','SMAEdge','tag','Connectors','ValueChangedFcn',@(src,evt)self.updateProperties(self.ConnectorsSubDropDown,evt));
                if~isempty(src)
                    self.updateProperties(src,evt)
                end
            case 'SMB'
                self.ConnectorsSubDropDown=uidropdown(self.ConnectorsGridLayout,'Items',...
                {'SMB_Johnson','SMB_Pasternack'},'Value','SMB_Johnson','tag','Connectors','ValueChangedFcn',...
                @(src,evt)self.updateProperties(self.ConnectorsSubDropDown,evt));

            case 'SMC'
                self.ConnectorsSubDropDown=uidropdown(self.ConnectorsGridLayout,'Items',...
                {'SMC_Pasternack','SMCEdge_Pasternack'},'Value','SMC_Pasternack','tag','Connectors','ValueChangedFcn',...
                @(src,evt)self.updateProperties(self.ConnectorsSubDropDown,evt));


            case 'Coaxial Cable'
                self.ConnectorsSubDropDown=uidropdown(self.ConnectorsGridLayout,'Items',...
                {'Semi_020','Semi_034','Semi_047','Semi_118'},'Value','Semi_020','tag','Connectors','ValueChangedFcn',...
                @(src,evt)self.updateProperties(self.ConnectorsSubDropDown,evt));

            end
            setPosition(self,self.ConnectorsSubDropDown,2,[3,4]);
            self.CurrentConnector=self.ConnectorsSubDropDown.Value;
            if~isempty(src)
                self.updateProperties(src,evt)
            end
            self.ConnectorsSubDropDown.Tag='ConnectorsSubDropDown';
            ddown=self.ConnectorsSubDropDown;
            self.ConnectorsPanel.Title=['PCBConnector - ',self.CurrentConnector];
        end

        function updateWriterProperties(self)
            props=properties(self.Writer);
            props=props(4:end);
            self.WriterDialog.delete;
            props=[{'Filename'};props];
            uicomp={'edit','checkbox','edit','edit','edit','edit','edit',...
            'dropdown','checkbox'};
            values=getPropertyValues(self,self.Writer);
            self.WriterDialog=em.internal.pcbDesigner.createDialog(self,self.WriterGridLayout,props,uicomp,...
            '',[{'untitled'},values(4:end)]);
            self.WriterDialog.Tag='Writer';
            setPosition(self,self.WriterDialog,[1,9],[1,4])
            self.WriterPanel.Layout.Row=1;
            self.WriterPanel.Layout.Column=[1,2];
            self.BrowseButton=uibutton(self.WriterDialog,'Text','Browse','ButtonPushedFcn',...
            @(src,evt)getFile(self,src,evt),'Tag','ServicesFileBrowse');
            setPosition(self,self.BrowseButton,1,4);
            updateOkButtonState(self)
        end


        function updateOkButtonState(self)
            uiimageobj=findall(self.Parent,'type','uiimage');
            vis={uiimageobj.Visible};
            if any(strcmpi(vis,'on'))
                self.OKBtn.Enable='off';
            else
                self.OKBtn.Enable='on';
            end
        end

        function updateProperties(self,src,evt)
            if strcmpi(src.Tag,'Services')
                index=(strcmpi(self.ServicesDropDown.Items,self.ServicesDropDown.Value));
                self.CurrentService=self.AllServices{index};
                prop=properties(PCBServices.(self.CurrentService));
                prop(strcmpi(prop,'Files'))=[];
                prop(strcmpi(prop,'PostWriteFcn'))=[];
                prop(strcmpi(prop,'Filename'))=[];
                uicomps={'edit','edit','edit','edit','checkbox','edit','checkbox',...
                'edit','edit','checkbox','checkbox','checkbox'};
                units={};
                self.ServicesDialog.delete;
                self.ServicesDialog=em.internal.pcbDesigner.createDialog(self,...
                self.ServicesGridLayout,prop,uicomps,'',getPropertyValues(self,self.ServiceToUse{index}));
                setPosition(self,self.ServicesDialog,[2,15],[1,4]);



                self.ServicesDialog.Tag='Services';
                self.ServicesPanel.Title=['PCBService - ',self.CurrentService];
            elseif self.Update
                if strcmpi(src.Tag,'ConnectorsSubDropDown')
                    self.CurrentConnector=src.Value;
                end

                index=(strcmpi(self.AllConnectorsType,self.CurrentConnector));
                prop=properties(self.ConnectorToUse{index});
                uicomp={'uilabel'};
                uicomps=repmat(uicomp,1,7);

                writeuicomp={'edit'};
                uicomps=[uicomps,repmat(writeuicomp,1,length(prop)-7)];
                specialProperties={'AddThermals','VerticalGroundStrips',...
                'ExtendBoardProfile','FillGroundSide'};
                for i=1:numel(uicomps)
                    if any(strcmpi(prop{i},specialProperties))
                        uicomps{i}='checkbox';
                    end
                end
                units={};
                self.ConnectorsDialog.delete;
                self.ConnectorsDialog=em.internal.pcbDesigner.createDialog(self,...
                self.ConnectorsGridLayout,prop,uicomps,'',getPropertyValues(self,self.ConnectorToUse{index}));
                setPosition(self,self.ConnectorsDialog,[3,14],[1,4]);
                self.ConnectorsDialog.Tag='Connectors';
                self.ConnectorsPanel.Title=['PCBConnector - ',self.CurrentConnector];
            end

            updateOkButtonState(self)
        end

        function valuechanged(self,src,evt)
            if strcmpi(src.Tag,'PostWriteFcn')
                val=str2func(src.Value);
            else
                try
                    val=eval(src.Value);
                catch me
                    val=src.Value;
                end
            end
            if strcmpi(src.Parent.Tag,'Services')
                index=find(strcmpi(self.ServicesDropDown.Items,self.CurrentService));
                exclamationmark=findobj(self.ServicesPanel,'type','uiimage','tag',src.Tag);
                editfield=findobj(self.ServicesPanel,'type','uieditfield','tag',src.Tag);
                if isempty(editfield)
                    checkboxobj=findobj(self.ServicesPanel,'type','uicheckbox','tag',src.Tag);
                    checkboxobj.Value=logical(val);
                    self.ServiceToUse{index}.(src.Tag)=logical(val);
                else
                    try
                        self.ServiceToUse{index}.(src.Tag)=val;
                        editfield.BackgroundColor=[1,1,1];
                        editfield.FontColor=[0,0,0];
                        exclamationmark.Visible='off';
                    catch me

                        editfield.BackgroundColor=[0.999,0.9,0.9];
                        editfield.FontColor=[1,0,0];
                        exclamationmark.Visible='on';
                        exclamationmark.Tooltip=me.message;

                    end
                end
            elseif strcmpi(src.Parent.Tag,'Writer')

                exclamationmark=findobj(self.WriterPanel,'type','uiimage','tag',src.Tag);
                editfield=findobj(self.WriterPanel,'type','uieditfield','tag',src.Tag);
                if isempty(editfield)
                    checkboxobj=findobj(self.WriterPanel,'type','uicheckbox','tag',src.Tag);
                    dropdownobj=findobj(self.WriterPanel,'type','uidropdown','tag',src.Tag);
                    if~isempty(checkboxobj)
                        checkboxobj.Value=logical(val);
                        self.Writer.(src.Tag)=logical(val);
                        if strcmpi(src.Tag,'UseDefaultConnector')
                            if src.Value
                                self.ConnectorsPanel.Enable='off';
                                self.PrevConnector.Type=self.ConnectorsDropDown.Value;
                                self.PrevConnector.SubType=self.ConnectorsSubDropDown.Value;
                                [self.CurrentConnector,conntype]=getDefaultConnector(self);
                                if strcmpi(conntype,'pinhole')
                                    self.ConnectorsDropDown.Value='SMA';
                                    self.ConnectorsDropDown.Enable='off';
                                    self.updateSubDropDown(self.ConnectorsDropDown,-1);
                                    self.ConnectorsSubDropDown.Value='SMA';
                                    self.ConnectorsSubDropDown.Enable='off';
                                else
                                    self.ConnectorsDropDown.Value='SMAEdge';
                                    self.ConnectorsDropDown.Enable='off';
                                    self.updateSubDropDown(self.ConnectorsDropDown,-1);
                                    self.ConnectorsSubDropDown.Value='SMAEdge';
                                    self.ConnectorsSubDropDown.Enable='off';
                                end

                            else
                                self.ConnectorsPanel.Enable='on';
                                self.ConnectorsDropDown.Value=self.PrevConnector.Type;
                                self.ConnectorsDropDown.Enable='on';
                                self.updateSubDropDown(self.ConnectorsDropDown,-1);
                                self.ConnectorsSubDropDown.Value=self.PrevConnector.SubType;
                                self.ConnectorsSubDropDown.Enable='on';
                            end
                            updateProperties(self,self.ConnectorsSubDropDown,-1);
                        end
                    else
                        self.Writer.(src.Tag)=val;
                        dropdownobj.Value=val;
                    end
                else
                    try
                        if strcmpi(src.Tag,'Filename')

                            for k=1:numel(self.ServiceToUse)
                                self.ServiceToUse{k}.(src.Tag)=val;
                            end
                        else
                            self.Writer.(src.Tag)=val;
                        end
                        self.Filename=val;
                        editfield.BackgroundColor=[1,1,1];
                        editfield.FontColor=[0,0,0];
                        exclamationmark.Visible='off';
                    catch me

                        editfield.BackgroundColor=[0.999,0.9,0.9];
                        editfield.FontColor=[1,0,0];
                        exclamationmark.Visible='on';
                        exclamationmark.Tooltip=me.message;

                    end
                end
            else
                for i=1:numel(self.ConnectorToUse)
                    true=strcmpi(class(self.ConnectorToUse{i}),class(PCBConnectors.(self.CurrentConnector)));
                    if true
                        idx=i;
                    end
                end

                exclamationmark=findobj(self.ConnectorsPanel,'type','uiimage','tag',src.Tag);
                editfield=findobj(self.ConnectorsPanel,'type','uieditfield','tag',src.Tag);
                if isempty(editfield)
                    checkboxobj=findobj(self.ConnectorsPanel,'type','uicheckbox','tag',src.Tag);
                    checkboxobj.Value=logical(val);
                    self.ConnectorToUse{idx}.(src.Tag)=logical(val);
                else
                    try
                        self.ConnectorToUse{idx}.(src.Tag)=val;
                        editfield.BackgroundColor=[1,1,1];
                        editfield.FontColor=[0,0,0];
                        exclamationmark.Visible='off';
                    catch me

                        editfield.BackgroundColor=[0.999,0.9,0.9];
                        editfield.FontColor=[1,0,0];
                        exclamationmark.Visible='on';
                        exclamationmark.Tooltip=me.message;

                    end
                end

            end

            updateOkButtonState(self)
        end

        function[connector,conntype]=getDefaultConnector(self)
            if isempty(self.PCBStackObject)||~isvalid(self.PCBStackObject)...
                ||~isa(self.PCBStackObject,'pcbStack')
                connector='SMA';
                conntype='pinhole';
            else

                createNewWriterObjWithAntenna(self);
                connector=self.Writer.Design.DefaultConnector;
                connector=strsplit(connector,'.');
                connector=connector{2};
                if strcmpi(connector,'SMA')
                    conntype='pinhole';
                else
                    conntype='edge';
                end
            end
        end

        function createNewWriterObjWithAntenna(self)
            if isempty(self.PCBStackObject)||~isvalid(self.PCBStackObject)...
                ||~isa(self.PCBStackObject,'pcbStack')
                return;
            end
            writerobj=self.Writer;
            newwriter=PCBWriter(self.PCBStackObject);
            props=properties(writerobj);
            props=props(4:end);
            for i=1:numel(props)
                newwriter.(props{i})=writerobj.(props{i});
            end
            writerobj.delete;
            self.Writer=newwriter;
        end

        function OKcallback(self)
            index=find(strcmpi(self.ServicesDropDown.Items,self.CurrentService));
            self.Services=self.ServiceToUse{index};%#ok<*FNDSB>
            for i=1:numel(self.ConnectorToUse)
                true=strcmpi(class(self.ConnectorToUse{i}),class(PCBConnectors.(self.CurrentConnector)));
                if true
                    idx=i;
                end
            end
            self.Connectors=self.ConnectorToUse{idx};
            writerobj=self.Writer;
            writerobj.Writer=self.Services;
            if~writerobj.UseDefaultConnector
                writerobj.Connector=self.Connectors;
            end
            gerberWrite(self,writerobj);
            self.hideSettingsDialog();
        end


        function gerberWrite(self,writerobj)
            try
                gerberWrite(writerobj);
            catch me
                h=errordlg(me.message,'Error','modal');
            end
        end

        function modelChanged(self,evt)
        end

        function setModel(self,model)
        end

        function hideDialog(self)
            self.Parent.Visible='off';
            self.Parent.WindowStyle='normal';
        end

        function setPosition(self,gobj,row,column)
            gobj.Layout.Row=row;
            gobj.Layout.Column=column;
        end
    end

    events
DialogClosed
    end
end