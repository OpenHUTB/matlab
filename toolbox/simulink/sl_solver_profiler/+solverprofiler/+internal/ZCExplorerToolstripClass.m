classdef ZCExplorerToolstripClass<handle

    properties(SetAccess=private)
FromTextbox
ToTextbox
ZoomInButton
ZoomOutButton
PanButton
EventCheckbox
HiliteButton
GoToFileButton
RemoveButton
TraceSrcButton
NewPlotButton
    end

    methods


        function obj=ZCExplorerToolstripClass(h,tSpan)
            import matlab.ui.internal.toolstrip.*


            strFrom=obj.DAGetString('From');
            strTo=obj.DAGetString('To');
            strZoomIn=obj.DAGetString('zoomIn');
            strZoomOut=obj.DAGetString('zoomOut');
            strPan=obj.DAGetString('pan');
            strShowFile=obj.DAGetString('showFile');
            strHilite=obj.DAGetString('hilite');
            strTraceSrc=obj.DAGetString('traceSrc');
            strRemoveTrace=obj.DAGetString('removeTrace');
            strNewPlot=obj.DAGetString('newPlot');


            strRange=obj.DAGetString('range');
            strView=obj.DAGetString('view');
            strFilter=obj.DAGetString('filter');
            strTrace=obj.DAGetString('trace');
            strShare=obj.DAGetString('share');


            strFromSETip=obj.DAGetString('fromSETip');
            strToSETip=obj.DAGetString('toSETip');
            strShowFileTip=obj.DAGetString('showFileTip');
            strHiliteTip=obj.DAGetString('hiliteTip');
            strRemoveTraceTip=obj.DAGetString('removeTraceTip');
            strTraceSrcTip=obj.DAGetString('traceSrcTip');
            strNewPlotTip=obj.DAGetString('newPlotTip');


            tabgroup=TabGroup();
            tabgroup.Tag='tabMain';
            tabMain=tabgroup.addTab(obj.DAGetString('ZCExplorer'));
            h.addTabGroup(tabgroup);


            sec=Section(strRange);
            sec.Tag='secRange';
            tabMain.add(sec);

            col=sec.addColumn();
            fromText=Label(strFrom);
            toText=Label(strTo);
            col.add(fromText);
            col.add(toText);


            col=sec.addColumn('Width',75);
            obj.FromTextbox=EditField(num2str(tSpan(1)));
            obj.FromTextbox.Tag='fromTextbox';
            obj.FromTextbox.Description=strFromSETip;
            obj.ToTextbox=EditField(num2str(tSpan(2)));
            obj.ToTextbox.Tag='toTextbox';
            obj.ToTextbox.Description=strToSETip;
            col.add(obj.FromTextbox);
            col.add(obj.ToTextbox);


            sec=Section(strView);
            sec.Tag='secView';
            tabMain.add(sec);


            col=sec.addColumn();
            obj.ZoomInButton=ToggleButton(strZoomIn,Icon.ZOOM_IN_16);
            obj.ZoomInButton.Tag='zoomInButton';
            obj.ZoomOutButton=ToggleButton(strZoomOut,Icon.ZOOM_OUT_16);
            obj.ZoomOutButton.Tag='zoomOutButton';
            obj.PanButton=ToggleButton(strPan,Icon.PAN_16);
            obj.PanButton.Tag='panButton';
            col.add(obj.ZoomInButton);
            col.add(obj.ZoomOutButton);
            col.add(obj.PanButton);


            sec=Section(strFilter);
            sec.Tag='secFilter';
            tabMain.add(sec);
            col=sec.addColumn();


            obj.EventCheckbox=CheckBox(obj.DAGetString('event'));
            obj.EventCheckbox.Tag='eventsCheckbox';
            obj.EventCheckbox.Description=obj.DAGetString('zcCheckboxTip');
            obj.EventCheckbox.Value=true;
            col.add(obj.EventCheckbox);


            sec=Section(strTrace);
            sec.Tag='secTrace';
            tabMain.add(sec);


            col=sec.addColumn();
            icon=Icon.FIND_FILES_24;
            obj.GoToFileButton=Button(sprintf(strShowFile),icon);
            obj.GoToFileButton.Tag='goToFileButton';
            obj.GoToFileButton.Description=strShowFileTip;
            col.add(obj.GoToFileButton);


            col=sec.addColumn();
            filename=fullfile(matlabroot,'toolbox','simulink','sl_solver_profiler',...
            '+solverprofiler','icons','spicon_highlight_in_model_24.png');
            icon=Icon(filename);
            obj.HiliteButton=Button(sprintf(strHilite),icon);
            obj.HiliteButton.Tag='hiliteButton';
            obj.HiliteButton.Description=strHiliteTip;
            col.add(obj.HiliteButton);


            col=sec.addColumn();
            filename=fullfile(matlabroot,'toolbox','simulink','sl_solver_profiler',...
            '+solverprofiler','icons','spicon_trace_to_source_16.png');
            icon=Icon(filename);
            obj.TraceSrcButton=Button(sprintf(strTraceSrc),icon);
            obj.TraceSrcButton.Tag='sourceButton';
            obj.TraceSrcButton.Description=strTraceSrcTip;
            filename=fullfile(matlabroot,'toolbox','simulink','sl_solver_profiler',...
            '+solverprofiler','icons','spicon_remove_trace_16.png');
            icon=Icon(filename);
            obj.RemoveButton=Button(sprintf(strRemoveTrace),icon);
            obj.RemoveButton.Tag='removeButton';
            obj.RemoveButton.Description=strRemoveTraceTip;
            obj.RemoveButton.Enabled=false;
            col.add(obj.TraceSrcButton);
            col.add(obj.RemoveButton);


            sec=Section(strShare);
            sec.Tag='secShare';
            tabMain.add(sec);


            col=sec.addColumn();
            filename=fullfile(matlabroot,'toolbox','simulink','sl_solver_profiler',...
            '+solverprofiler','icons','spicon_send_to_figure_24.png');
            icon=Icon(filename);
            obj.NewPlotButton=Button(sprintf(strNewPlot),icon);
            obj.NewPlotButton.Tag='newPlotButton';
            obj.NewPlotButton.Description=strNewPlotTip;
            col.add(obj.NewPlotButton);
        end


        function delete(~)

        end


        function setFromTime(obj,value)
            obj.FromTextbox.Value=num2str(value);
        end

        function setToTime(obj,value)
            obj.ToTextbox.Value=num2str(value);
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


        function val=isEventCheckboxSelected(obj)
            val=obj.EventCheckbox.Value;
        end


        function enableTrace(obj)
            obj.TraceSrcButton.Enabled=true;
        end

        function disableTrace(obj)
            obj.TraceSrcButton.Enabled=false;
        end

        function enableGoToFileButton(obj)
            obj.GoToFileButton.Enabled=true;
        end

        function disableGoToFileButton(obj)
            obj.GoToFileButton.Enabled=false;
        end

        function enableRemoveButton(obj)
            obj.RemoveButton.Enabled=true;
        end

        function disableRemoveButton(obj)
            obj.RemoveButton.Enabled=false;
        end


        function attachCallback(obj,iconName,type,fhandle)
            obj.(iconName).(type)=fhandle;
        end


        function fromTextboxValue=getFromTextboxValue(obj)
            fromTextboxValue=str2double(obj.FromTextbox.Value);
        end

        function toTextboxValue=getToTextboxValue(obj)
            toTextboxValue=str2double(obj.ToTextbox.Value);
        end

    end

    methods(Static)

        function value=DAGetString(key)
            value=DAStudio.message(['Simulink:solverProfiler:',key]);
        end
    end

end