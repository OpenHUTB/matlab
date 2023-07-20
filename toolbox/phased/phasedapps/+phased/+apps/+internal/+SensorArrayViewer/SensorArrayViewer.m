


classdef SensorArrayViewer<handle

    properties
FigureHandle
ContainerHandle
DialogPanel

Settings
Visualization
ArrayChar
    end


    properties(Access=private)
ZoomTools
PanTool
RotateTool

AxesHandler

Listeners


MyKey
MyMap

        isSettingsVisible=true;
        IsStale=false;

    end

    properties(Constant,Access=private)
        AppSize=[940,680];
    end

    methods
        function obj=SensorArrayViewer(varargin)
            if numel(varargin)==1&&...
                isa(varargin{1},'phased.internal.AbstractSensorOperation')
                obj.isSettingsVisible=false;
                init(obj,varargin{1});
            else
                init(obj);
            end
        end
        function updateSettingsWithSystemObject(obj,sysObj)
            updateWithSystemObject(obj.Settings,sysObj);
        end
        function setKey(obj)





            persistent map;
            if isempty(map)
                map=containers.Map('KeyType','int32','ValueType','any');
                key=1;
            else
                keys=cell2mat(map.keys);
                M=max(keys);
                m=setdiff(1:M,keys);
                if isempty(m)
                    m=M+1;
                else
                    m=min(m);
                end
                key=m;
            end
            obj.MyKey=key;
            map(obj.MyKey)=obj;
            obj.MyMap=map;
        end
        function flag=isStale(obj)
            flag=obj.IsStale;
        end
        function close(obj)
            closeFilePressed(obj);
        end
        function onFigureClose(obj,~,~)

            remove(obj.MyMap,obj.MyKey);
            obj.mouseMove('clear');
            delete(obj.FigureHandle);

            drawnow;
            obj.IsStale=true;
        end

    end

    methods
        function init(obj,varargin)
            obj.setKey();
            initGUI(obj,varargin{:});
        end

    end

    methods(Access=private)
        function initGUI(obj,varargin)





            figureName=getString(message('phased:apps:arrayapp:title'));
            if obj.MyKey~=1
                figureName=[figureName,' ',num2str(obj.MyKey)];
            end


            scnSize=get(0,'ScreenSize');
            cntrPos=[(scnSize(3:4)-obj.AppSize)/2,obj.AppSize];
            cntrPos(1:2)=max([0,0],cntrPos(1:2));


            fig=figure(...
            'NumberTitle','off',...
            'Name',figureName,...
            'IntegerHandle','off',...
            'Menubar','none',...
            'Position',cntrPos,...
            'Visible','on',...
            'HandleVisibility','off',...
            'CloseRequestFcn',@obj.onFigureClose);

            obj.FigureHandle=fig;
            hHigher=uicontainer(...
            'parent',fig,...
            'tag','Sensor_Array_ContainerHandle_Parent',...
            'pos',[0,0,1,1]);
            obj.ContainerHandle=uicontainer(...
            'parent',hHigher,...
            'tag','Sensor_Array_ContainerHandle',...
            'pos',[0,0,1,0.99]);


            renderMenu(obj);

            createDialogMgr(obj);

            addDialogs(obj,varargin{:});

            obj.AxesHandler=phased.apps.internal.SensorArrayViewer.AxesController(obj,obj.DialogPanel.hBodyPanel);

            initMainGUIParts(obj);



            obj.setupMouse();
            obj.enableMouse();


            obj.refreshGUI();

        end

        function renderMenu(obj)

            file_tag=uimenu(obj.FigureHandle,'Label',...
            getString(message('phased:apps:arrayapp:FileLabel')),...
            'Tag','FileTag');
            uimenu(file_tag,'Label',...
            getString(message('phased:apps:arrayapp:GenerateReportLabel')),...
            'Callback',@obj.generateReport,'Tag',...
            'GenerateReportTag','Interruptible','off');
            uimenu(file_tag,'Label',...
            getString(message('phased:apps:arrayapp:GenerateCodeLabel')),...
            'Callback',@obj.generateCode,'Tag',...
            'GenerateCodeTag','Interruptible','off');
            uimenu(file_tag,'Label',...
            getString(message('phased:apps:arrayapp:Close')),...
            'Callback',@obj.closeFilePressed,'Tag',...
            'CloseTag','Separator','on');
            help_tag=uimenu(obj.FigureHandle,'Label',...
            getString(message('phased:apps:arrayapp:HelpLabel')),...
            'Tag','HelpTag');
            uimenu(help_tag,'Label',...
            getString(message('phased:apps:arrayapp:GUIhelp')),...
            'Callback',@obj.saaHelpPressed,'Tag',...
            'GUIHelpTag');
            uimenu(help_tag,'Label',...
            getString(message('phased:apps:arrayapp:PAThelp')),...
            'Callback',@obj.pastHelpPressed,'Tag',...
            'PATHelpTag');
            uimenu(help_tag,'Label',...
            getString(message('phased:apps:arrayapp:About')),...
            'Callback',@obj.aboutHelpPressed,'Separator','on',...
            'Tag','AboutTag');


            colorval=get(0,'DefaultUIControlBackgroundColor');
            htb=uitoolbar('Parent',obj.FigureHandle);
            obj.ZoomTools=render_zoombtns(obj.FigureHandle);
            obj.ZoomTools(1).Separator='off';
            for i=1:length(obj.ZoomTools)-1
                obj.ZoomTools(i).OnCallback=@(~,~)obj.zoomPressed;
            end
            obj.PanTool=uitoolfactory(htb,'Exploration.Pan');
            obj.PanTool.ClickedCallback=@obj.setPanButton;
            obj.PanTool.Interruptible='off';
            X=imread(fullfile(matlabroot,'toolbox','matlab',...
            'icons','tool_rotate_3d.png'),'BackgroundColor',colorval);
            icon=double(X)/(2^16-1);
            obj.RotateTool=uitoggletool(htb,'CData',icon,...
            'TooltipString',getString(message('phased:apps:arrayapp:Rotate')),...
            'ClickedCallback',@obj.setRotateButton,...
            'Enable','on','Interruptible','off');

        end

        function setupMouse(obj)






            lis.MouseMotion=addlistener(obj.FigureHandle,'WindowMouseMotion',@nullCallback);
            lis.MouseMotion.Enabled=false;

            lis.MousePress=addlistener(obj.FigureHandle,'WindowMousePress',@nullCallback);
            lis.MousePress.Enabled=false;

            lis.MouseRelease=addlistener(obj.FigureHandle,'WindowMouseRelease',@nullCallback);
            lis.MouseRelease.Enabled=false;

            lis.ScrollWheel=addlistener(obj.FigureHandle,'WindowScrollWheel',@nullCallback);
            lis.ScrollWheel.Enabled=false;

            obj.Listeners=lis;
        end


        function createDialogMgr(obj)



            theDP=dialogmgr.DPVerticalPanel(obj.ContainerHandle);

            theDP.Animation=false;
            theDP.AutoHide=false;

            theDP.PanelLock=false;
            theDP.PanelMinWidth=361;
            theDP.PanelMaxWidth=600;
            if ismac
                theDP.PanelWidth=420;
            else
                theDP.PanelWidth=370;
            end
            theDP.PanelLockWidth=false;
            theDP.SplitterWidth=8;
            theDP.hBodySplitter.ArrowCount=5;


            theDP.PixelFactor=1;
            theDP.ScrollBarWidth=18;
            theDP.BodyMinHeight=250;
            theDP.BodyMinWidth=300;
            theDP.BodyMinSizeTitle=getString(message('phased:apps:arrayapp:plot'));
            theDP.DialogBorderServicesChanges={'DialogClose','off'};
            theDP.DockLocationMouseDragEnable=true;
            theDP.DockLocation='left';
            theDP.DialogBorderFactory=@dialogmgr.DBTopBar;
            theDP.DialogHorizontalGutter=8;
            theDP.DialogVerticalGutter=8;
            theDP.DialogHoverHighlight=false;
            theDP.DialogBorderDecoration={'TitlePanelBackgroundColorSource','Auto'};
            if obj.isSettingsVisible
                theDP.DockedDialogNamesInit={getString(message('phased:apps:arrayapp:ArraySettings')),...
                getString(message('phased:apps:arrayapp:VisualizationSettings')),...
                getString(message('phased:apps:arrayapp:ArrayCharacteristics'))};
            else
                theDP.DockedDialogNamesInit={getString(message('phased:apps:arrayapp:VisualizationSettings')),...
                getString(message('phased:apps:arrayapp:ArrayCharacteristics'))};
            end


            obj.DialogPanel=theDP;
            theDP.UserData=obj;

        end

        function addDialogs(obj,varargin)


            theDP=obj.DialogPanel;



            obj.Settings=phased.apps.internal.SensorArrayViewer.SettingsDialog(obj);
            if obj.isSettingsVisible
                theDP.createAndRegisterDialog(obj.Settings);
            else


                fakeCont=uicontainer('parent',obj.FigureHandle,'pos',[0,0,1,1]);
                fakeDP=dialogmgr.DPVerticalPanel(fakeCont);
                fakeDP.DockedDialogNamesInit={getString(message('phased:apps:arrayapp:ArraySettings'))};
                fakeDP.createAndRegisterDialog(obj.Settings);
                finalizeDialogRegistration(fakeDP);
                setDialogPanelVisible(fakeDP,true)
                setVisible(fakeDP,true);
                fakeCont.Visible='off';
            end

            obj.Visualization=phased.apps.internal.SensorArrayViewer.VisualizationDialog(obj);
            theDP.createAndRegisterDialog(obj.Visualization);
            onPropertyChange(obj.Visualization,@obj.visualizationChanged);

            obj.ArrayChar=phased.apps.internal.SensorArrayViewer.ArrayCharDialog(obj);
            theDP.createAndRegisterDialog(obj.ArrayChar);

            initWithSystemObject(obj.Settings,varargin{:});
        end

        function initMainGUIParts(obj)

            theDP=obj.DialogPanel;



            finalizeDialogRegistration(theDP);


            setDialogPanelVisible(theDP,true)
            setVisible(theDP,true);



            if~ismac&&~ispc
                sppi=get(0,'ScreenPixelsPerInch');
                if sppi>72
                    dSize=1;
                    if sppi>80
                        dSize=2;
                    end
                    if sppi>90
                        dSize=3;
                    end
                    for i=1:length(obj.DialogPanel.Dialogs)
                        obj.DialogPanel.Dialogs(i).DialogContent.changeFontSize(-dSize);
                    end
                end
            end
        end

    end






    methods(Access=public)

        function visualizationChanged(obj,~,ev)






            curAT=obj.Settings.getCurArrayType();
            numElements=curAT.getArraySize();
            if obj.Visualization.getCurViewType()==phased.apps.internal.SensorArrayViewer.ViewType.ArrayDirectivity3D...
                &&numElements>obj.Settings.NumElLimit3D
                choice=questdlg(getString(message('phased:apps:arrayapp:warn3dplotstring')),...
                getString(message('phased:apps:arrayapp:warndlgName')),...
                getString(message('phased:apps:arrayapp:yes')),...
                getString(message('phased:apps:arrayapp:no')),...
                getString(message('phased:apps:arrayapp:no')));
                if strcmp(choice,getString(message('phased:apps:arrayapp:no')))


                    obj.Visualization.ViewTypeIndex=1;
                    return;
                end

                obj.Settings.NumElLimit3D=numElements;
            end


            trigger=ev.Property;
            if strcmp(trigger,'AzCutValue')
                obj.AxesHandler.azCutValueChanged();
            elseif strcmp(trigger,'ElCutValue')
                obj.AxesHandler.elCutValueChanged();
            elseif strcmp(trigger,'ShowGeometry')
                obj.AxesHandler.showGeometryChanged();
            elseif any(strcmp(trigger,{'ShowNormals','ShowIndex'}))
                obj.AxesHandler.geometryOptionChanged();
            else
                obj.AxesHandler.switchGraph();
                obj.enableToolbarBtns();
            end
        end

        function refreshGUI(obj,varargin)








            uistack(obj.Settings.Dialog.ChildDialogs(obj.Settings.ArrayTypeIndex).DialogBorder.Panel,'top');



            if~isempty(varargin)
                ev=varargin{1};
                if isa(ev,'dialogmgr.DCEvent')&&strcmp(ev.Property,'ArrayTypeIndex')

                    obj.AxesHandler.reset();
                end
            end


            obj.ArrayChar.prepareToCalculate();

            obj.Visualization.updateVisuals();

            obj.AxesHandler.prepareRedraw();

            obj.AxesHandler.switchGraph();
            obj.enableToolbarBtns();
            obj.ArrayChar.updateReadout();

        end

        function expStr=expandReportStr(~,str)
            expLength=50;
            numToExpand=expLength-length(str);
            expStr=[str,' ',repmat('.',1,numToExpand),' '];
        end
    end


    methods(Access=private)


        function saaHelpPressed(~,~,~)
            helpview([docroot,'\phased\helptargets.map'],'array_app');
        end
        function pastHelpPressed(~,~,~)

            helpview([docroot,'\phased\helptargets.map'],'phased_doc');
        end
        function aboutHelpPressed(~,~,~)
            aboutphasedtbx;
        end


        function closeFilePressed(obj,~,~)
            set(obj.FigureHandle,'HandleVisibility','on');
            close(obj.FigureHandle);
        end


        function setRotateButton(obj,~,~)
            btnState=get(obj.RotateTool,'State');
            obj.AxesHandler.setRotate(btnState);
        end



        function setPanButton(obj,~,~)
            btnState=get(obj.PanTool,'State');
            obj.AxesHandler.setPan(btnState);
        end


        function enableToolbarBtns(obj)

            [canPan,canRotate]=obj.AxesHandler.getToolbarOptions();

            if canPan
                set(obj.PanTool,'Visible','on');
            else
                set(obj.PanTool,'Visible','off');
                set(obj.PanTool,'State','off');
                obj.AxesHandler.setPan('off');
            end

            if canRotate
                set(obj.RotateTool,'Visible','on');
                obj.setRotateButton;
            else
                set(obj.RotateTool,'Visible','off');
                set(obj.RotateTool,'State','off');
                obj.AxesHandler.setRotate('off');
            end

        end


        function zoomPressed(obj)
            set(obj.PanTool,'State','off');
            set(obj.RotateTool,'State','off');

            obj.setRotateButton();
            obj.AxesHandler.setPan('off');
        end


        function generateCode(obj,~,~)

            curAT=obj.Settings.getCurArrayType();

            if~curAT.isValid()
                errHandle=errordlg('Errors were found in dialog','Unable to generate code');
                set(errHandle,'Tag','ErrorDialogTag');
                return;
            end


            curAT.applyPendingChanges();


            date_time_str=datestr(now);
            ml=ver('matlab');
            pat=ver('phased');
            local_str=['%%MATLAB Code from Sensor Array Analyzer App',...
            sprintf('\n\n'),'%%Generated by ',ml.Name,' '...
            ,ml.Version,' and ',pat.Name,' ',pat.Version,...
            '\n\n%%Generated on ',date_time_str,sprintf('\n')];

            mcode=sigcodegen.mcodebuffer;
            mcode.addcr(sprintf(local_str));

            elementType=curAT.getCurElementType();

            curAT.genCode(mcode);
            curAT.genCodeTaper(mcode);
            elementType.genCode(curAT,mcode);


            isSteered=curAT.SteeringIsOn;

            F=curAT.SignalFreqs;
            SA=curAT.SteeringAngles;
            PSB=curAT.PhaseShiftBits;
            PS=curAT.PropSpeed;

            NumSA=size(SA,2);
            NumF=length(F);
            NumPSB=length(PSB);
            if isSteered


                [SA,F,PSB]=phased.apps.internal.SensorArrayViewer.makeEqualLength(SA,F,PSB,NumSA,NumF,NumPSB);
                mcode.addcr('%Assign steering angles, frequencies and propagation speed');
                mcode.addcr(['SA = ',mat2str(SA),';']);
                mcode.addcr('%Assign number of phase shift quantization bits');
                mcode.addcr(['PSB = ',mat2str(PSB),';']);
            else
                mcode.addcr('%Assign frequencies and propagation speed');
            end
            mcode.addcr(['F = ',mat2str(F),';']);
            mcode.addcr(['PS = ',num2str(PS),';']);


            et=curAT.getCurElementType();
            elem=et.getElement(curAT);
            if et==phased.apps.internal.SensorArrayViewer.ElementType.CardioidMicrophone
                rangeStr='FrequencyVector';
            else
                rangeStr='FrequencyRange';
            end
            defaultElem=eval(class(elem));
            if et~=phased.apps.internal.SensorArrayViewer.ElementType.CustomAntenna&&...
                max(F)>max(defaultElem.(rangeStr))

                mcode.addcr('%Expand frequency range');
                mcode.addcr(['h.Element.',rangeStr,'(2) = max(F);';]);
            end


            obj.AxesHandler.genCode(mcode);

            obj.dumpGenCode(mcode);
        end

        function dumpGenCode(~,mcode)


            pause(.3);
            if(matlab.desktop.editor.isEditorAvailable)
                editorDoc=matlab.desktop.editor.newDocument;
                editorDoc.Text=mcode.string;
                editorDoc.smartIndentContents();

                editorDoc.goToLine(1);
            else
                wdisplaymatlabcode(mcode.string,'cmdwindow');
            end
        end

        function generateReport(obj,~,~)

            curAT=obj.Settings.getCurArrayType();

            if~curAT.isValid()
                errHandle=errordlg('Errors were found in dialog','Unable to generate report');
                set(errHandle,'Tag','ErrorDialogTag');
                return;
            end


            curAT.applyPendingChanges();


            date_time_str=datestr(now);
            ml=ver('matlab');
            pat=ver('phased');
            str=obj.Settings.getCurArrayType().TranslatedName;
            mcode=sigcodegen.mcodebuffer;
            mcode.addcr('% Sensor Array Analyzer Report');
            mcode.addcr('%');
            mcode.addcr(['% Generated by ',ml.Name,' ',ml.Version,' and ',pat.Name,' ',pat.Version]);
            mcode.addcr(['% Generated on ',date_time_str]);
            mcode.addcr('%');
            mcode.addcr('%');
            mcode.addcr([expandReportStr(obj,'% Array Type'),str]);
            mcode.addcr('%');









            controls=obj.Settings.getCurArrayType().Controls;

            for i=1:size(controls,1)
                if isempty(controls{i,1})||strcmpi(controls{i,1}.Visible,'off')
                    continue;
                end

                if strcmp(controls{i,2}.Tag,'ULA_NumElementsTag')||...
                    ~isempty(strfind(controls{i,2}.Tag,'Steering'))

                    continue;
                end


                title_str=controls{i,1}.String;
                title_str=regexprep(title_str,': *','');


                if strcmp(controls{i,2}.Style,'popupmenu')
                    value_str=controls{i,2}.String{controls{i,2}.Value};
                elseif strcmp(controls{i,2}.Style,'checkbox')
                    value_str='On';
                    if controls{i,2}.Value==0;
                        value_str='Off';
                    end
                else
                    value_str=controls{i,2}.String;

                    if isletter(value_str(1))


                        value_str=mat2str(evalin('base',value_str));
                    end
                end


                unit_str='';
                if~isempty(controls{i,3})
                    if strcmp(controls{i,3}.Style,'popupmenu')
                        unit_str=controls{i,3}.String{controls{i,3}.Value};
                        if~isempty(strfind(unit_str,'lambda'))
                            unit_str='wavelength';
                        end
                    else
                        unit_str=controls{i,3}.String;
                    end
                    unit_str=[' (',unit_str,')'];%#ok<AGROW>
                end

                mcode.addcr([expandReportStr(obj,['% ',title_str,unit_str]),value_str]);

            end

            obj.ArrayChar.generateReport(mcode);

            obj.dumpGenCode(mcode);
        end
    end

    methods(Access=private)
        function enableMouse(obj)
            lis=obj.Listeners;

            lis.MouseMotion.Callback=@(h,e)mouseMove(obj,h,e);
            lis.MouseMotion.Enabled=true;

            lis.MousePress.Callback=@(h,e)mouseDownEv(obj);
            lis.MousePress.Enabled=true;

            lis.MouseRelease.Enabled=false;
            lis.MouseRelease.Callback=@nullCallback;

            lis.ScrollWheel.Callback=@(h,e)wheelMove(obj,e);
            lis.ScrollWheel.Enabled=true;
        end

        function nullCallback(~,~)

        end

        function mouseDownEv(obj)



            motionFcn=mouseDown(obj.DialogPanel);
            if isempty(motionFcn)









            end



            lis=obj.Listeners;

            lis.MouseMotion.Enabled=false;
            lis.MousePress.Enabled=false;
            lis.ScrollWheel.Enabled=false;


            lis.MouseRelease.Callback=@(~,~)mouseUpEv(obj);
            lis.MouseRelease.Enabled=true;

            if~isempty(motionFcn)
                lis.MouseMotion.Callback=motionFcn;
                lis.MouseMotion.Enabled=true;
            end

        end

        function mouseUp(obj)




            lis=obj.Listeners;
            lis.MouseMotion.Enabled=false;


            handledMouseUp=mouseUp(obj.DialogPanel);
            if~handledMouseUp

            end


            enableMouse(obj);
        end

        function mouseUpEv(obj)




            lis=obj.Listeners;

            lis.MouseMotion.Enabled=false;
            lis.MouseRelease.Enabled=false;
            lis.MousePress.Enabled=false;
            lis.ScrollWheel.Enabled=false;


            handledMouseUp=mouseUp(obj.DialogPanel);
            if~handledMouseUp
            end


            enableMouse(obj);
        end

        function wheelMove(obj,ev)



            handled=mouseScrollWheel(obj.DialogPanel,ev);
            if handled
                return
            end
        end

        function mouseMove(obj,varargin)











            persistent WAV_OBJS;
            if~isempty(varargin)&&strcmp(varargin{1},'clear')
                WAV_OBJS{obj.MyKey}=[];
                return;
            end




            if obj.MyKey>length(WAV_OBJS)||isempty(WAV_OBJS{obj.MyKey})||~ishandle(WAV_OBJS{obj.MyKey}.FigureHandle)
                WAV_OBJS{obj.MyKey}=obj;
            end

            if numel(varargin)>1
                point=varargin{2}.Point;
                obj.FigureHandle.CurrentPoint=point;
            end

            if mouseMove(obj.DialogPanel)


                return
            end
        end
    end
end
