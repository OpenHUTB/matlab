classdef(Hidden)PwrBusUtilUi<matlab.apps.AppBase




    properties
Blk

    end


    properties

        Fig matlab.ui.Figure
        DscPanel matlab.ui.container.Panel
        ParamPanel matlab.ui.container.Panel
        SignalNamePanel matlab.ui.container.Panel
        SignalSelectPanel matlab.ui.container.Panel
        AssctBlkPanel matlab.ui.container.Panel
        SignalInfoPanel matlab.ui.container.Panel


        SignalTabGroup matlab.ui.container.TabGroup
        MainTab matlab.ui.container.Tab
        TrnsfrdSignalTab matlab.ui.container.Tab
        NotTrnsfrdSignalTab matlab.ui.container.Tab
        StoredSignalTab matlab.ui.container.Tab



        OkButton matlab.ui.control.Button
        CancelButton matlab.ui.control.Button
        HelpButton matlab.ui.control.Button
        ApplyButton matlab.ui.control.Button


        MainGridLayout matlab.ui.container.GridLayout
        MaskButtonGridLayout matlab.ui.container.GridLayout
        AssctBlkGridLayout matlab.ui.container.GridLayout
        RefBlkGridLayout matlab.ui.container.GridLayout


        TrnsfrdSignalTbl matlab.ui.control.Table
        NotTrnsfrdSignalTbl matlab.ui.control.Table
        StoredSignalTbl matlab.ui.control.Table


AssctBlkDropdown
RefBlkEdit


        PwrTrnsfrdCheckBox matlab.ui.control.CheckBox
        PwrNotTrnsfrdCheckBox matlab.ui.control.CheckBox
        PwrStoredCheckBox matlab.ui.control.CheckBox

    end


    properties(Access=private)
TopLevelSignalNames
AllSignalNames
        PwrInfoBusObj autoblks.pwr.PwrInfoBus
    end


    methods

        function app=PwrBusUtilUi(BlkName,PwrInfoBusObj)
            app.Blk=BlkName;
            app.PwrInfoBusObj=PwrInfoBusObj;


            app.Fig=uifigure('visible','off');
            app.Fig.UserData=app;
            app.Fig.Name=get_param(app.Blk,'Name');
            app.Fig.Position(end)=560;


            BlkPos=get_param(app.Blk,'Position');
            ParentBlk=get_param(app.Blk,'Parent');
            ScrollOffset=get_param(ParentBlk,'ScrollbarOffset');
            ParentLoc=get_param(ParentBlk,'Location');
            BlkGlobalPos=BlkPos;
            BlkGlobalPos(1:2)=BlkPos(1:2)-ScrollOffset+ParentLoc(1:2);
            if BlkGlobalPos(1)-app.Fig.Position(3)>25
                app.Fig.Position(1)=BlkGlobalPos(1)-app.Fig.Position(3);
            else
                app.Fig.Position(1)=BlkGlobalPos(1);
            end
            MP=get(0,'MonitorPositions');
            FullScreenSize=[0,0];
            for i=1:size(MP,1)
                FullScreenSize(1)=max(FullScreenSize(1),MP(i,3)+MP(i,1)-1);
                FullScreenSize(2)=max(FullScreenSize(2),MP(i,4)+MP(i,2)-1);
            end
            if BlkGlobalPos(2)-app.Fig.Position(4)>50
                app.Fig.Position(2)=FullScreenSize(2)-BlkGlobalPos(2);
            else
                app.Fig.Position(2)=FullScreenSize(2)-app.Fig.Position(4)-50;
            end


            app.MainGridLayout=uigridlayout(app.Fig,[3,1]);
            app.MainGridLayout.RowHeight={75,'1x',35};
            app.DscPanel=uipanel(app.MainGridLayout,'Title',getString(message('autoblks_shared:autoblkPwrInfoBus:pwrAccTitle')));
            app.ParamPanel=uipanel(app.MainGridLayout,'Title',getString(message('autoblks_shared:autoblkPwrInfoBus:parms')));
            app.MaskButtonGridLayout=uigridlayout(app.MainGridLayout,[1,5]);


            app.SignalTabGroup=uitabgroup(uigridlayout(app.ParamPanel,[1,1],'Padding',[5,5,5,5]));
            app.MainTab=uitab(app.SignalTabGroup,'Title',getString(message('autoblks_shared:autoblkPwrInfoBus:blkOpt')));
            app.TrnsfrdSignalTab=uitab(app.SignalTabGroup,'Title',getString(message('autoblks_shared:autoblkPwrInfoBus:descTrans')));
            app.NotTrnsfrdSignalTab=uitab(app.SignalTabGroup,'Title',getString(message('autoblks_shared:autoblkPwrInfoBus:descNotTrans')));
            app.StoredSignalTab=uitab(app.SignalTabGroup,'Title',getString(message('autoblks_shared:autoblkPwrInfoBus:descStored')));


            app.MaskButtonGridLayout.Padding=[5,5,5,5];
            app.MaskButtonGridLayout.ColumnWidth={'1x',70,70,70,70};
            uigridlayout(app.MaskButtonGridLayout);
            app.OkButton=uibutton(app.MaskButtonGridLayout,'Text',getString(message('autoblks_shared:autoblkPwrInfoBus:okButton')),'ButtonPushedFcn',app.createCallbackFcn(@OkButtonPushed,true));
            app.CancelButton=uibutton(app.MaskButtonGridLayout,'Text',getString(message('autoblks_shared:autoblkPwrInfoBus:cancelButton')),'ButtonPushedFcn',app.createCallbackFcn(@CancelButtonPushed,true));
            app.HelpButton=uibutton(app.MaskButtonGridLayout,'Text',getString(message('autoblks_shared:autoblkPwrInfoBus:helpButton')),'ButtonPushedFcn',app.createCallbackFcn(@HelpButtonPushed,true));
            app.ApplyButton=uibutton(app.MaskButtonGridLayout,'Text',getString(message('autoblks_shared:autoblkPwrInfoBus:applyButton')),'ButtonPushedFcn',app.createCallbackFcn(@ApplyButtonPushed,true));


            BlkOptionLayout=uigridlayout(app.MainTab,[2,1],'Padding',[5,5,5,5]);


            AssctBlkPanel=uipanel(BlkOptionLayout,'Title',getString(message('autoblks_shared:autoblkPwrInfoBus:assocBlk')));

            AssctBlkPanelGridLayout=uigridlayout(AssctBlkPanel,[3,1]);
            AssctBlkPanelGridLayout.Padding=[5,5,5,5];
            AssctBlkPanelGridLayout.RowHeight={22,22,'1x'};
            app.AssctBlkGridLayout=uigridlayout(AssctBlkPanelGridLayout,[1,2],'Padding',[0,0,0,0],'ColumnWidth',{100,'1x'});
            app.RefBlkGridLayout=uigridlayout(AssctBlkPanelGridLayout,[1,2],'Padding',[0,0,0,0],'ColumnWidth',{120,'1x'});

            uilabel(app.AssctBlkGridLayout,'Text',getString(message('autoblks_shared:autoblkPwrInfoBus:assocLabel')));
            app.AssctBlkDropdown=uidropdown(app.AssctBlkGridLayout,'ValueChangedFcn',app.createCallbackFcn(@AssctBlkDropdownChange,true));
            uilabel(app.RefBlkGridLayout,'Text',getString(message('autoblks_shared:autoblkPwrInfoBus:blkName')));
            app.RefBlkEdit=uieditfield(app.RefBlkGridLayout);


            DscLabel=uitextarea(uigridlayout(app.DscPanel,[1,1],'Padding',[0,0,0,0]),'Editable',false,'BackgroundColor',app.DscPanel.BackgroundColor);

            DscLabel.Value=getString(message('autoblks_shared:autoblkPwrInfoBus:descText'));


            PwrTypePanel=uipanel(BlkOptionLayout,'Title',getString(message('autoblks_shared:autoblkPwrInfoBus:pwrInp')));
            SignalTypeLayout=uigridlayout(PwrTypePanel,[4,1]);
            SignalTypeLayout.RowHeight={22,22,22,'1x'};
            app.PwrTrnsfrdCheckBox=uicheckbox(SignalTypeLayout,'Text',getString(message('autoblks_shared:autoblkPwrInfoBus:pwrTrans')),'ValueChangedFcn',app.createCallbackFcn(@checkboxChangedFcn,true));
            app.PwrNotTrnsfrdCheckBox=uicheckbox(SignalTypeLayout,'Text',getString(message('autoblks_shared:autoblkPwrInfoBus:pwrNotTrans')),'ValueChangedFcn',app.createCallbackFcn(@checkboxChangedFcn,true));
            app.PwrStoredCheckBox=uicheckbox(SignalTypeLayout,'Text',getString(message('autoblks_shared:autoblkPwrInfoBus:pwrStored')),'ValueChangedFcn',app.createCallbackFcn(@checkboxChangedFcn,true));



            app.TrnsfrdSignalTbl=uitable(uigridlayout(app.TrnsfrdSignalTab,[1,1],'Padding',[5,5,5,5]));
            app.NotTrnsfrdSignalTbl=uitable(uigridlayout(app.NotTrnsfrdSignalTab,[1,1],'Padding',[5,5,5,5]));
            app.StoredSignalTbl=uitable(uigridlayout(app.StoredSignalTab,[1,1],'Padding',[5,5,5,5]));


            app.ReadMaskParams;


            valueIndex=cellfun(@(x)strcmp(x,app.AssctBlkDropdown.Value),app.AssctBlkDropdown.Items);


            app.AssctBlkDropdown.Items={getString(message('autoblks_shared:autoblkPwrInfoBus:parBlk'));...
            getString(message('autoblks_shared:autoblkPwrInfoBus:refBlk'))};
            app.AssctBlkDropdown.Value=app.AssctBlkDropdown.Items{valueIndex};


            app.PwrInfoBusObj.GetInputSignals;
            app.loadSignalTbls;
            app.checkboxChangedFcn(0);


            app.Fig.Visible='on';
        end


        function ReadMaskParams(app)
            MaskObj=get_param(app.Blk,'MaskObject');
            AssctBlkParam=MaskObj.getParameter('AssctBlkSelPopup');
            RefBlkNameParam=MaskObj.getParameter('RefBlkName');

            app.AssctBlkDropdown.Items=AssctBlkParam.TypeOptions;
            app.AssctBlkDropdown.Value=AssctBlkParam.Value;
            app.AssctBlkDropdownChange(struct('Value',app.AssctBlkDropdown.Value));
            app.RefBlkEdit.Value=RefBlkNameParam.Value;
            app.PwrTrnsfrdCheckBox.Value=strcmp(get_param(app.Blk,'PwrTrnsfrdCheckBox'),'on');
            app.PwrNotTrnsfrdCheckBox.Value=strcmp(get_param(app.Blk,'PwrNotTrnsfrdCheckBox'),'on');
            app.PwrStoredCheckBox.Value=strcmp(get_param(app.Blk,'PwrStoredCheckBox'),'on');
        end


        function SaveMaskParams(app)
            MaskObj=get_param(app.Blk,'MaskObject');
            AssctBlkParam=MaskObj.getParameter('AssctBlkSelPopup');
            RefBlkNameParam=MaskObj.getParameter('RefBlkName');
            valueIndex=cellfun(@(x)strcmp(x,app.AssctBlkDropdown.Value),app.AssctBlkDropdown.Items);
            AssctBlkParam.Value=AssctBlkParam.TypeOptions{valueIndex};
            RefBlkNameParam.Value=app.RefBlkEdit.Value;

            app.SetCheckBox('PwrTrnsfrdCheckBox',app.PwrTrnsfrdCheckBox)
            app.SetCheckBox('PwrNotTrnsfrdCheckBox',app.PwrNotTrnsfrdCheckBox)
            app.SetCheckBox('PwrStoredCheckBox',app.PwrStoredCheckBox)


            TblData=app.TrnsfrdSignalTbl.Data;
            if~isempty(TblData)
                app.PwrInfoBusObj.PwrTrnsfrdSignal.saveSignalInfo(TblData(:,1),TblData(:,3),TblData(:,2));
            end

            TblData=app.NotTrnsfrdSignalTbl.Data;
            if~isempty(TblData)
                app.PwrInfoBusObj.PwrNotTrnsfrdSignal.saveSignalInfo(TblData(:,1),TblData(:,2));
            end

            TblData=app.StoredSignalTbl.Data;
            if~isempty(TblData)
                app.PwrInfoBusObj.PwrStoredSignal.saveSignalInfo(TblData(:,1),TblData(:,2));
            end


            app.PwrInfoBusObj.GetInputSignals;
            app.loadSignalTbls;
        end
    end



    methods(Access=private)

        function SetCheckBox(app,ParamName,CheckBox)
            if CheckBox.Value
                set_param(app.Blk,ParamName,'on')
            else
                set_param(app.Blk,ParamName,'off')
            end
        end

        function loadSignalTbls(app)


            SignalSummary=app.PwrInfoBusObj.getTrnsfrdSignalSummary;
            app.updateSignalTbl(SignalSummary,app.TrnsfrdSignalTbl)


            app.updateSignalTbl(app.PwrInfoBusObj.PwrNotTrnsfrdSignal.getSignalSummary,app.NotTrnsfrdSignalTbl)


            app.updateSignalTbl(app.PwrInfoBusObj.PwrStoredSignal.getSignalSummary,app.StoredSignalTbl)

        end


        function updateSignalTbl(app,SignalSummary,TblObj)

            [~,IA]=setxor({SignalSummary.FullName},{'PwrTrnsfrd','PwrNotTrnsfrd','PwrStored'});
            SignalSummary=SignalSummary(IA);

            if isfield(SignalSummary,'AssctPort')
                TblData=[{SignalSummary.FullName}',{SignalSummary.AssctPort}',{SignalSummary.Description}'];
                TblObj.ColumnName={getString(message('autoblks_shared:autoblkPwrInfoBus:sigName')),...
                getString(message('autoblks_shared:autoblkPwrInfoBus:assocPort')),...
                getString(message('autoblks_shared:autoblkPwrInfoBus:descr'))};
                TblObj.ColumnEditable=[false,true,true];
                TblObj.Data=TblData;
                TblObj.ColumnFormat={'char','char','char'};
            else
                TblData=[{SignalSummary.FullName}',{SignalSummary.Description}'];
                TblObj.ColumnName={getString(message('autoblks_shared:autoblkPwrInfoBus:sigName')),...
                getString(message('autoblks_shared:autoblkPwrInfoBus:descr'))};
                TblObj.ColumnEditable=[false,true,true];
                TblObj.Data=TblData;
                TblObj.ColumnFormat={'char','char'};
            end
        end
    end


    methods(Access=private)

        function OkButtonPushed(app,event)
            ErrReached=app.runInit;
            if~ErrReached
                delete(app.Fig);
            end
        end

        function ApplyButtonPushed(app,event)
            app.runInit;
        end

        function CancelButtonPushed(app,event)
            delete(app.Fig);
        end

        function HelpButtonPushed(app,event)
            eval(get_param(app.Blk,'MaskHelp'));
        end

        function AssctBlkDropdownChange(app,event)
            if strcmp(event.Value,'Parent reference block')
                app.RefBlkGridLayout.Children(1).Visible='on';
                app.RefBlkGridLayout.Children(2).Visible='on';
            else
                app.RefBlkGridLayout.Children(1).Visible='off';
                app.RefBlkGridLayout.Children(2).Visible='off';
            end
        end


        function ErrReached=runInit(app)


            ErrReached=false;
            TblData=app.TrnsfrdSignalTbl.Data;
            if~isempty(TblData)
                for i=1:size(TblData,1)
                    if~isempty(strfind(TblData{i,2},''''))||~isempty(strfind(TblData{i,2},'{'))||~isempty(strfind(TblData{i,2},'}'))
                        try
                            AssctPortNames=eval(TblData{i,2});
                            if iscell(AssctPortNames)
                                for j=1:length(AssctPortNames)
                                    if~iscellstr(AssctPortNames{j})&&~ischar(AssctPortNames{j})&&~isstring(AssctPortNames{j})
                                        ErrReached=true;
                                    end
                                end
                            else
                                if~ischar(AssctPortNames)&&~isstring(AssctPortNames)
                                    ErrReached=true;
                                end
                            end

                        catch
                            ErrReached=true;
                        end

                        if ErrReached
                            ErrMsg=message('autoblks_shared:autoerrPwrInfoBus:cannotEvaluateAssctPort',TblData{i,2},TblData{i,1});
                            errordlg(ErrMsg.getString);
                            break;
                        end
                    end
                end
            end


            if~ErrReached
                app.SaveMaskParams;
            end
        end


        function checkboxChangedFcn(app,event)
            TabList=app.MainTab;
            if app.PwrTrnsfrdCheckBox.Value
                TabList=[TabList,app.TrnsfrdSignalTab];
                app.TrnsfrdSignalTab.Parent=app.SignalTabGroup;
            else
                app.TrnsfrdSignalTab.Parent=[];
            end

            if app.PwrNotTrnsfrdCheckBox.Value
                TabList=[TabList,app.NotTrnsfrdSignalTab];
                app.NotTrnsfrdSignalTab.Parent=app.SignalTabGroup;
            else
                app.NotTrnsfrdSignalTab.Parent=[];
            end

            if app.PwrStoredCheckBox.Value
                TabList=[TabList,app.StoredSignalTab];
                app.StoredSignalTab.Parent=app.SignalTabGroup;
            else
                app.StoredSignalTab.Parent=[];
            end

            app.SignalTabGroup.Children=TabList;
        end

    end
end
