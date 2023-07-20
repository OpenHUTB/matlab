classdef SolverProfilerToolstripClass<handle












    properties(SetAccess=private)
MainTab
SaveButton
SaveButtonPopup_data
SaveButtonPopup_rule
OpenButton
OpenButtonPopup_data
OpenButtonPopup_rule
SscStiffEdit

StateCheckbox
LogZCCheckbox
SimlogCheckbox
JacobianCheckbox
SscStiffButton
RuleButton

FromTextbox
ToTextbox
BufferTextbox

RunButton
StopButton

ZoomInButton
ZoomOutButton
PanButton

ZCCheckbox
ExceptionCheckbox
ResetCheckbox
JacobianUpdateCheckbox

HiliteButton
RemoveButton
TraceSrcButton
SrcFileButton

SEButton
SSCButton
ZEButton
ExportTabButton
BarText
ProgressBar
    end

    methods

        function obj=SolverProfilerToolstripClass(h,mdl)
            import solverprofiler.util.*
            import matlab.ui.internal.toolstrip.*


            strFrom=utilDAGetString('From');
            strTo=utilDAGetString('To');
            strBuffer=utilDAGetString('buffer');


            strGeneralExplorer=utilDAGetString('generalExplorer');
            strSimscapeExplorer=utilDAGetString('simscapeExplorer');


            tabgroup=TabGroup();
            tabgroup.Tag='tabMain';
            tabMain=tabgroup.addTab(utilDAGetString('Profiler'));
            obj.MainTab=tabMain;
            h.addTabGroup(tabgroup);


            fileSec=obj.createSection('secFile','file');


            col=fileSec.addColumn();
            icon=Icon.OPEN_24;
            obj.OpenButton=obj.createButton('loadButton','load','loadTip',icon,true,'split');
            col.add(obj.OpenButton);


            items1=ListItem(utilDAGetString('loadSession'),icon);
            items2=ListItem(utilDAGetString('loadRule'),icon);
            popup=PopupList();
            popup.add(items1);
            popup.add(items2);
            obj.OpenButtonPopup_data=items1;
            obj.OpenButtonPopup_rule=items2;
            obj.OpenButton.Popup=popup;

            col=fileSec.addColumn();
            icon=Icon.SAVE_DIRTY_24;
            obj.SaveButton=obj.createButton('saveButton','save','saveTip',icon,false,'split');
            col.add(obj.SaveButton);


            items1=ListItem(utilDAGetString('saveSession'),icon);
            items2=ListItem(utilDAGetString('saveRule'),icon);
            popup=PopupList();
            popup.add(items1);
            popup.add(items2);
            obj.SaveButtonPopup_data=items1;
            obj.SaveButtonPopup_rule=items2;
            obj.SaveButton.Popup=popup;


            configSec=obj.createSection('secSetup','setup');


            configSet=getActiveConfigSet(mdl);
            tStart=configSet.get_param('StartTime');
            tStop=configSet.get_param('StopTime');

            fromText=Label(strFrom);
            toText=Label(strTo);
            bufferText=Label(strBuffer);

            col=configSec.addColumn();
            col.add(fromText);
            col.add(toText);
            col.add(bufferText);

            col=configSec.addColumn('width',55);
            obj.FromTextbox=obj.createTextBox('fromTextbox',tStart,'fromTip');
            obj.ToTextbox=obj.createTextBox('toTextbox',tStop,'toTip');
            obj.BufferTextbox=obj.createTextBox('bufferTextbox',200000,'bufferTip');
            col.add(obj.FromTextbox);
            col.add(obj.ToTextbox);
            col.add(obj.BufferTextbox);


            col=configSec.addColumn();
            obj.StateCheckbox=obj.createCheckbox('logStateCheckbox','logStates','stateCheckboxTip',true,false);
            obj.LogZCCheckbox=obj.createCheckbox('logZCCheckbox','logZC','logZCCheckboxTip',true,false);
            obj.SimlogCheckbox=obj.createCheckbox('logSimlogCheckbox','logSimlog','simlogCheckboxTip',true,false);
            col.add(obj.StateCheckbox);
            col.add(obj.SimlogCheckbox);
            col.add(obj.LogZCCheckbox);

            col=configSec.addColumn();
            obj.JacobianCheckbox=obj.createCheckbox('logJacobianCheckbox','logJacobian','jacobianCheckboxTip',true,false);


            obj.SscStiffEdit=ListItemWithEditField(utilDAGetString('SscStiffAtTimes'),'[]','at times');
            popup=PopupList();
            popup.add(obj.SscStiffEdit);
            obj.SscStiffButton=obj.createButton('sscStiffButton','simscapeStiffness',...
            'simscapeStiffnessCheckboxTip',Icon.PROPERTIES_16,true,'dropdown');
            obj.SscStiffButton.Popup=popup;

            obj.RuleButton=obj.createButton('ruleButton','rule','ruleTip',Icon.PROPERTIES_16,true,'reg');
            col.add(obj.JacobianCheckbox);
            col.add(obj.SscStiffButton);
            col.add(obj.RuleButton);


            profileSec=obj.createSection('secSim','profile');


            col=profileSec.addColumn();
            obj.RunButton=obj.createButton('runButton','run',[],Icon.PLAY_24,true,'reg');
            col.add(obj.RunButton);

            col=profileSec.addColumn();
            obj.StopButton=obj.createButton('stopButton','stop',[],Icon.STOP_24,false,'reg');
            col.add(obj.StopButton);


            viewSec=obj.createSection('secView','view');


            col=viewSec.addColumn();
            obj.ZoomInButton=obj.createButton('zoomInButton','','zoomInTip',Icon.ZOOM_IN_16,false,'tog');
            obj.ZoomOutButton=obj.createButton('zoomOutButton','','zoomOutTip',Icon.ZOOM_OUT_16,false,'tog');
            obj.PanButton=obj.createButton('panButton','','panTip',Icon.PAN_16,false,'tog');
            col.add(obj.ZoomInButton);
            col.add(obj.ZoomOutButton);
            col.add(obj.PanButton);


            col=viewSec.addColumn();
            obj.ExceptionCheckbox=obj.createCheckbox('exceptionCheckbox','Solverexception','exceptionCheckboxTip',false,false);
            obj.JacobianUpdateCheckbox=obj.createCheckbox('jacobianUpdateCheckbox','Solverjacobian','jacobianUpdateCheckboxTip',false,false);
            col.add(obj.ExceptionCheckbox);
            col.add(obj.JacobianUpdateCheckbox);

            col=viewSec.addColumn();
            obj.ResetCheckbox=obj.createCheckbox('resetCheckbox','Solverreset','resetCheckboxTip',false,false);
            obj.ZCCheckbox=obj.createCheckbox('zcCheckbox','Zerocrossing','zcCheckboxTip',false,false);
            col.add(obj.ResetCheckbox);
            col.add(obj.ZCCheckbox);


            traceSec=obj.createSection('secTrace','trace');
            icons_folder=slfullfile(matlabroot,'toolbox','simulink','sl_solver_profiler','+solverprofiler','icons');


            col=traceSec.addColumn();
            filename=slfullfile(icons_folder,'spicon_highlight_in_model_24.png');
            obj.HiliteButton=obj.createButton('hiliteButton','hilite','hiliteTip',Icon(filename),false,'split');
            col.add(obj.HiliteButton);

            filename=slfullfile(icons_folder,'spicon_trace_to_source_16.png');
            item1=obj.createListItem('source','traceSrc','traceSrcTip',Icon(filename),false);
            filename=slfullfile(icons_folder,'spicon_remove_trace_16.png');
            item2=obj.createListItem('removeButton','removeTrace','removeTraceTip',Icon(filename),false);
            item3=obj.createListItem('sourceFileButton','showFile','showFileTip',Icon.FIND_FILES_16,false);
            obj.TraceSrcButton=item1;
            obj.RemoveButton=item2;
            obj.SrcFileButton=item3;

            popup=PopupList();
            popup.add(item1);
            popup.add(item2);
            popup.add(item3);
            obj.HiliteButton.Popup=popup;


            traceSec=obj.createSection('secExplore','explore');
            col=traceSec.addColumn();


            filename=slfullfile(icons_folder,'spicon_states_explorer_24.png');
            obj.SEButton=obj.createGalleryItem('stateExplorer','statesExplorer','statesExplorerTip',Icon(filename),false);
            obj.updateStatesExplorerButtonTooltip();

            filename=slfullfile(icons_folder,'spicon_zerocrossing_explorer_24.png');
            obj.ZEButton=obj.createGalleryItem('zcExplorer','zcExplorer','zcExplorerTip',Icon(filename),false);

            filename=slfullfile(icons_folder,'spicon_simscape_explorer_24.png');
            obj.SSCButton=obj.createGalleryItem('sscExplorer','SSCExplorer','SSCTip',Icon(filename),false);

            popup=GalleryPopup();
            category=matlab.ui.internal.toolstrip.GalleryCategory(strGeneralExplorer);
            category.add(obj.SEButton);
            category.add(obj.ZEButton);
            popup.add(category);

            category=matlab.ui.internal.toolstrip.GalleryCategory(strSimscapeExplorer);
            category.add(obj.SSCButton);
            popup.add(category);

            gallery=Gallery(popup,'MaxColumnCount',3,'MinColumnCount',1);
            col.add(gallery);


            shareSec=obj.createSection('secShare','share');


            col=shareSec.addColumn();
            obj.ExportTabButton=obj.createButton('exportButton','exportTab','exportTabTip',Icon.EXPORT_24,false,'reg');
            col.add(obj.ExportTabButton);


            bar=matlab.ui.internal.statusbar.StatusBar();
            bar.Tag="statusBar";
            obj.BarText=matlab.ui.internal.statusbar.StatusLabel();
            obj.BarText.Tag="statusText";
            obj.BarText.Text="";
            obj.ProgressBar=matlab.ui.internal.statusbar.StatusProgressBar();
            bar.add(obj.BarText);
            bar.add(obj.ProgressBar);
            h.add(bar);
            obj.hideBar();
        end


        function delete(~)
        end


        function attachCallback(obj,iconName,type,fhandle)
            addlistener(obj.(iconName),type,fhandle);
        end


        function enableIcon(obj,iconName)
            obj.(iconName).Enabled=true;
        end


        function disableIcon(obj,iconName)
            obj.(iconName).Enabled=false;
        end


        function unselectZoomIn(obj)
            obj.ZoomInButton.Value=false;
        end


        function unselectZoomOut(obj)
            obj.ZoomOutButton.Value=false;
        end


        function unselectPan(obj)
            obj.PanButton.Value=false;
        end


        function val=isZoomInSelected(obj)
            val=obj.ZoomInButton.Value;
        end


        function val=isZoomOutSelected(obj)
            val=obj.ZoomOutButton.Value;
        end


        function val=isPanSelected(obj)
            val=obj.PanButton.Value;
        end


        function enableViewPanel(obj)
            obj.ZoomInButton.Enabled=true;
            obj.ZoomOutButton.Enabled=true;
            obj.PanButton.Enabled=true;
        end


        function disableViewPanel(obj)
            obj.ZoomInButton.Enabled=false;
            obj.ZoomOutButton.Enabled=false;
            obj.PanButton.Enabled=false;
        end


        function disableLogPanel(obj)
            obj.StateCheckbox.Enabled=false;
            obj.LogZCCheckbox.Enabled=false;
            obj.SimlogCheckbox.Enabled=false;
            obj.JacobianCheckbox.Enabled=false;
            obj.SscStiffButton.Enabled=false;
            obj.FromTextbox.Enabled=false;
            obj.ToTextbox.Enabled=false;
            obj.BufferTextbox.Enabled=false;
            obj.RuleButton.Enabled=false;
        end


        function enableLogPanel(obj)
            obj.StateCheckbox.Enabled=true;
            obj.LogZCCheckbox.Enabled=true;
            obj.SimlogCheckbox.Enabled=true;
            obj.FromTextbox.Enabled=true;
            obj.ToTextbox.Enabled=true;
            obj.BufferTextbox.Enabled=true;
            obj.JacobianCheckbox.Enabled=true;
            obj.SscStiffButton.Enabled=true;
            obj.RuleButton.Enabled=true;
        end



        function disableHiliteAndTrace(obj)
            obj.HiliteButton.Enabled=false;
            obj.TraceSrcButton.Enabled=false;
        end

        function enableTraceIcons(obj)
            obj.TraceSrcButton.Enabled=true;
        end

        function disableTraceIcons(obj)
            obj.TraceSrcButton.Enabled=false;
        end

        function uiStatus=getUIStatusAtSim(obj)
            uiStatus.from=obj.getFromTime();
            uiStatus.to=obj.getToTime();
            uiStatus.buffer=obj.getBufferValue();
            uiStatus.state=obj.getStateCheckbox();
            uiStatus.zc=obj.getLogZCCheckbox();
            uiStatus.simlog=obj.getSimlogCheckbox();
            uiStatus.jacobian=obj.getJacobianCheckbox();
        end

        function restoreUIStatusAtSim(obj,uiStatus)
            obj.setFromTime(uiStatus.from);
            obj.setToTime(uiStatus.to);
            obj.setBuffer(uiStatus.buffer);
            obj.setStateCheckbox(uiStatus.state);
            obj.setLogZCCheckbox(uiStatus.zc);
            obj.setSimlogCheckbox(uiStatus.simlog);
            obj.setJacobianCheckbox(uiStatus.jacobian);
        end


        function text=getFromTime(obj)
            text=obj.FromTextbox.Value;
        end

        function text=getToTime(obj)
            text=obj.ToTextbox.Value;
        end

        function text=getBufferValue(obj)
            text=obj.BufferTextbox.Value;
        end

        function selected=getStateCheckbox(obj)
            selected=obj.StateCheckbox.Value;
        end

        function selected=getLogZCCheckbox(obj)
            selected=obj.LogZCCheckbox.Value;
        end

        function selected=getSimlogCheckbox(obj)
            selected=obj.SimlogCheckbox.Value;
        end

        function selected=getJacobianCheckbox(obj)
            selected=obj.JacobianCheckbox.Value;
        end

        function setFromTime(obj,txt)
            obj.FromTextbox.Value=txt;
        end

        function setToTime(obj,txt)
            obj.ToTextbox.Value=txt;
        end

        function setBuffer(obj,txt)
            obj.BufferTextbox.Value=txt;
        end

        function setStateCheckbox(obj,selected)
            obj.StateCheckbox.Value=selected;
        end

        function setLogZCCheckbox(obj,selected)
            obj.LogZCCheckbox.Value=selected;
        end

        function setSimlogCheckbox(obj,selected)
            obj.SimlogCheckbox.Value=selected;
        end

        function setJacobianCheckbox(obj,selected)
            obj.JacobianCheckbox.Value=selected;
        end


        function setBarText(obj,text)
            obj.BarText.Enabled=true;
            obj.BarText.Text=text;
        end


        function setBarValue(obj,value)
            obj.ProgressBar.Enabled=true;
            obj.ProgressBar.Value=int64(value);
        end


        function showBar(obj)
            obj.BarText.Enabled=true;
            obj.ProgressBar.Enabled=true;
        end


        function hideBar(obj)
            obj.ProgressBar.Value=0;
            obj.BarText.Text='';
            obj.ProgressBar.Enabled=false;
            obj.BarText.Enabled=false;
        end


        function changeRunButtonTo(obj,type)
            import solverprofiler.util.*
            import matlab.ui.internal.toolstrip.*

            if strcmp(type,'Run')
                obj.RunButton.Icon=Icon.PLAY_24;
                obj.RunButton.Text=utilDAGetString('run');
                obj.RunButton.Enabled=false;
            elseif strcmp(type,'Pause')
                obj.RunButton.Icon=Icon.PAUSE_24;
                obj.RunButton.Text=utilDAGetString('pause');
                obj.RunButton.Enabled=false;
            elseif strcmp(type,'Continue')
                obj.RunButton.Icon=Icon.PLAY_24;
                obj.RunButton.Text=utilDAGetString('continue');
                obj.RunButton.Enabled=false;
            end
        end

        function status=isZCCheckboxSelected(obj)
            status=obj.ZCCheckbox.Value;
        end

        function status=isExceptionCheckboxSelected(obj)
            status=obj.ExceptionCheckbox.Value;
        end

        function status=isResetCheckboxSelected(obj)
            status=obj.ResetCheckbox.Value;
        end

        function status=isJacobianCheckboxSelected(obj)
            status=obj.JacobianUpdateCheckbox.Value;
        end

        function setZCCheckbox(obj,status)
            obj.ZCCheckbox.Value=status;
        end

        function setExceptionCheckbox(obj,status)
            obj.ExceptionCheckbox.Value=status;
        end

        function setResetCheckbox(obj,status)
            obj.ResetCheckbox.Value=status;
        end

        function setJacobianUpdateCheckbox(obj,status)
            obj.JacobianUpdateCheckbox.Value=status;
        end

        function updateStatesExplorerButtonTooltip(obj)
            import solverprofiler.util.*
            if obj.SEButton.Enabled
                obj.SEButton.Description=utilDAGetString('statesExplorerTip');
            else
                obj.SEButton.Description=utilDAGetString('statesExplorerTipOff');
            end
        end

    end


    methods(Access=private)


        function section=createSection(obj,tag,key)
            import solverprofiler.util.*
            import matlab.ui.internal.toolstrip.*

            section=Section(utilDAGetString(key));
            section.Tag=tag;
            obj.MainTab.add(section);
        end

    end


    methods(Static)

        function item=createGalleryItem(tag,nameKey,tipKey,icon,enabled)
            import solverprofiler.util.*
            import matlab.ui.internal.toolstrip.*
            item=GalleryItem(utilDAGetString(nameKey),icon);
            item.Tag=tag;
            item.Enabled=enabled;
            item.Description=utilDAGetString(tipKey);
        end


        function item=createListItem(tag,nameKey,tipKey,icon,enabled)
            import solverprofiler.util.*
            import matlab.ui.internal.toolstrip.*

            item=ListItem(utilDAGetString(nameKey),icon);
            item.Tag=tag;
            item.Enabled=enabled;
            item.Description=utilDAGetString(tipKey);
        end


        function checkbox=createCheckbox(tag,nameKey,tipKey,enabled,value)
            import solverprofiler.util.*
            import matlab.ui.internal.toolstrip.*

            checkbox=CheckBox(utilDAGetString(nameKey));
            checkbox.Tag=tag;
            checkbox.Enabled=enabled;
            checkbox.Value=value;
            checkbox.Description=utilDAGetString(tipKey);
        end


        function button=createButton(tag,nameKey,tipKey,icon,enabled,type)
            import solverprofiler.util.*
            import matlab.ui.internal.toolstrip.*

            if isempty(nameKey)
                buttonName='';
            else
                buttonName=sprintf(utilDAGetString(nameKey));
            end

            switch(type)
            case 'reg'
                button=Button(buttonName,icon);
            case 'tog'
                button=ToggleButton(buttonName,icon);
            case 'dropdown'
                button=DropDownButton(buttonName);
            case 'split'
                button=SplitButton(buttonName,icon);
            end

            button.Tag=tag;

            if~isempty(tipKey)
                button.Description=utilDAGetString(tipKey);
            end

            button.Enabled=enabled;
        end


        function textbox=createTextBox(tag,value,tipKey)
            import solverprofiler.util.*
            import matlab.ui.internal.toolstrip.*

            textbox=EditField(num2str(value));
            textbox.Tag=tag;
            if(~isempty(tipKey))
                textbox.Description=utilDAGetString(tipKey);
            end

        end

    end

end
