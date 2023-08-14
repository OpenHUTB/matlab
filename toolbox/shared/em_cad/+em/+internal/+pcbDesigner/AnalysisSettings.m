classdef AnalysisSettings<cad.View




    properties
Parent
ParentLayout

AnalysisSettingsPanel
AnalysisSettingsGridLayout
PortTitle
PortName
PortErrorImage
PortEdit
PortUnits
Pattern3DTitle
AzRangeName
AzRangeErrorImage
AzRangeEdit
AzRangeUnits
ElRangeName
ElRangeErrorImage
ElRangeEdit
ElRangeUnits

MeshSettingsPanel
MeshSettingsGridLayout
MeshingModeName
MeshingModeDropDown
MaxEdgeName
MaxEdgeErrorImage
MaxEdgeEdit
MaxEdgeUnits
MinEdgeName
MinEdgeErrorImage
MinEdgeEdit
MinEdgeUnits
GrowthRateName
GrowthRateErrorImage
GrowthRateEdit
GrowthRateUnits

OKBtn
CancelBtn
        SettingsChanged=0;

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
Model

        PvtPortImpedance=50
        PvtAzRange=[0:5:360]
        PvtElRange=[0:5:360]

        PvtMeshingMode='Auto'
        PvtMaxEdgeLength=[]
        PvtMinEdgeLength=[]
        PvtGrowthRate=[]

    end
    properties(Dependent=true)
PortImpedance
AzRange
ElRange

MeshingMode
MaxEdgeLength
MinEdgeLength
GrowthRate
    end

    methods
        function self=AnalysisSettings(Parent)
            self.Parent=Parent;
            self.ErrorCData=zeros(13,14,3,'uint8');
            self.ErrorCData(:,:,1)=self.error1;
            self.ErrorCData(:,:,2)=self.error2;
            self.ErrorCData(:,:,3)=self.error3;


            createAnalysisSettings(self);

        end

        function set.PortImpedance(self,val)

            self.PvtPortImpedance=val;
            self.PortEdit.Value=num2str(val);
        end

        function val=get.PortImpedance(self)
            val=str2num(self.PortEdit.Value);
        end

        function set.AzRange(self,val)
            self.PvtAzRange=val;
            self.AzRangeEdit.Value=decreaseMatrixToString(self,val);
        end

        function val=get.AzRange(self)
            val=str2num(self.AzRangeEdit.Value);
        end

        function set.ElRange(self,val)
            self.PvtElRange=val;
            self.ElRangeEdit.Value=decreaseMatrixToString(self,val);
        end

        function val=get.ElRange(self)
            val=str2num(self.ElRangeEdit.Value);
        end

        function set.MaxEdgeLength(self,val)
            self.PvtMaxEdgeLength=val;
            self.MaxEdgeEdit.Value=num2str(val);
        end

        function val=get.MaxEdgeLength(self)
            val=str2num(self.MaxEdgeEdit.Value);
        end

        function set.MinEdgeLength(self,val)
            self.PvtMinEdgeLength=val;
            self.MinEdgeEdit.Value=num2str(val);
        end

        function val=get.MinEdgeLength(self)
            val=str2num(self.MinEdgeEdit.Value);
        end

        function set.MeshingMode(self,val)
            self.PvtMeshingMode=val;
            self.MeshingModeDropDown.Value=val;
        end

        function val=get.MeshingMode(self)
            val=self.MeshingModeDropDown.Value;
        end

        function set.GrowthRate(self,val)
            self.PvtGrowthRate=val;
            self.GrowthRateEdit.Value=num2str(val);
        end

        function val=get.GrowthRate(self)
            val=str2num(self.GrowthRateEdit.Value);
        end

        function showSettingsDialog(self)
            self.SettingsChanged=0;
            self.PortErrorImage.Visible='off';
            self.PortEdit.BackgroundColor=[1,1,1];
            self.PortEdit.FontColor=[0,0,0];
            self.PortImpedance=self.PvtPortImpedance;

            self.AzRangeErrorImage.Visible='off';
            self.AzRangeEdit.BackgroundColor=[1,1,1];
            self.AzRangeEdit.FontColor=[0,0,0];
            self.AzRange=self.PvtAzRange;

            self.ElRangeErrorImage.Visible='off';
            self.ElRangeEdit.BackgroundColor=[1,1,1];
            self.ElRangeEdit.FontColor=[0,0,0];
            self.ElRange=self.PvtElRange;

            self.MaxEdgeErrorImage.Visible='off';
            self.MaxEdgeEdit.BackgroundColor=[1,1,1];
            self.MaxEdgeEdit.FontColor=[0,0,0];
            self.MaxEdgeLength=self.PvtMaxEdgeLength;

            self.MinEdgeErrorImage.Visible='off';
            self.MinEdgeEdit.BackgroundColor=[1,1,1];
            self.MinEdgeEdit.FontColor=[0,0,0];
            self.MinEdgeLength=self.PvtMinEdgeLength;

            self.GrowthRateErrorImage.Visible='off';
            self.GrowthRateEdit.BackgroundColor=[1,1,1];
            self.GrowthRateEdit.FontColor=[0,0,0];
            self.GrowthRate=self.PvtGrowthRate;

            self.Parent.Visible='on';
            self.Parent.WindowStyle='modal';
        end
        function errorval=isErrorPresent(self)
            errorval=0;
            if strcmpi(self.PortErrorImage.Visible,'on')
                errorval=1;
            elseif strcmpi(self.AzRangeErrorImage.Visible,'on')
                errorval=1;
            elseif strcmpi(self.ElRangeErrorImage.Visible,'on')
                errorval=1;
            end

            if~strcmpi(self.MeshingModeDropDown.Value,'Auto')
                if strcmpi(self.MaxEdgeErrorImage.Visible,'on')
                    errorval=1;
                elseif strcmpi(self.MinEdgeErrorImage.Visible,'on')
                    errorval=1;
                elseif strcmpi(self.GrowthRateErrorImage.Visible,'on')
                    errorval=1;
                end
            end

        end


        function createAnalysisSettings(self)

            self.ParentLayout=uigridlayout(self.Parent);
            self.Parent.Name='Analysis Settings';
            createAnalysisSettingsPanel(self)
            createMeshSettingsPanel(self);

            self.ParentLayout.RowHeight={'fit','fit','fit'};
            self.ParentLayout.ColumnWidth={'fit','fit','fit'};
            self.AnalysisSettingsPanel.Layout.Row=1;
            self.AnalysisSettingsPanel.Layout.Column=[1,3];
            self.MeshSettingsPanel.Layout.Row=2;
            self.MeshSettingsPanel.Layout.Column=[1,3];
            self.OKBtn=uibutton(self.ParentLayout,'Text','OK','ButtonPushedFcn',@(src,evt)okcallback(self));
            self.OKBtn.Layout.Row=3;self.OKBtn.Layout.Column=2;
            self.CancelBtn=uibutton(self.ParentLayout,'Text','Cancel','ButtonPushedFcn',@(src,evt)hideSettingsDialog(self));
            self.CancelBtn.Layout.Row=3;self.CancelBtn.Layout.Column=3;

            self.Parent.Position(3:4)=[350,450];
            self.Parent.Resize='off';
            self.Parent.CloseRequestFcn=@(src,evt)hideSettingsDialog(self);

        end

        function createAnalysisSettingsPanel(self)
            self.AnalysisSettingsPanel=uipanel(self.ParentLayout);
            self.AnalysisSettingsPanel.Title='Plot Settings';
            self.AnalysisSettingsGridLayout=uigridlayout(self.AnalysisSettingsPanel);
            layout=self.AnalysisSettingsGridLayout;
            layout.RowHeight=[25,25,25,25,25];
            layout.ColumnWidth=[125,16,95,40];

            self.PortTitle=uilabel(layout,'Text','Port:','FontWeight','bold',...
            'HorizontalAlignment','left');
            self.PortTitle.Layout.Row=1;
            self.PortTitle.Layout.Column=[1,4];


            self.PortName=uilabel(layout,'Text','Ref Impedance (Z0)',...
            'HorizontalAlignment','right');
            setPosition(self,self.PortName,2,1);

            self.PortErrorImage=uiimage(layout,'ImageSource',self.ErrorCData,...
            'tag','PortImpedance','Visible','off');
            setPosition(self,self.PortErrorImage,2,2);
            self.PortEdit=uieditfield(layout,'Value','50','tag','PortImpedance',...
            'ValueChangedFcn',@(src,evt)self.valuechanged(src,evt));
            setPosition(self,self.PortEdit,2,3);
            self.PortUnits=uilabel(layout,'Text','ohms',...
            'HorizontalAlignment','left');
            setPosition(self,self.PortUnits,2,4);
            self.Pattern3DTitle=uilabel(layout,'Text','3D Pattern:','FontWeight','bold',...
            'HorizontalAlignment','left');
            setPosition(self,self.Pattern3DTitle,3,[1,4]);

            self.AzRangeName=uilabel(layout,'Text','Az Range',...
            'HorizontalAlignment','right');
            setPosition(self,self.AzRangeName,4,1);
            self.AzRangeErrorImage=uiimage(layout,'ImageSource',self.ErrorCData,...
            'tag','AzRange','Visible','off');
            setPosition(self,self.AzRangeErrorImage,4,2);
            self.AzRangeEdit=uieditfield(layout,'Value','0:5:360','tag','AzRange',...
            'ValueChangedFcn',@(src,evt)self.valuechanged(src,evt));
            setPosition(self,self.AzRangeEdit,4,3);
            self.AzRangeUnits=uilabel(layout,'Text','deg',...
            'HorizontalAlignment','left');
            setPosition(self,self.AzRangeUnits,4,4);


            self.ElRangeName=uilabel(layout,'Text','El Range',...
            'HorizontalAlignment','right');
            setPosition(self,self.ElRangeName,5,1);
            self.ElRangeEdit=uieditfield(layout,'Value','0:5:360','tag','ElRange',...
            'ValueChangedFcn',@(src,evt)self.valuechanged(src,evt));
            setPosition(self,self.ElRangeEdit,5,3);
            self.ElRangeErrorImage=uiimage(layout,'ImageSource',self.ErrorCData,...
            'tag','ElRange','Visible','off');
            setPosition(self,self.ElRangeErrorImage,5,2);
            self.ElRangeUnits=uilabel(layout,'Text','deg',...
            'HorizontalAlignment','left');
            setPosition(self,self.ElRangeUnits,5,4);

        end

        function createMeshSettingsPanel(self)
            self.MeshSettingsPanel=uipanel(self.ParentLayout);
            self.MeshSettingsPanel.Title='Mesh Settings';
            self.MeshSettingsGridLayout=uigridlayout(self.MeshSettingsPanel);
            layout=self.MeshSettingsGridLayout;
            layout.RowHeight=[25,25,25,25];
            layout.ColumnWidth=[125,16,95,40];



            self.MeshingModeName=uilabel(layout,'Text','Meshing Mode',...
            'HorizontalAlignment','right');
            setPosition(self,self.MeshingModeName,1,1);
            self.MeshingModeDropDown=uidropdown(layout,'Value','auto','Items',...
            {'auto','manual'},'tag','MeshingMode','ValueChangedFcn',@(src,evt)self.valuechanged(src,evt));
            setPosition(self,self.MeshingModeDropDown,1,3);


            self.MaxEdgeName=uilabel(layout,'Text','Max Edge Length',...
            'HorizontalAlignment','right');
            setPosition(self,self.MaxEdgeName,2,1);
            self.MaxEdgeErrorImage=uiimage(layout,'ImageSource',self.ErrorCData,...
            'tag','MaxEdgeLength','Visible','off');
            setPosition(self,self.MaxEdgeErrorImage,2,2);
            self.MaxEdgeEdit=uieditfield(layout,'Value','','tag','MaxEdgeLength',...
            'Enable','off','ValueChangedFcn',@(src,evt)self.valuechanged(src,evt));
            setPosition(self,self.MaxEdgeEdit,2,3);
            self.MaxEdgeUnits=uilabel(layout,'Text','m',...
            'HorizontalAlignment','left');
            setPosition(self,self.MaxEdgeUnits,2,4);

            self.MinEdgeName=uilabel(layout,'Text','Min Edge Length',...
            'HorizontalAlignment','right');
            setPosition(self,self.MinEdgeName,3,1);
            self.MinEdgeErrorImage=uiimage(layout,'ImageSource',self.ErrorCData,...
            'tag','MinEdgeLength','Visible','off');
            setPosition(self,self.MinEdgeErrorImage,3,2);
            self.MinEdgeEdit=uieditfield(layout,'Value','','tag','MinEdgeLength',...
            'Enable','off','ValueChangedFcn',@(src,evt)self.valuechanged(src,evt));
            setPosition(self,self.MinEdgeEdit,3,3);
            self.MinEdgeUnits=uilabel(layout,'Text','m',...
            'HorizontalAlignment','left');
            setPosition(self,self.MinEdgeUnits,3,4);

            self.GrowthRateName=uilabel(layout,'Text','Growth Rate',...
            'HorizontalAlignment','right');
            setPosition(self,self.GrowthRateName,4,1);
            self.GrowthRateEdit=uieditfield(layout,'Value','','tag','GrowthRate',...
            'Enable','off','ValueChangedFcn',@(src,evt)self.valuechanged(src,evt));
            setPosition(self,self.GrowthRateEdit,4,3);
            self.GrowthRateErrorImage=uiimage(layout,'ImageSource',self.ErrorCData,...
            'tag','GrowthRate','Visible','off');
            setPosition(self,self.GrowthRateErrorImage,4,2);



        end

        function valuechanged(self,src,evt)
            try
                if strcmpi(src.Tag,'PortImpedance')
                    validateattributes(str2num(evt.Value),{'numeric'},{'nonnan','finite','real',...
                    'nonnegative','nonempty','scalar'},'','Ref Impedance');
                elseif strcmpi(src.Tag,'AzRange')
                    validateattributes([str2num(evt.Value)],{'numeric'},{'nonnan','finite','real',...
                    'nonempty','vector','row'},'','Azimuth Range');
                elseif strcmpi(src.Tag,'ElRange')
                    validateattributes([str2num(evt.Value)],{'numeric'},{'nonnan','finite','real',...
                    'nonempty','vector','row'},'','Elevation Range');
                elseif strcmpi(src.Tag,'MaxEdgeLength')
                    if strcmpi(evt.Value,'')

                    else
                        validateattributes(str2num(evt.Value),{'numeric'},...
                        {'nonnan','finite','real','nonnegative','nonzero','scalar'},...
                        '','MaxEdgeLength');
                    end
                elseif strcmpi(src.Tag,'MinEdgeLength')
                    if strcmpi(evt.Value,'')

                    else
                        validateattributes(str2num(evt.Value),{'numeric'},...
                        {'nonnan','finite','real','nonnegative','nonzero','scalar'},...
                        '','MinEdgeLength');
                    end
                elseif strcmpi(src.Tag,'GrowthRate')
                    if strcmpi(evt.Value,'')

                    else
                        validateattributes(str2num(evt.Value),{'numeric'},...
                        {'nonnan','finite','real','nonnegative','scalar','<=',1,'>',0},...
                        '','GrowthRate');
                    end
                elseif strcmpi(src.Tag,'MeshingMode')
                    if strcmpi(evt.Value,'Auto')
                        self.MaxEdgeEdit.Enable='off';
                        self.MaxEdgeEdit.BackgroundColor=[1,1,1];
                        self.MaxEdgeErrorImage.Visible='off';
                        self.MaxEdgeEdit.FontColor='k';
                        self.MinEdgeEdit.Enable='off';
                        self.MinEdgeEdit.BackgroundColor=[1,1,1];
                        self.MinEdgeErrorImage.Visible='off';
                        self.MinEdgeEdit.FontColor='k';
                        self.GrowthRateEdit.Enable='off';
                        self.GrowthRateEdit.BackgroundColor=[1,1,1];
                        self.GrowthRateEdit.FontColor='k';
                        self.GrowthRateErrorImage.Visible='off';
                    else
                        self.MaxEdgeEdit.Enable='on';
                        self.MinEdgeEdit.Enable='on';
                        self.GrowthRateEdit.Enable='on';
                        evttemp.Value=self.GrowthRateEdit.Value;
                        self.valuechanged(self.GrowthRateEdit,evttemp);
                        evttemp.Value=self.MaxEdgeEdit.Value;
                        self.valuechanged(self.MaxEdgeEdit,evttemp);
                        evttemp.Value=self.MinEdgeEdit.Value;
                        self.valuechanged(self.MinEdgeEdit,evttemp);
                    end
                end
                src.FontColor='k';
                src.BackgroundColor=[1,1,1];
                if strcmpi(src.Tag,'PortImpedance')
                    self.PortErrorImage.Visible='off';
                elseif strcmpi(src.Tag,'AzRange')
                    self.AzRangeErrorImage.Visible='off';
                elseif strcmpi(src.Tag,'ElRange')
                    self.ElRangeErrorImage.Visible='off';
                elseif strcmpi(src.Tag,'MaxEdgeLength')
                    self.MaxEdgeErrorImage.Visible='off';
                elseif strcmpi(src.Tag,'MinEdgeLength')
                    self.MinEdgeErrorImage.Visible='off';
                elseif strcmpi(src.Tag,'GrowthRate')
                    self.GrowthRateErrorImage.Visible='off';
                end
                self.SettingsChanged=1;
            catch Me
                src.FontColor='r';
                src.BackgroundColor=[0.999,0.9,0.9];
                if strcmpi(src.Tag,'PortImpedance')
                    self.PortErrorImage.Visible='on';
                    self.PortErrorImage.Tooltip=Me.message;
                elseif strcmpi(src.Tag,'AzRange')
                    self.AzRangeErrorImage.Visible='on';
                    self.AzRangeErrorImage.Tooltip=Me.message;
                elseif strcmpi(src.Tag,'ElRange')
                    self.ElRangeErrorImage.Visible='on';
                    self.ElRangeErrorImage.Tooltip=Me.message;
                elseif strcmpi(src.Tag,'MaxEdgeLength')
                    self.MaxEdgeErrorImage.Visible='on';
                    self.MaxEdgeErrorImage.Tooltip=Me.message;
                elseif strcmpi(src.Tag,'MinEdgeLength')
                    self.MinEdgeErrorImage.Visible='on';
                    self.MinEdgeErrorImage.Tooltip=Me.message;
                elseif strcmpi(src.Tag,'GrowthRate')
                    self.GrowthRateErrorImage.Visible='on';
                    self.GrowthRateErrorImage.Tooltip=Me.message;
                end
            end

            if isErrorPresent(self)
                self.OKBtn.Enable='off';
            elseif strcmpi(self.MeshingMode,'manual')
                if~isempty(self.MaxEdgeLength)||~isempty(self.MinEdgeLength)||~isempty(self.GrowthRate)
                    self.OKBtn.Enable='on';
                else
                    self.OKBtn.Enable='off';
                end

            else
                self.OKBtn.Enable='on';
            end
        end


        function setPosition(self,gobj,row,column)
            gobj.Layout.Row=row;
            gobj.Layout.Column=column;
        end



        function updateView(self,vm)



            modelInfo=vm.getModelInfo();
            self.PortImpedance=modelInfo.Plot.Port;
            self.AzRange=modelInfo.Plot.AzRange;
            self.ElRange=modelInfo.Plot.ElRange;
            self.MaxEdgeLength=modelInfo.Mesh.MaxEdgeLength;
            self.MinEdgeLength=modelInfo.Mesh.MinEdgeLength;
            self.GrowthRate=modelInfo.Mesh.GrowthRate;
            self.MeshingMode=modelInfo.Mesh.MeshingMode;
            evt=[];
            evt.Value=self.MeshingMode;
            self.valuechanged(self.MeshingModeDropDown,evt);
        end

        function setModel(self,model)
            self.Model=model;
            addlistener(self,'ValueChanged',@(src,evt)settingsChanged(model,evt));
        end

        function okcallback(self)
            plotSet=struct('Port',self.PortImpedance,'AzRange',self.AzRange,...
            'ElRange',self.ElRange);
            Mesh=struct('MeshingMode',self.MeshingMode,'MaxEdgeLength',self.MaxEdgeLength,...
            'MinEdgeLength',self.MinEdgeLength,'GrowthRate',self.GrowthRate);
            Data=struct('Plot',plotSet,'Mesh',Mesh);
            Data.Property='Model';
            Data.Type='AnalysisSettings';







            if self.SettingsChanged
                self.notify('ValueChanged',cad.events.ValueChangedEventData(Data));
            end
            hideSettingsDialog(self);
        end

        function hideSettingsDialog(self)
            self.Parent.Visible='off';
            self.Parent.WindowStyle='normal';
            self.notify('DialogClosed');
        end

        function decval=decreaseMatrixToString(self,val)
            if numel(val)>5
                diffval=val(2:end)-val(1:end-1);
                if numel(unique(round(diffval,8)))==1
                    decval=[num2str(val(1)),':',num2str(unique(round(diffval,8))),':',num2str(val(end))];
                else
                    decval=mat2str(val);
                end
            else
                decval=mat2str(val);
            end
        end

        function delete(self)
            if self.checkValid(self.Parent)
                clf(self.Parent);
                self.Parent.delete;
            end
        end
    end

    events
ValueChanged
    end
end
