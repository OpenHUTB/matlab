classdef PropertyPanelView<cad.View




    properties
        VariablesManager=cad.VariablesManager;
PropertyPanel
SelectedObjPanels
Parent
PropertyPanelLayout
PropertyPanelAccordion
        DielectricCatalog=DielectricCatalog
        MetalCatalog=MetalCatalog;
        error1=[
        219,219,219,225,219,219,219,219,219,219,219,219,219,219
        219,219,219,219,219,219,219,219,219,219,219,226,219,219
        219,219,219,219,219,219,255,255,219,219,219,219,226,219
        219,219,219,219,219,219,255,255,219,219,219,219,219,219
        219,219,219,219,219,219,255,255,219,219,219,219,219,224
        219,219,219,219,219,219,255,255,219,219,219,219,219,219
        219,219,219,219,219,219,255,255,219,219,219,219,219,219
        219,219,219,219,219,219,255,255,219,219,219,219,219,219
        219,219,219,219,219,219,219,219,219,219,219,219,219,219
        219,219,219,219,219,219,255,255,219,219,219,219,219,219
        219,219,219,219,219,219,219,219,219,219,219,219,219,219
        219,219,219,217,219,219,219,219,219,219,219,219,219,219
        219,219,219,219,219,219,219,219,219,219,219,219,219,219];


        error2=[
        60,60,60,60,60,60,60,60,60,60,60,60,60,60
        60,60,60,60,60,60,60,60,60,60,60,60,60,60
        60,60,60,60,60,60,255,255,60,60,60,60,60,60
        60,60,60,60,60,60,255,255,60,60,60,60,60,60
        60,60,60,60,60,60,255,255,60,60,60,60,60,60
        60,60,60,60,60,60,255,255,60,60,60,60,60,60
        60,60,60,60,60,60,255,255,60,60,60,60,60,60
        60,60,60,60,60,60,255,255,60,60,60,60,60,60
        60,60,60,60,60,60,60,60,60,60,60,60,60,60
        60,60,60,60,60,60,255,255,60,60,60,60,60,60
        60,60,60,60,60,60,60,60,60,60,60,60,60,60
        60,60,60,60,60,60,60,60,60,60,60,60,60,60
        60,60,60,60,60,60,60,60,60,60,60,60,60,60];


        error3=[
        48,48,48,48,48,48,48,48,48,48,48,48,48,48
        48,48,48,48,48,48,48,48,48,48,48,48,48,48
        48,48,48,48,48,48,255,255,48,48,48,48,48,48
        48,48,48,48,48,48,255,255,48,48,48,48,48,48
        48,48,48,48,48,48,255,255,48,48,48,48,48,48
        48,48,48,48,48,48,255,255,48,48,48,48,48,48
        48,48,48,48,48,48,255,255,48,48,48,48,48,48
        48,48,48,48,48,48,255,255,48,48,48,48,48,48
        48,48,48,48,48,48,48,48,48,48,48,48,48,48
        48,48,48,48,48,48,255,255,48,48,48,48,48,48
        48,48,48,48,48,48,48,48,48,48,48,48,48,48
        48,48,48,48,48,48,48,48,48,48,48,48,48,48
        48,48,48,48,48,48,48,48,48,48,48,48,48,48];

ErrorCData
ShapeView
LayerView
FeedView
LoadView
ViaView
PCBAntennaView
LayerTreeView
    end

    methods
        function self=PropertyPanelView(Parent)
            self.Parent=Parent;
            self.MetalCatalog=MetalCatalog;
            self.DielectricCatalog=DielectricCatalog;
            self.ErrorCData=zeros(13,14,3,'uint8');
            self.ErrorCData(:,:,1)=self.error1;
            self.ErrorCData(:,:,2)=self.error2;
            self.ErrorCData(:,:,3)=self.error3;
            initializePanel(self);
        end

        function initializePanel(self)



            self.Parent.Scrollable='off';
            layout=uigridlayout(self.Parent,[1,1]);
            layout.RowHeight={'1x'};
            layout.ColumnWidth={'1x'};
            layout.Padding=[0,0,0,0];


            self.PropertyPanelLayout=layout;
            self.PropertyPanelAccordion=matlab.ui.container.internal.Accordion('Parent',layout);
        end

        function clearPanel(self)
            for i=1:numel(self.SelectedObjPanels)
                self.SelectedObjPanels(i).Parent=[];
            end
            self.SelectedObjPanels=[];
        end

        function updateView(self,vm)





            selectedInfo=vm.getSelectedObjInfo();
            clearPanel(self);

            if isempty(selectedInfo)

                return;
            end
            args=selectedInfo{3};
            Type=selectedInfo{1};
            modelInfo=selectedInfo{4};

            arr=cell2mat(arrayfun(@(x)~isempty(x{1}),args,'UniformOutput',false));
            args=args(arr);

            idx=[];
            for i=1:numel(modelInfo.LayerInfo)
                if strcmpi(modelInfo.LayerInfo{i}.MaterialType,'metal')
                    idx=[idx,i];
                end
            end
            if~isempty(idx)
                metalLayers=modelInfo.LayerInfo(idx);
            else
                metalLayers={};
            end
            for i=1:numel(args)

                if~isempty(args)
                    if strcmpi(Type{i},'LayerTree')
                        args{i}.Metal=args{i}.Args;
                        args{i}.Name='Layers';
                        args{i}.Id=0;
                    end
                    pan=findView(self,Type{i},args{i});
                    if isempty(pan)
                        pan=generatePropertyPanel(self,Type{i},args{i},metalLayers);
                        addPanelView(self,pan,Type{i},args{i});
                    else

                        updatepanel(self,pan,args{i},metalLayers);
                        pan.Parent=self.PropertyPanelAccordion;
                    end
                    if~isempty(pan)
                        self.SelectedObjPanels=[self.SelectedObjPanels,pan];
                    end
                end
            end

        end

        function layersUpdated(self,inf)

        end

        function addPanelView(self,pan,type,info)
            fieldname=[type,num2str(info.Id)];
            if strcmpi(type,'Shape')
                if isfield(self.ShapeView,fieldname)&&~isempty(self.ShapeView.(fieldname))...
                    &&isvalid(self.ShapeView.(fieldname))
                    self.ShapeView.(fieldname).delete;
                    self.ShapeView.(fieldname)=pan;
                else
                    self.ShapeView.(fieldname)=pan;
                end
            elseif strcmpi(type,'Layer')
                if isfield(self.LayerView,fieldname)&&~isempty(self.LayerView.(fieldname))...
                    &&isvalid(self.LayerView.(fieldname))
                    self.LayerView.(fieldname).delete;
                    self.LayerView.(fieldname)=pan;
                else
                    self.LayerView.(fieldname)=pan;
                end
            elseif strcmpi(type,'Feed')
                if isfield(self.FeedView,fieldname)&&~isempty(self.FeedView.(fieldname))...
                    &&isvalid(self.FeedView.(fieldname))
                    self.FeedView.(fieldname).delete;
                    self.FeedView.(fieldname)=pan;
                else
                    self.FeedView.(fieldname)=pan;
                end
            elseif strcmpi(type,'Via')
                if isfield(self.ViaView,fieldname)&&~isempty(self.ViaView.(fieldname))...
                    &&isvalid(self.ViaView.(fieldname))
                    self.ViaView.(fieldname).delete;
                    self.ViaView.(fieldname)=pan;
                else
                    self.ViaView.(fieldname)=pan;
                end
            elseif strcmpi(type,'Load')
                if isfield(self.LoadView,fieldname)&&~isempty(self.LoadView.(fieldname))...
                    &&isvalid(self.LoadView.(fieldname))
                    self.LoadView.(fieldname).delete;
                    self.LoadView.(fieldname)=pan;
                else
                    self.LoadView.(fieldname)=pan;
                end
            elseif strcmpi(type,'PCBAntenna')
                if isfield(self.PCBAntennaView,fieldname)&&~isempty(self.PCBAntennaView.(fieldname))...
                    &&isvalid(self.PCBAntennaView.(fieldname))
                    self.PCBAntennaView.(fieldname).delete;
                    self.PCBAntennaView.(fieldname)=pan;
                else
                    self.PCBAntennaView.(fieldname)=pan;
                end
            elseif strcmpi(type,'LayerTree')
                if isfield(self.LayerTreeView,fieldname)&&~isempty(self.LayerTreeView.(fieldname))...
                    &&isvalid(self.LayerTreeView.(fieldname))
                    self.LayerTreeView.(fieldname).delete;
                    self.LayerTreeView.(fieldname)=pan;
                else
                    self.LayerTreeView.(fieldname)=pan;
                end
            end
        end

        function deletePanelView(self,type,info)
            fieldname=[type,num2str(info.Id)];
            if strcmpi(type,'Shape')
                if isfield(self.ShapeView,fieldname)&&~isempty(self.ShapeView.(fieldname))...
                    &&isvalid(self.ShapeView.(fieldname))
                    self.ShapeView.(fieldname).delete;
                    self.ShapeView.(fieldname)=[];
                else
                    self.ShapeView.(fieldname)=[];
                end
            elseif strcmpi(type,'Layer')
                if isfield(self.LayerView,fieldname)&&~isempty(self.LayerView.(fieldname))...
                    &&isvalid(self.LayerView.(fieldname))
                    self.LayerView.(fieldname).delete;
                    self.LayerView.(fieldname)=[];
                else
                    self.LayerView.(fieldname)=[];
                end
            elseif strcmpi(type,'Feed')
                if isfield(self.FeedView,fieldname)&&~isempty(self.FeedView.(fieldname))...
                    &&isvalid(self.FeedView.(fieldname))
                    self.FeedView.(fieldname).delete;
                    self.FeedView.(fieldname)=[];
                else
                    self.FeedView.(fieldname)=[];
                end
            elseif strcmpi(type,'Via')
                if isfield(self.ViaView,fieldname)&&~isempty(self.ViaView.(fieldname))...
                    &&isvalid(self.ViaView.(fieldname))
                    self.ViaView.(fieldname).delete;
                    self.ViaView.(fieldname)=[];
                else
                    self.ViaView.(fieldname)=[];
                end
            elseif strcmpi(type,'Load')
                if isfield(self.LoadView,fieldname)&&~isempty(self.LoadView.(fieldname))...
                    &&isvalid(self.LoadView.(fieldname))
                    self.LoadView.(fieldname).delete;
                    self.LoadView.(fieldname)=[];
                else
                    self.LoadView.(fieldname)=[];
                end
            elseif strcmpi(type,'PCBAntenna')
                if isfield(self.PCBAntennaView,fieldname)&&~isempty(self.PCBAntennaView.(fieldname))...
                    &&isvalid(self.PCBAntennaView.(fieldname))
                    self.PCBAntennaView.(fieldname).delete;
                    self.PCBAntennaView.(fieldname)=[];
                else
                    self.PCBAntennaView.(fieldname)=[];
                end
            elseif strcmpi(type,'LayerTree')
                if isfield(self.LayerTreeView,fieldname)&&~isempty(self.LayerTreeView.(fieldname))...
                    &&isvalid(self.LayerTreeView.(fieldname))
                    self.LayerTreeView.(fieldname).delete;
                    self.LayerTreeView.(fieldname)=[];
                else
                    self.LayerTreeView.(fieldname)=[];
                end

            end
        end

        function updatepanel(self,panel,info,metalLayers)
            if strcmpi(info.Type,'PCBAntenna')
                panel.Title=['PCBAntenna - ',info.Name];
            else
                panel.Title=info.Name;
            end


            nameeditfield=findobj(panel,'tag','Name','type','uieditfield');
            if~isempty(nameeditfield)
                nameeditfield.Value=info.Name;

                nameeditfield.UserData.PreviousValue=info.Name;
            end

            args=info.Args;

            f=fields(args);
            for i=1:numel(f)
                if any(strcmpi(f{i},{'Axis'}))
                    continue;
                end
                if strcmpi(info.Type,'Layer')&&strcmpi(f{i},'Color')
                    gobj=findobj(panel,'tag',f{i},'type','uiimage');
                else
                    gobj=findobj(panel,'tag',f{i},'-not','type','uiimage');
                end
                if isempty(gobj)
                    continue;
                end
                if strcmpi(info.Type,'Layer')&&strcmpi(f{i},'Color')
                    val=info.Args.('Color');
                    if~isempty(gobj)
                        gobj.ImageSource=generateColorIcon(self,info.Args.Color);
                    end
                    gobj.UserData.PreviousValue=info.Args.('Color');
                elseif strcmpi(info.Type,'Layer')&&strcmpi(f{i},'Type')
                    val=info.('MaterialType');
                    if~isempty(gobj)
                        gobj.Text=val;
                    end
                    gobj.UserData.PreviousValue=info.('MaterialType');
                elseif strcmpi(info.Type,'LayerTree')&&strcmpi(f{i},'Type')
                    val=info.Metal.Type;
                    gobj.Value=val;
                elseif strcmpi(info.Type,'Layer')&&strcmpi(f{i},'DielectricType')
                    val=info.Args.DielectricType;
                    if~isempty(gobj)
                        gobj.Value=val;
                    end
                    gobj.UserData.PreviousValue=info.Args.DielectricType;
                elseif strcmpi(info.Type,'Layer')&&strcmpi(f{i},'Overlay')
                    val=info.Args.Overlay;
                    if~isempty(gobj)
                        gobj.Value=logical(val);
                    end
                    gobj.UserData.PreviousValue=info.Args.Overlay;
                elseif strcmpi(info.Type,'Layer')&&strcmpi(f{i},'Color')
                    val=info.Args.Color;
                    cdata=generateColorIcon(self,val);
                    if~isempty(gobj)
                        gobj.ImageSource=cdata;
                    end
                    gobj.UserData.PreviousValue=info.Args.Color;
                elseif(strcmpi(info.Type,'Feed')||strcmpi(info.Type,'Via'))&&(strcmpi(f{i},'StartLayer')||strcmpi(f{i},'StopLayer'))
                    gobj.ItemsData=metalLayers;
                    gobj.Items=cellfun(@(x)x.Name,metalLayers,'UniformOutput',false);
                    gobj.Value=info.Args.(f{i});
                    gobj.UserData.LayerValue=info.Args.(f{i});
                    gobj.UserData.PreviousValue=info.Args.(f{i});
                elseif(strcmpi(info.Type,'Load'))&&(strcmpi(f{i},'StartLayer')||strcmpi(f{i},'StopLayer'))
                    if(strcmpi(f{i},'StartLayer'))
                        gobj.ItemsData=metalLayers;
                        gobj.Items=cellfun(@(x)x.Name,metalLayers,'UniformOutput',false);
                        gobj.Value=info.Args.(f{i});
                        gobj.UserData.LayerValue=info.Args.(f{i});
                        gobj.UserData.PreviousValue=info.Args.(f{i});
                    else
                        continue;
                    end
                elseif(strcmpi(info.Type,'PCBAntenna')||strcmpi(info.Type,'FeedTree')||strcmpi(info.Type,'ViaTree'))&&(strcmpi(f{i},'FeedViaModel'))
                    gobj.Value=info.Args.(f{i});
                else
                    rmerror(self,findErrorImage(self,gobj));
                    rmerror(self,gobj);
                    val=info.Args.(f{i});

                    if~strcmpi(f{i},'Vertices')
                        if~(isstring(val)||ischar(val))

                            if numel(val)>1
                                val=mat2str(val);
                            else
                                val=num2str(val);
                            end
                        end
                    end
                    if~isempty(gobj)
                        if strcmpi(gobj.Type,'uitable')
                            val=val(:,1:2);
                            tmp=mat2cell(val,ones(1,size(val,1)),ones(1,size(val,2)));
                            gobj.Data=[tmp;{[],[]};{[],[]}];
                        else
                            gobj.Value=val;
                        end
                    end
                    if isfield(info,'PropertyValueMap')&&isfield(info.PropertyValueMap,f{i})&&...
                        ~isempty(info.PropertyValueMap.(f{i}))
                        gobj.UserData.PreviousValue=info.PropertyValueMap.(f{i});
                    else
                        gobj.UserData.PreviousValue=info.Args.(f{i});
                    end
                end

            end
        end

        function opObj=findView(self,type,info)
            opObj=[];
            fieldname=[type,num2str(info.Id)];
            if strcmpi(type,'Shape')
                if isfield(self.ShapeView,fieldname)&&~isempty(self.ShapeView.(fieldname))...
                    &&isvalid(self.ShapeView.(fieldname))
                    opObj=self.ShapeView.(fieldname);
                else
                    opObj=[];
                end
            elseif strcmpi(type,'Layer')
                if isfield(self.LayerView,fieldname)&&~isempty(self.LayerView.(fieldname))...
                    &&isvalid(self.LayerView.(fieldname))
                    opObj=self.LayerView.(fieldname);
                else
                    opObj=[];
                end
            elseif strcmpi(type,'Feed')
                if isfield(self.FeedView,fieldname)&&~isempty(self.FeedView.(fieldname))...
                    &&isvalid(self.FeedView.(fieldname))
                    opObj=self.FeedView.(fieldname);
                else
                    opObj=[];
                end
            elseif strcmpi(type,'Via')
                if isfield(self.ViaView,fieldname)&&~isempty(self.ViaView.(fieldname))...
                    &&isvalid(self.ViaView.(fieldname))
                    opObj=self.ViaView.(fieldname);
                else
                    opObj=[];
                end
            elseif strcmpi(type,'Load')
                if isfield(self.LoadView,fieldname)&&~isempty(self.LoadView.(fieldname))...
                    &&isvalid(self.LoadView.(fieldname))
                    opObj=self.LoadView.(fieldname);
                else
                    opObj=[];
                end
            elseif strcmpi(type,'PCBAntenna')
                if isfield(self.PCBAntennaView,fieldname)&&~isempty(self.PCBAntennaView.(fieldname))...
                    &&isvalid(self.PCBAntennaView.(fieldname))
                    opObj=self.PCBAntennaView.(fieldname);
                else
                    opObj=[];
                end
            elseif strcmpi(type,'LayerTree')
                if isfield(self.LayerTreeView,fieldname)&&~isempty(self.LayerTreeView.(fieldname))...
                    &&isvalid(self.LayerTreeView.(fieldname))
                    opObj=self.LayerTreeView.(fieldname);
                else
                    opObj=[];
                end

            end
        end


        function opObj=findObj(self,type,info)
            opObj=[];
            if~isempty(self.SelectedObjPanels)
                data=[self.SelectedObjPanels.UserData];
                types={data.Type};
                idx=strcmpi(types,type);
                filterobj=self.SelectedObjPanels(idx);
                if isempty(filterobj)
                    return;
                end
                data=[filterobj.UserData];
                Ids=[data.Id];
                idx=Ids==info.Id;
                filterobj=filterobj(idx);
                if isempty(filterobj)
                    return;
                end

                opObj=filterobj;
            end
        end
        function pan=generatePropertyPanel(self,Type,info,metalLayers)
            pan=[];
            if strcmpi(Type,{'Shape'})||strcmpi(Type,{'Layer'})||strcmpi(Type,{'Feed'})||...
                strcmpi(Type,{'Via'})||strcmpi(Type,{'Load'})||strcmpi(Type,{'PCBAntenna'})||...
                strcmpi(Type,{'FeedTree'})||strcmpi(Type,{'ViaTree'})||strcmpi(Type,{'LayerTree'})



                args=info.Args;

                pan=matlab.ui.container.internal.AccordionPanel('Parent',self.PropertyPanelAccordion);
                sz=numel(fields(args));
                u=uigridlayout(pan,[sz+1,2]);

                Data.Id=info.Id;
                Data.Type=Type;
                pan.UserData=Data;
                rownum=0;
                if~any(strcmpi(Type,{'FeedTree','ViaTree','LayerTree'}))
                    nametext=uilabel(u,'text','Name','HorizontalAlignment','Right');
                    nametext.Layout.Row=1;
                    nametext.Layout.Column=1;
                    Data.Property='Name';
                    Data.PreviousValue=info.Name;
                    nameerrorimage=uiimage(u,'ImageSource',self.ErrorCData,'Tag','Name','UserData',Data,'Visible','off');
                    nameerrorimage.Layout.Row=1;
                    nameerrorimage.Layout.Column=2;
                    nameedit=uieditfield(u,'Value',info.Name,'UserData',Data,...
                    'valueChangedFcn',@(src,evt)valueChanged(self,src,evt),'tag','Name',...
                    'HorizontalAlignment','Left');
                    nameedit.Layout.Row=1;
                    nameedit.Layout.Column=3;
                    rownum=1;
                end
                if strcmpi(Type,'PCBAntenna')
                    pan.Title=['PCBAntenna - ',info.Name];
                else
                    pan.Title=info.Name;
                end
                f=fields(args);

                rowweights=cellfun(@(x)25,[f;{'name'}],'UniformOutput',false);
                u.RowHeight=rowweights;
                u.ColumnWidth={'fit',16,'1x'};

                for i=1:numel(f)
                    if any(strcmpi(f{i},{'Axis'}))
                        continue;
                    end
                    errorimagepresent=0;
                    if any(strcmpi(Type,{'Load','Feed','Via'}))&&strcmpi(f{i},'Diameter')
                        continue;
                    end
                    if(strcmpi(Type,'Load'))&&(strcmpi(f{i},'StartLayer')||strcmpi(f{i},'StopLayer'))
                        if(strcmpi(f{i},'StartLayer'))
                            rownum=rownum+1;
                            txtobj=uilabel(u,'text','Layer','HorizontalAlignment','Right');
                            txtobj.Layout.Row=rownum;
                            txtobj.Layout.Column=1;
                            Data.Property=f{i};
                        else
                            continue;
                        end
                    else
                        rownum=rownum+1;
                        txtobj=uilabel(u,'text',f{i},'HorizontalAlignment','Right');
                        if strcmpi(f{i},'Impedance')
                            txtobj.Text=[txtobj.Text,' (Ohm)'];
                        elseif strcmpi(f{i},'Frequency')
                            txtobj.Text=[txtobj.Text,' (Hz)'];
                        end
                        txtobj.Layout.Row=rownum;
                        txtobj.Layout.Column=1;
                        Data.Property=f{i};
                    end

                    if strcmpi(Type,'PCBAntenna')||strcmpi(Type,'FeedTree')
                        Data.NumFeeds=info.NumFeeds;
                    end
                    if strcmpi(Type,'Shape')&&strcmpi(f{i},'Vertices')

                        data=args.(f{i});
                        data=data(:,1:2);
                        data=mat2cell(data,ones(1,size(data,1)),ones(1,size(data,2)));
                        data=[data;{[],[]};{[],[]}];
                        Data.PreviousValue=args.(f{i});
                        edtObj=uitable(u,'Data',data,'UserData',Data,'Tag',f{i},...
                        'ColumnEditable',true,'ColumnName',{'x','y'},'CellEditCallback',...
                        @(src,evt)valueChanged(self,src,evt),'ColumnFormat',{'numeric','numeric'},...
                        'ColumnWidth',{50,50});
                        errorObj=uiimage(u,'ImageSource',self.ErrorCData,'Visible','off','tag',f{i},'UserData',Data);
                        errorimagepresent=1;
                    elseif strcmpi(Type,'LayerTree')&&strcmpi(f{i},'Type')
                        mc=self.MetalCatalog;
                        edtObj=uidropdown(u,'Items',[{'Custom'};mc.Materials{:,1}],...
                        'UserData',Data,'Value',args.(f{i}),...
                        'valueChangedFcn',@(src,evt)valueChanged(self,src,evt),'tag',f{i});
                    elseif(strcmpi(Type,'PCBAntenna')||strcmpi(Type,'FeedTree')||strcmpi(Type,'ViaTree'))&&strcmpi(f{i},'FeedViaModel')
                        edtObj=uidropdown(u,'Items',{'strip','square','hexagon','octagon'},...
                        'UserData',Data,'Value',args.(f{i}),...
                        'valueChangedFcn',@(src,evt)valueChanged(self,src,evt),'tag',f{i});
                    elseif strcmpi(Type,'Layer')&&strcmpi(f{i},'type')
                        edtObj=uilabel(u,'Text',args.(f{i}),'HorizontalAlignment','Left','tag',f{i});
                    elseif strcmpi(Type,'Layer')&&strcmpi(f{i},'DielectricType')
                        dc=self.DielectricCatalog;
                        edtObj=uidropdown(u,'Items',[{'Custom'};dc.Materials{:,1}],...
                        'UserData',Data,'Value',args.(f{i}),...
                        'valueChangedFcn',@(src,evt)valueChanged(self,src,evt),'tag',f{i});
                    elseif strcmpi(Type,'Layer')&&strcmpi(f{i},'Overlay')
                        edtObj=uicheckbox(u,'text','','userData',Data,'Value',args.(f{i}),'Tag',f{i},...
                        'valueChangedFcn',@(src,evt)valueChanged(self,src,evt));
                    elseif strcmpi(Type,'Layer')&&strcmpi(f{i},'Color')
                        edtObj=uiimage(u,'ImageSource',self.generateColorIcon(args.(f{i})),...
                        'userData',Data,'Tag',f{i},'ScaleMethod','fill',...
                        'ImageClickedFcn',@(src,evt)colorClicked(self,src,evt),...
                        'horizontalAlignment','left');
                        edtObj.Tooltip='Click to change color';
                        u.RowHeight{i+1}=20;
                    elseif(strcmpi(Type,'Feed')||strcmpi(Type,'Via'))&&(strcmpi(f{i},'StartLayer')||strcmpi(f{i},'StopLayer'))
                        layerinf=args.(f{i});
                        Data.LayerValue=layerinf;
                        edtObj=uidropdown(u,'Items',cellfun(@(x)x.Name,metalLayers,'UniformOutput',false),...
                        'UserData',Data,'Value',layerinf.Name,...
                        'valueChangedFcn',@(src,evt)valueChanged(self,src,evt),'tag',f{i});
                        edtObj.ItemsData=metalLayers;
                    elseif(strcmpi(Type,'Load'))&&(strcmpi(f{i},'StartLayer')||strcmpi(f{i},'StopLayer'))
                        if(strcmpi(f{i},'StartLayer'))
                            layerinf=args.(f{i});
                            Data.LayerValue=layerinf;
                            edtObj=uidropdown(u,'Items',cellfun(@(x)x.Name,metalLayers,'UniformOutput',false),...
                            'UserData',Data,'Value',layerinf.Name,...
                            'valueChangedFcn',@(src,evt)valueChanged(self,src,evt),'tag',f{i});
                            edtObj.ItemsData=metalLayers;
                        else
                        end
                    else
                        errorimagepresent=1;
                        val=args.(f{i});
                        if~(isstring(val)||ischar(val))

                            if numel(val)>1
                                val=mat2str(val);
                            else
                                val=num2str(val);
                            end
                        end
                        Data.PreviousValue=args.(f{i});
                        errorObj=uiimage(u,'ImageSource',self.ErrorCData,'Visible','off','tag',f{i},'UserData',Data);
                        edtObj=uieditfield(u,'Value',val,'UserData',Data,...
                        'valueChangedFcn',@(src,evt)valueChanged(self,src,evt),'tag',f{i});
                    end
                    if errorimagepresent
                        errorObj.Layout.Row=rownum;
                        errorObj.Layout.Column=2;
                    end
                    edtObj.Layout.Row=rownum;
                    edtObj.Layout.Column=3;
                    if strcmpi(Type,'Shape')&&strcmpi(f{i},'Vertices')
                        numrows=size(edtObj.Data,1);
                        height=numrows*20;
                        rowsreq=ceil((height+10)/(25+10));
                        edtObj.Layout.Row=[rownum,rownum+rowsreq];
                        rownum=rownum+rowsreq+1;
                    end
                end
            end
        end

        function colorClicked(self,src,evt)
            prevcolor=[src.ImageSource(1,1,1),src.ImageSource(1,1,2),src.ImageSource(1,1,3)];
            finColor=uisetcolor(prevcolor);
            data.PreviousValue=prevcolor;
            data.Value=finColor;
            if~all(finColor==prevcolor)
                valueChanged(self,src,data);
            end
        end
        function valueChanged(self,src,evt)
            Data=src.UserData;
            errored=0;
            if strcmpi(Data.Property,'Name')
                try
                    validateMLname(self,evt.Value,'Name');
                    Data.Value=evt.Value;
                    rmerror(self,findErrorImage(self,src));
                    rmerror(self,src);
                catch me
                    errored=1;
                    errorImage=findErrorImage(self,src);
                    errorImage.Tooltip=me.message;
                    seterror(self,errorImage);
                    seterror(self,src);
                end
            elseif strcmpi(Data.Property,'Overlay')||strcmpi(Data.Property,'Color')
                Data.PreviousValue=evt.PreviousValue;
                Data.Value=evt.Value;
            elseif strcmpi(Data.Property,'StartLayer')||strcmpi(Data.Property,'StopLayer')
                Data.PreviousValue=Data.LayerValue;
                Data.Value=src.ItemsData{src.Value.Id==[cell2mat(cellfun(@(x)x.Id,src.ItemsData,'UniformOutput',false))]};
            elseif any(strcmpi(Data.Property,{'DielectricType','FeedViaModel'}))||(strcmpi(Data.Property,{'Type'})&&strcmpi(Data.Type,'LayerTree'))
                Data.PreviousValue=evt.PreviousValue;
                Data.Value=evt.Value;
            else
                try
                    if any(strcmpi(src.Tag,{'FeedVoltage','FeedPhase'}))



                        [funchandle,depvar,opval]=self.VariablesManager....
                        parseExpression(evt.Value);


                        self.validateArgs(opval,src.Tag);
                        evt=[];
                        if isempty(depvar)
                            evt.Value=num2str(opval);
                        else
                            evt.Value=funchandle;
                        end
                    elseif any(strcmpi(src.Tag,{'Vertices'}))
                        if strcmpi(evt.EditData,'')
                            src.Data{evt.Indices(1),evt.Indices(2)}=[];
                        end
                        if imag(src.Data{evt.Indices(1),evt.Indices(2)})==0





                            val=src.Data{evt.Indices(1),evt.Indices(2)};
                            if val<0
                                src.Data{evt.Indices(1),evt.Indices(2)}=abs(val)*-1;
                            else
                                src.Data{evt.Indices(1),evt.Indices(2)}=abs(val);
                            end
                        end
                        valobj=src.Data;
                        self.validateArgs(valobj,src.Tag);
                    elseif strcmpi(src.Tag,'ViaDiameter')||...
                        strcmpi(src.Tag,'FeedDiameter')||strcmpi(src.Tag,'Thickness')||...
                        strcmpi(src.Tag,'Conductivity')||...
                        strcmpi(src.Tag,'Length')||strcmpi(src.Tag,'Width')||...
                        strcmpi(src.Tag,'Radius')||strcmpi(src.Tag,'Diameter')...
                        ||strcmpi(src.Tag,'EpsilonR')||strcmpi(src.Tag,'center')...
                        ||strcmpi(src.Tag,'angle')||strcmpi(src.Tag,'LossTangent')
                        [funchandle,depvar,opval]=self.VariablesManager....
                        parseExpression(evt.Value);


                        self.validateArgs(opval,src.Tag);
                        evt=[];
                        if isempty(depvar)
                            evt.Value=num2str(opval);
                        else
                            evt.Value=funchandle;
                        end
                    elseif strcmpi(src.Tag,'Transparency')
                        [~,depvars,opval]=self.VariablesManager....
                        parseExpression(evt.Value);
                        if~isempty(depvars)
                            error(message('antenna:pcbantennadesigner:ValueCannotBeVariable','Transparency'));
                        end
                        self.validateArgs(opval,src.Tag);
                    elseif strcmpi(src.Tag,'Impedance')||strcmpi(src.Tag,'Frequency')
                        [funchandle,depvar,opval]=self.VariablesManager....
                        parseExpression(evt.Value,1);
                        self.validateArgs(opval,src.Tag);
                        evt=[];
                        if isempty(depvar)
                            evt.Value=num2str(opval);
                        else
                            evt.Value=funchandle;
                        end






                    elseif strcmpi(src.Tag,'MajorAxis')||strcmpi(src.Tag,'MinorAxis')
                        if strcmpi(src.Tag,'MajorAxis')
                            editobj=findobj(src.Parent,'tag','MinorAxis','type','uieditfield');
                        else
                            editobj=findobj(src.Parent,'tag','MajorAxis','type','uieditfield');
                        end
                        [funchandle,depvar,opval]=self.VariablesManager....
                        parseExpression(evt.Value);
                        [~,~,opval2]=self.VariablesManager....
                        parseExpression(editobj.Value);
                        self.validateArgs(opval,src.Tag,opval2);
                        evt=[];
                        if isempty(depvar)
                            evt.Value=num2str(opval);
                        else
                            evt.Value=funchandle;
                        end


                    end
                    if any(strcmpi(src.Tag,{'Vertices'}))
                        Data.Value=[cell2mat(src.Data(:,1)),...
                        cell2mat(src.Data(:,2))];
                        if size(src.Data,2)==2



                            Data.Value=[Data.Value,zeros(size(Data.Value,1),1)];
                        end
                    else



                        if isa(evt.Value,'function_handle')
                            Data.Value=evt.Value;
                        else
                            Data.Value=str2num(evt.Value);
                        end

                    end
                    rmerror(self,findErrorImage(self,src));
                    rmerror(self,src);
                catch me
                    errored=true;
                    errorimage=findErrorImage(self,src);
                    errorimage.Tooltip=me.message;
                    seterror(self,errorimage);
                    seterror(self,src);
                end
            end
            if~errored
                self.notify('ValueChanged',cad.events.ValueChangedEventData(Data));
            end
        end

        function seterror(self,obj)
            if strcmpi(obj.Type,'uiimage')
                obj.Visible='on';
            else
                obj.BackgroundColor=[0.999,0.9,0.9];
                try
                    obj.FontColor='r';
                catch
                end
            end
        end

        function errObj=findErrorImage(self,gobj)
            errObj=[];

            uiimageobj=findobj(self.Parent,'Tag',gobj.Tag,'type','uiimage');
            if isempty(uiimageobj)

                uiimageobj=findobj(gobj.Parent,'Tag',gobj.Tag,'type','uiimage');
            end
            for i=1:numel(uiimageobj)
                if uiimageobj(i).UserData.Id==gobj.UserData.Id&&...
                    strcmpi(uiimageobj(i).UserData.Type,gobj.UserData.Type)
                    errObj=uiimageobj(i);
                    break;
                end
            end
        end

        function rmerror(self,obj)
            try
                if strcmpi(obj.Type,'uiimage')
                    obj.Visible='off';
                else
                    obj.BackgroundColor=[1,1,1];
                    try
                        obj.FontColor='k';
                    catch
                    end
                end
            catch
            end
        end

        function validateArgs(self,argval,argtype,varargin)
            if any(strcmpi(argtype,{'Length','Width','Radius','Diameter','EpsilonR',...
                'FeedDiameter','ViaDiameter','Transparency'}))

                if strcmpi(argtype,'Transparency')

                    validateattributes(argval,{'numeric'},{'nonempty','nonnan',...
                    'finite','real','nonzero','nonnegative','scalar','>',0,'<=',1},'',argtype);
                else
                    validateattributes(argval,{'numeric'},{'nonempty','nonnan',...
                    'finite','real','nonzero','nonnegative','scalar'},'',argtype);
                end
            elseif strcmpi(argtype,'LossTangent')
                validateattributes(argval,{'numeric'},{'nonempty','nonnan',...
                'finite','real','nonnegative','scalar'},'',argtype);
            elseif strcmpi(argtype,'Conductivity')
                validateattributes(argval,{'numeric'},{'nonempty','nonnan','real','positive','scalar'},'',argtype);
                if argval<1e5
                    error(message('antenna:antennaerrors:LowConductivity'));
                end
            elseif strcmpi(argtype,'Thickness')
                validateattributes(argval,{'numeric'},{'nonempty','nonnan',...
                'finite','real','nonnegative','scalar'},'',argtype);
            elseif strcmpi(argtype,'center')
                validateattributes(argval,{'numeric'},{'nonempty','nonnan',...
                'finite','real','row','numel',2},'',argtype);
            elseif strcmpi(argtype,'angle')
                validateattributes(argval,{'numeric'},{'nonempty','nonnan',...
                'finite','real','row','scalar'},'',argtype);
            elseif strcmpi(argtype,'vertices')
                xval=cell2mat(argval(:,1));
                yval=cell2mat(argval(:,2));
                validateattributes(xval,{'numeric'},{'nonempty','nonnan','finite','real','vector'},'','x');
                validateattributes(yval,{'numeric'},{'nonempty','nonnan','finite','real','vector'},'','y');
                numcoord=[numel(xval),numel(yval)];
                if numel(unique(numcoord))~=1
                    [minval,idx]=min(numcoord);
                    if idx==2
                        str='number of y co-ordinates';
                    else
                        str='number of x co-ordinates';
                    end
                    error(['Expected ',str,' to be equal to ',num2str(max(numcoord))]);
                end
            elseif strcmpi(argtype,'Impedance')
                if~isempty(argval)
                    validateattributes(argval,{'numeric'},...
                    {'vector','finite','nonnan'},argtype);
                    validateattributes(real(argval),{'numeric'},...
                    {'vector','real','finite','nonnan','nonnegative'},...
                    argtype);
                end
            elseif strcmpi(argtype,'Frequency')
                if~isempty(argval)
                    validateattributes(argval,{'numeric'},{'nonnan','real',...
                    'finite','positive','vector','row'},'',argtype);
                end
            elseif any(strcmpi(argtype,{'FeedVoltage','FeedPhase'}))
                if strcmpi(argtype,'FeedPhase')
                    validateattributes(argval,{'numeric'},{'nonnan','real','finite',...
                    'nonempty','nonnegative','row','scalar'},'',argtype);
                else
                    validateattributes(argval,{'numeric'},{'nonnan','real','finite',...
                    'nonempty','nonnegative','nonzero','row','scalar'},'',argtype);
                end
            elseif any(strcmpi(argtype,{'MajorAxis','MinorAxis'}))
                if strcmpi(argtype,'MajorAxis')
                    validateattributes(argval,{'numeric'},{'nonnan','real','finite',...
                    'nonempty','positive','scalar','>',varargin{1}},...
                    '',argtype);
                else
                    validateattributes(argval,{'numeric'},{'nonnan','real','finite',...
                    'nonempty','positive','scalar','<',varargin{1}},'',argtype);
                end
            end
        end
        function validateMLname(self,newName,desc)
            if~isvarname(newName)
                validateattributes(newName,{'char'},{'row'},'',desc)


                error(message('rf:shared:ValidateMLNameNotAVarName',desc,newName))
            end
        end


        function setModel(self,Model)
            addlistener(self,'ValueChanged',@(src,evt)valueChanged(Model,evt));
        end

        function cdata=generateColorIcon(self,color)
            cdata=ones(10,10,3);
            cdata(:,:,1)=cdata(:,:,1).*color(1);
            cdata(:,:,2)=cdata(:,:,2).*color(2);
            cdata(:,:,3)=cdata(:,:,3).*color(3);

        end

        function delete(self)
            if self.checkValid(self.Parent)
                clf(self.Parent);
                self.DielectricCatalog.delete;
                self.MetalCatalog.delete;
            end
        end

        function sessionCleared(self)
            self.ShapeView=[];
            self.ViaView=[];
            self.FeedView=[];
            self.LoadView=[];
            self.LayerView=[];
            self.PCBAntennaView=[];
        end
    end

    events
ValueChanged
    end
end
