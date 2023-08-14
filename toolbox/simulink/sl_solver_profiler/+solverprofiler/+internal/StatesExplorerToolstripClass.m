classdef StatesExplorerToolstripClass<handle

    properties(SetAccess=private)
MainTab
FromTextbox
ToTextbox
RankPulldown
EditButton
ZoomInButton
ZoomOutButton
PanButton
NewtonCheckbox
ErrorControlCheckbox
HiliteButton
RemoveButton
TraceSrcButton
NewPlotButton
    end

    methods

        function SEToolstrip=StatesExplorerToolstripClass(h,tSpan,customAlg)
            import solverprofiler.util.*
            import matlab.ui.internal.toolstrip.*


            strFrom=SEToolstrip.DAGetString('From');
            strTo=SEToolstrip.DAGetString('To');
            strRankBy=SEToolstrip.DAGetString('rankBy');
            strType1=SEToolstrip.DAGetString('stateRankType1');
            strType2=SEToolstrip.DAGetString('stateRankType2');
            strType3=SEToolstrip.DAGetString('stateRankType3');
            strType4=SEToolstrip.DAGetString('stateRankType4');
            strType5=SEToolstrip.DAGetString('stateRankType5');
            strType6=SEToolstrip.DAGetString('stateRankType6');


            strExplorer=SEToolstrip.DAGetString('Explorer');


            strRankTip=SEToolstrip.DAGetString('rankTip');

            tabgroup=TabGroup();
            tabgroup.Tag='tabMain';
            tabMain=tabgroup.addTab(strExplorer);
            SEToolstrip.MainTab=tabMain;


            setupPanel=SEToolstrip.createPanel('secSetup','range');


            fromText=Label(strFrom);
            toText=Label(strTo);


            col=setupPanel.addColumn('Width',60);
            col.add(fromText);
            col.add(toText);

            col=setupPanel.addColumn('Width',60);
            SEToolstrip.FromTextbox=SEToolstrip.createTextBox('fromTextbox',tSpan(1),'fromSETip');
            SEToolstrip.ToTextbox=SEToolstrip.createTextBox('toTextbox',tSpan(2),'toSETip');
            col.add(SEToolstrip.FromTextbox);
            col.add(SEToolstrip.ToTextbox);


            rankPanel=SEToolstrip.createPanel('secRank','rank');


            rankText=Label(strRankBy);
            col=rankPanel.addColumn();
            col.add(rankText);

            SEToolstrip.RankPulldown=DropDown(...
            {strType1;strType2;strType3;strType4;strType5;strType6});
            SEToolstrip.RankPulldown.Tag='rankPulldown';
            SEToolstrip.RankPulldown.Description=strRankTip;
            SEToolstrip.RankPulldown.Value=strType1;
            col.add(SEToolstrip.RankPulldown);


            source=fullfile(matlabroot,'toolbox','shared','controllib','general','resources','toolstrip_icons','Edit.png');
            icon=matlab.ui.internal.toolstrip.Icon(source);
            SEToolstrip.EditButton=...
            SEToolstrip.createButton('Button','editButton',[],'editTip',icon,true);
            col=rankPanel.addColumn();
            col.add(EmptyControl());
            col.add(SEToolstrip.EditButton);


            SEToolstrip.initializeCustomRankingOptions(customAlg);


            viewPanel=SEToolstrip.createPanel('secView','view');


            SEToolstrip.ZoomInButton=SEToolstrip.createButton('ToggleButton','zoomInButton','zoomIn',[],Icon.ZOOM_IN_16,true);
            SEToolstrip.ZoomOutButton=SEToolstrip.createButton('ToggleButton','zoomOutButton','zoomOut',[],Icon.ZOOM_OUT_16,true);
            SEToolstrip.PanButton=SEToolstrip.createButton('ToggleButton','panButton','pan',[],Icon.PAN_16,true);

            col=viewPanel.addColumn();
            col.add(SEToolstrip.ZoomInButton);
            col.add(SEToolstrip.ZoomOutButton);
            col.add(SEToolstrip.PanButton);


            filterPanel=SEToolstrip.createPanel('secFilter','filter');


            SEToolstrip.NewtonCheckbox=SEToolstrip.createCheckbox('newtonCheckbox','newtonDAE',...
            'newtonDAECheckboxTip',true,false);


            SEToolstrip.ErrorControlCheckbox=SEToolstrip.createCheckbox('errorControlCheckbox','errorControl',...
            'otherCheckboxTip',true,false);

            col=filterPanel.addColumn();
            col.add(SEToolstrip.NewtonCheckbox);
            col.add(SEToolstrip.ErrorControlCheckbox);


            tracePanel=SEToolstrip.createPanel('secTrace','trace');


            filename=fullfile(matlabroot,'toolbox','simulink','sl_solver_profiler','+solverprofiler','icons','spicon_highlight_in_model_24.png');
            SEToolstrip.HiliteButton=SEToolstrip.createButton('Button','hiliteButton','hilite','hiliteTip',Icon(filename),true);

            col=tracePanel.addColumn();
            col.add(SEToolstrip.HiliteButton);


            filename=fullfile(matlabroot,'toolbox','simulink','sl_solver_profiler',...
            '+solverprofiler','icons','spicon_remove_trace_16.png');
            SEToolstrip.RemoveButton=SEToolstrip.createButton('Button','removeButton','removeTrace','removeTraceTip',Icon(filename),false);


            filename=fullfile(matlabroot,'toolbox','simulink','sl_solver_profiler',...
            '+solverprofiler','icons','spicon_trace_to_source_16.png');
            SEToolstrip.TraceSrcButton=SEToolstrip.createButton('Button','source','traceSrc','traceSrcTip',Icon(filename),false);

            col=tracePanel.addColumn();
            col.add(SEToolstrip.TraceSrcButton);
            col.add(SEToolstrip.RemoveButton);


            sharePanel=SEToolstrip.createPanel('secShare','share');


            filename=fullfile(matlabroot,'toolbox','simulink','sl_solver_profiler',...
            '+solverprofiler','icons','spicon_send_to_figure_24.png');
            SEToolstrip.NewPlotButton=SEToolstrip.createButton('Button','newPlotButton','newPlot','newPlotTip',Icon(filename),true);

            col=sharePanel.addColumn();
            col.add(SEToolstrip.NewPlotButton);

            h.addTabGroup(tabgroup);
        end


        function delete(~)

        end

        function initializeCustomRankingOptions(SEToolstrip,customAlg)
            if isempty(customAlg)
                return;
            end
            for i=1:length(customAlg(:,1))
                addpath(customAlg{i,1});
                SEToolstrip.addItemInPullDown(customAlg{i,2});
            end
        end

        function addItemInPullDown(SEToolstrip,item)
            SEToolstrip.RankPulldown.addItem(item);
        end

        function removeItemInPullDown(SEToolstrip,item)
            SEToolstrip.RankPulldown.removeItem(item);
        end


        function setFromTime(SEToolstrip,value)
            SEToolstrip.FromTextbox.Value=num2str(value);
        end

        function setToTime(SEToolstrip,value)
            SEToolstrip.ToTextbox.Value=num2str(value);
        end


        function unselectZoomIn(SEToolstrip)
            SEToolstrip.ZoomInButton.Value=false;
        end


        function unselectZoomOut(SEToolstrip)
            SEToolstrip.ZoomOutButton.Value=false;
        end


        function unselectPan(SEToolstrip)
            SEToolstrip.PanButton.Value=false;
        end


        function val=isZoomInSelected(SEToolstrip)
            val=SEToolstrip.ZoomInButton.Value;
        end


        function val=isZoomOutSelected(SEToolstrip)
            val=SEToolstrip.ZoomOutButton.Value;
        end


        function val=isPanSelected(SEToolstrip)
            val=SEToolstrip.PanButton.Value;
        end


        function enableTrace(SEToolstrip)
            SEToolstrip.TraceSrcButton.Enabled=true;
        end

        function disableTrace(SEToolstrip)
            SEToolstrip.TraceSrcButton.Enabled=false;
        end

        function enableRemoveButton(SEToolstrip)
            SEToolstrip.RemoveButton.Enabled=true;
        end

        function disableRemoveButton(SEToolstrip)
            SEToolstrip.RemoveButton.Enabled=false;
        end


        function attachCallback(SEToolstrip,iconName,type,fhandle)
            addlistener(SEToolstrip.(iconName),type,fhandle);
        end


        function fromTextboxValue=getFromTextboxValue(SEToolstrip)
            fromTextboxValue=str2double(SEToolstrip.FromTextbox.Value);
        end

        function toTextboxValue=getToTextboxValue(SEToolstrip)
            toTextboxValue=str2double(SEToolstrip.ToTextbox.Value);
        end


        function selectNewtonCheckbox(SEToolstrip)
            SEToolstrip.NewtonCheckbox.Value=true;
        end


        function selectErrorControlCheckbox(SEToolstrip)
            SEToolstrip.ErrorControlCheckbox.Value=true;
        end


        function status=isNewtonCheckboxSelected(SEToolstrip)
            status=SEToolstrip.NewtonCheckbox.Value;
        end

        function status=isErrorControlCheckboxSelected(SEToolstrip)
            status=SEToolstrip.ErrorControlCheckbox.Value;
        end


        function selectedRankType=getSelectedRankType(SEToolstrip)
            selectedRankType=SEToolstrip.RankPulldown.SelectedIndex;
        end
    end

    methods(Access=private)

        function section=createPanel(SEToolstrip,tag,key)
            import solverprofiler.util.*
            import matlab.ui.internal.toolstrip.*

            section=Section(utilDAGetString(key));
            section.Tag=tag;
            SEToolstrip.MainTab.add(section);
        end

    end

    methods(Static)

        function value=DAGetString(key)
            value=DAStudio.message(['Simulink:solverProfiler:',key]);
        end


        function textbox=createTextBox(tag,value,tipKey)
            import solverprofiler.util.*
            import matlab.ui.internal.toolstrip.*

            textbox=EditField(num2str(value));
            textbox.Tag=tag;
            textbox.Description=utilDAGetString(tipKey);

        end


        function button=createButton(buttonType,tag,nameKey,tipKey,icon,enabled)
            import solverprofiler.util.*
            import matlab.ui.internal.toolstrip.*
            constructFunc=str2func(buttonType);
            if(isempty(nameKey))
                button=constructFunc(icon);
            else
                button=constructFunc(sprintf(utilDAGetString(nameKey)),icon);
            end

            button.Tag=tag;
            if~isempty(tipKey)
                button.Description=utilDAGetString(tipKey);
            end
            button.Enabled=enabled;
        end


        function checkbox=createCheckbox(tag,nameKey,tipKey,enabled,Value)
            import solverprofiler.util.*
            import matlab.ui.internal.toolstrip.*

            checkbox=CheckBox(utilDAGetString(nameKey));
            checkbox.Tag=tag;
            checkbox.Enabled=enabled;
            checkbox.Value=Value;
            checkbox.Description=utilDAGetString(tipKey);
        end

    end

end