classdef PlotOptionsDialog<handle






    properties
ReferenceImpedance
AZRange
ELRange
Termination
Model
    end

    properties(Hidden)
Figure
Name
Panel
Layout
        Width=0;
        Height=0;
Listeners
Response
        OKCancelFlag=0;
    end

    properties(Access=private)

PortPropertiesTitle
Pattern3DPropertiesTitle
Pattern2DPropertiesTitle
EmbeddedElementsPropertiesTitle
RefImpedanceLabel
RefImpedanceEdit
AZRangeLabel
AZRangeEdit
ELRangeLabel
ELRangeEdit
TerminationLabel
TerminationEdit
OKButton
CancelButton
ErrorExclamations
RefImpedanceUnits
AZRangeUnits
ELRangeUnits
TerminationUnits
    end

    methods

        function obj=PlotOptionsDialog(varargin)




            p=inputParser;
            p.addOptional('Name','Settings',@ischar);
            p.addParameter('ReferenceImpedance',0,@isnumeric);
            p.addParameter('AZRange',0,@isnumeric);
            p.addParameter('ELRange',0,@isnumeric);
            p.addParameter('Termination',0,@isnumeric);
            p.addParameter('ObjectModel',[]);
            parse(p,varargin{:});

            obj.Name=p.Results.Name;
            obj.ReferenceImpedance=p.Results.ReferenceImpedance;
            obj.AZRange=p.Results.AZRange;
            obj.ELRange=p.Results.ELRange;
            obj.Termination=p.Results.Termination;
            obj.Model=p.Results.ObjectModel;

            obj.Figure=dialog('Name','Settings');

            createUIControls(obj)
            showErrorLabels(obj);

            layoutUIControls(obj)
            registerListeners(obj);

            if isempty(obj.Model)
                uiwait(obj.Figure);
            end
        end


        function set.AZRange(obj,newRange)
            obj.AZRange=newRange;
        end

        function set.ELRange(obj,newRange)
            obj.ELRange=newRange;
        end

        function set.ReferenceImpedance(obj,newReferenceImpedance)
            obj.ReferenceImpedance=newReferenceImpedance;
        end

        function set.Termination(obj,newTermination)
            obj.Termination=newTermination;
        end

        function setListenersEnable(obj,val)
            obj.Listeners.RefImp.Enabled=val;
            obj.Listeners.Azimuth.Enabled=val;
            obj.Listeners.Elevation.Enabled=val;
            obj.Listeners.Termination.Enabled=val;
        end
    end

    methods(Access=private)

        function createUIControls(obj)

            obj.Panel=uipanel(...
            'Parent',obj.Figure,...
            'Title',obj.Name,...
            'BorderType','line',...
            'HighlightColor',[.5,.5,.5],...
            'Visible','on',...
            'FontWeight','bold',...
            'Tag','PlotOptionsDialogPanel');
            obj.Panel.Position=[0.01,0.01,0.98,0.98];

            obj.PortPropertiesTitle=uicontrol(...
            'Parent',obj.Panel,...
            'Style','text',...
            'String',' Port :',...
            'FontWeight','bold',...
            'ForegroundColor',[0,0,0],...
            'HorizontalAlignment','left',...
            'Tag','PortPropertiesTitle');

            obj.Pattern3DPropertiesTitle=uicontrol(...
            'Parent',obj.Panel,...
            'Style','text',...
            'String',' 3D Pattern :',...
            'FontWeight','bold',...
            'ForegroundColor',[0,0,0],...
            'HorizontalAlignment','left',...
            'Tag','Pattern3DPropertiesTitle');
            if obj.Termination~=0
                obj.EmbeddedElementsPropertiesTitle=uicontrol(...
                'Parent',obj.Panel,...
                'Style','text',...
                'String',' Embedded Element :',...
                'FontWeight','bold',...
                'ForegroundColor',[0,0,0],...
                'HorizontalAlignment','left',...
                'Tag','EmbeddedElementsPropertiesTitle');
            end

            if~isempty(obj.ReferenceImpedance)
                obj.RefImpedanceLabel=uicontrol(...
                'Parent',obj.Panel,...
                'Style','text',...
                'String','Ref Impedance(Z0):',...
                'HorizontalAlignment','right',...
                'Tag','RefImpedanceLabel');
                obj.RefImpedanceEdit=uicontrol(...
                'Parent',obj.Panel,...
                'Style','edit',...
                'String',em.internal.apps.shrink(obj.ReferenceImpedance),...
                'HorizontalAlignment','left',...
                'Tag','RefImpedanceEdit');
                obj.RefImpedanceUnits=uicontrol(...
                'Parent',obj.Panel,...
                'Style','text',...
                'String','ohm',...
                'HorizontalAlignment','left',...
                'Tag','RefImpedanceUnits');
            end


            if~isempty(obj.AZRange)
                obj.AZRangeLabel=uicontrol(...
                'Parent',obj.Panel,...
                'Style','text',...
                'String','Az Range:',...
                'HorizontalAlignment','right',...
                'Tag','AZRangeLabel');
                obj.AZRangeEdit=uicontrol(...
                'Parent',obj.Panel,...
                'Style','edit',...
                'String',em.internal.apps.shrink(obj.AZRange),...
                'HorizontalAlignment','left',...
                'Tag','AZRangeEdit');
                obj.AZRangeUnits=uicontrol(...
                'Parent',obj.Panel,...
                'Style','text',...
                'String','deg',...
                'HorizontalAlignment','left',...
                'Tag','AZRangeUnits');
            end

            if~isempty(obj.ELRange)
                obj.ELRangeLabel=uicontrol(...
                'Parent',obj.Panel,...
                'Style','text',...
                'String','El Range:',...
                'HorizontalAlignment','right',...
                'Tag','ELRangeLabel');
                obj.ELRangeEdit=uicontrol(...
                'Parent',obj.Panel,...
                'Style','edit',...
                'String',em.internal.apps.shrink(obj.ELRange),...
                'HorizontalAlignment','left',...
                'Tag','ELRangeEdit');
                obj.ELRangeUnits=uicontrol(...
                'Parent',obj.Panel,...
                'Style','text',...
                'String','deg',...
                'HorizontalAlignment','left',...
                'Tag','ELRangeUnits');
            end

            if obj.Termination~=0
                obj.TerminationLabel=uicontrol(...
                'Parent',obj.Panel,...
                'Style','text',...
                'String','Termination:',...
                'HorizontalAlignment','right',...
                'Tag','TerminationLabel');
                obj.TerminationEdit=uicontrol(...
                'Parent',obj.Panel,...
                'Style','edit',...
                'String',em.internal.apps.shrink(obj.Termination),...
                'HorizontalAlignment','left',...
                'Tag','TerminationEdit');
                obj.TerminationUnits=uicontrol(...
                'Parent',obj.Panel,...
                'Style','text',...
                'String','ohm',...
                'HorizontalAlignment','left',...
                'Tag','TerminationUnits');
            end

            obj.OKButton=uicontrol(...
            'Parent',obj.Panel,...
            'Style','pushbutton',...
            'String','Ok',...
            'HorizontalAlignment','left',...
            'Callback',@obj.okCancelCallback,...
            'Tag','ok');

            obj.CancelButton=uicontrol(...
            'Parent',obj.Panel,...
            'String','Cancel',...
            'HorizontalAlignment','left',...
            'Callback',@obj.okCancelCallback,...
            'Tag','cancel');
        end

        function layoutUIControls(obj)
            hspacing=3;
            vspacing=4;
            obj.Layout=...
            matlabshared.application.layout.GridBagLayout(...
            obj.Panel,...
            'VerticalGap',vspacing,...
            'HorizontalGap',hspacing,...
            'VerticalWeights',[0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],...
            'HorizontalWeights',[0,1,0,0]);

            if ispc
                w1=127;
            else
                w1=140;
            end

            w2=75;
            w3=55;


            row=3;
            titleHt=16;
            obj.addTitle(obj.Layout,obj.PortPropertiesTitle,row,[1,5],...
            titleHt,hspacing,vspacing)


            if~isempty(obj.ReferenceImpedance)
                h=24;
                row=row+1;
                obj.addText(obj.Layout,obj.RefImpedanceLabel,row,1,w1,h)
                obj.addText(obj.Layout,obj.ErrorExclamations{1},row,2,25,h)
                obj.addEdit(obj.Layout,obj.RefImpedanceEdit,row,[3,4],w2,h)
                obj.addText(obj.Layout,obj.RefImpedanceUnits,row,5,w3,h)
            end


            row=row+1;
            titleHt=16;
            obj.addTitle(obj.Layout,obj.Pattern3DPropertiesTitle,row,[1,4],...
            titleHt,hspacing,vspacing)


            if~isempty(obj.AZRange)
                row=row+1;
                obj.addText(obj.Layout,obj.AZRangeLabel,row,1,w1,h)
                obj.addText(obj.Layout,obj.ErrorExclamations{2},row,2,25,h)
                obj.addEdit(obj.Layout,obj.AZRangeEdit,row,[3,4],w2,h)
                obj.addText(obj.Layout,obj.AZRangeUnits,row,5,w3,h)
            end


            if~isempty(obj.ELRange)
                row=row+1;
                obj.addText(obj.Layout,obj.ELRangeLabel,row,1,w1,h)
                obj.addText(obj.Layout,obj.ErrorExclamations{3},row,2,25,h)
                obj.addEdit(obj.Layout,obj.ELRangeEdit,row,[3,4],w2,h)
                obj.addText(obj.Layout,obj.ELRangeUnits,row,5,w3,h)
            end

            if obj.Termination~=0

                row=row+1;
                titleHt=16;
                obj.addTitle(obj.Layout,obj.EmbeddedElementsPropertiesTitle,row,[1,4],...
                titleHt,hspacing,vspacing)


                row=row+1;
                obj.addText(obj.Layout,obj.TerminationLabel,row,1,w1,h)
                obj.addText(obj.Layout,obj.ErrorExclamations{4},row,2,25,h)
                obj.addEdit(obj.Layout,obj.TerminationEdit,row,[3,4],w2,h)
                obj.addText(obj.Layout,obj.TerminationUnits,row,5,w3,h)
            end


            row=row+1;
            obj.addButton(obj.Layout,obj.OKButton,row,4,w3,h);
            obj.addButton(obj.Layout,obj.CancelButton,row,5,w3,h);

            [~,~,w,h]=getMinimumSize(obj.Layout);
            obj.Width=sum(w)+obj.Layout.HorizontalGap*(numel(w)+1);
            obj.Height=max(h(2:end))*numel(h(2:end))+...
            obj.Layout.VerticalGap*(numel(h(2:end))+1)+(titleHt+2);
            obj.Figure.Position(3)=obj.Width;
            obj.Figure.Position(4)=obj.Height;
        end

        function registerListeners(obj)
            if~isempty(obj.ReferenceImpedance)
                obj.Listeners.RefImp=addlistener(obj.RefImpedanceEdit,'String',...
                'PostSet',@(h,e)obj.parameterChangedCallback(obj.RefImpedanceEdit,'RefImpedanceEdit'));
            end
            if~isempty(obj.AZRange)
                obj.Listeners.Azimuth=addlistener(obj.AZRangeEdit,'String',...
                'PostSet',@(h,e)obj.parameterChangedCallback(obj.AZRangeEdit,'AZRangeEdit'));
            end
            if~isempty(obj.ELRange)
                obj.Listeners.Elevation=addlistener(obj.ELRangeEdit,'String',...
                'PostSet',@(h,e)obj.parameterChangedCallback(obj.ELRangeEdit,'ELRangeEdit'));
            end
            if obj.Termination~=0
                obj.Listeners.Termination=addlistener(obj.TerminationEdit,'String',...
                'PostSet',@(h,e)obj.parameterChangedCallback(obj.TerminationEdit,'TerminationEdit'));
            end
        end

        function parameterChangedCallback(obj,h,~)
            t=h.Tag;
            try
                h.ForegroundColor=[0,0,0];
                h.BackgroundColor=[0.9400,0.9400,0.9400];
                h.Tooltip='';
                switch t
                case 'RefImpedanceEdit'
                    i=1;
                    obj.ErrorExclamations{i}.Visible='off';
                    val=eval(h.String);
                    validateattributes(val,{'numeric'},{'nonempty','scalar','finite','positive'},...
                    '','Impedance')

                case 'AZRangeEdit'
                    i=2;
                    obj.ErrorExclamations{i}.Visible='off';
                    val=eval(h.String);
                    validateattributes(val,{'numeric'},...
                    {'vector','nonempty','real','finite','nonnan'},'pattern');
                case 'ELRangeEdit'
                    i=3;
                    obj.ErrorExclamations{i}.Visible='off';
                    val=eval(h.String);
                    validateattributes(val,{'numeric'},...
                    {'vector','nonempty','real','finite','nonnan'},'pattern');
                case 'TerminationEdit'
                    i=4;
                    obj.ErrorExclamations{i}.Visible='off';
                    val=eval(h.String);
                    validateattributes(val,...
                    {'numeric'},{'scalar','nonempty','finite',...
                    'nonnan','nonnegative'},'pattern','Termination');
                end
            catch ME
                obj.OKButton.Enable='off';
                h.ForegroundColor='r';
                h.BackgroundColor=[0.999,0.9,0.9];
                h.Tooltip=ME.message;

                obj.ErrorExclamations{i}.Visible='on';
            end

            if strcmpi(obj.OKButton.Enable,'off')
                errorVisibleCell=cellfun(@(x)x.Visible,...
                obj.ErrorExclamations,'UniformOutput',false);
                if any(strcmpi(errorVisibleCell(:),'on'))
                    obj.OKButton.Enable='off';
                else
                    obj.OKButton.Enable='on';
                end
            end
        end

        function showErrorLabels(obj)
            error=zeros(13,14,3,'uint8');
            error(:,:,1)=em.internal.apps.PropertyPanelModel.error1;
            error(:,:,2)=em.internal.apps.PropertyPanelModel.error2;
            error(:,:,3)=em.internal.apps.PropertyPanelModel.error3;
            Tags={'RefImp','AzRange','ElRange','Termination'};
            for i=1:4
                obj.ErrorExclamations{i}=uicontrol('Parent',obj.Panel,'Style','checkbox',...
                'String','',...
                'HorizontalAlignment','right',...
                'Tag',['Error',Tags{i}],...
                'Visible','off');
                obj.ErrorExclamations{i}.FontWeight='bold';
                obj.ErrorExclamations{i}.ForegroundColor='r';
                set(obj.ErrorExclamations{i},'CData',error);
            end
        end

        function okCancelCallback(obj,src,~)
            if strcmpi(src.Tag,'ok')
                obj.OKCancelFlag=1;
                if~isempty(obj.ReferenceImpedance)
                    obj.ReferenceImpedance=eval(obj.RefImpedanceEdit.String);
                    if~isempty(obj.Model)
                        obj.Model.ReferenceImpedance=obj.ReferenceImpedance;
                    else

                        uiresume(obj.Figure);
                    end
                end
                if~isempty(obj.AZRange)
                    obj.AZRange=eval(obj.AZRangeEdit.String);
                    if~isempty(obj.Model)
                        obj.Model.AZRange=obj.AZRange;
                    else

                        uiresume(obj.Figure);
                    end
                end
                if~isempty(obj.ELRange)
                    obj.ELRange=eval(obj.ELRangeEdit.String);
                    if~isempty(obj.Model)
                        obj.Model.ELRange=obj.ELRange;
                    else

                        uiresume(obj.Figure);
                    end
                end
                if obj.Termination~=0
                    obj.Termination=eval(obj.TerminationEdit.String);
                    if~isempty(obj.Model)
                        obj.Model.Termination=obj.Termination;
                    else

                        uiresume(obj.Figure);
                    end
                end
                delete(obj.Figure);
                updatePlots(obj.Model);
            else
                obj.OKCancelFlag=0;
                delete(obj.Figure);
            end
        end
    end

    methods(Static)
        function addTitle(layout,uic,row,col,h,hspacing,vspacing)
            add(layout,uic,row,col,...
            'LeftInset',-hspacing,...
            'RightInset',-hspacing,...
            'TopInset',-vspacing,...
            'MinimumHeight',h,...
            'MaximumHeight',h,...
            'Fill','Horizontal')
        end

        function addText(layout,uic,row,col,w,h)
            textInset=5;
            add(layout,uic,row,col,...
            'MinimumWidth',w,...
            'MinimumHeight',h-textInset,...
            'TopInset',textInset)
        end

        function addEdit(layout,uic,row,col,w,h)
            add(layout,uic,row,col,...
            'MinimumWidth',w,...
            'Fill','Horizontal',...
            'MinimumHeight',h)
        end

        function addPopup(layout,uic,row,col,w,h)
            popupInset=0;
            add(layout,uic,row,col,...
            'MinimumWidth',w,...
            'Fill','Horizontal',...
            'MinimumHeight',h-popupInset,...
            'TopInset',popupInset)
        end

        function addButton(layout,uic,row,col,w,h)
            popupInset=-2;
            add(layout,uic,row,col,...
            'MinimumWidth',w,...
            'MinimumHeight',h-popupInset,...
            'TopInset',popupInset)
        end

    end
end
