classdef RptgenPreferencePanel<handle












    properties(Access=public)

UIFigure
    end

    properties(Access=private)

        FormatIdDropDown(1,1)matlab.ui.control.DropDown


        ExtensionEditField(1,1)matlab.ui.control.EditField


        SLImagesDropDown(1,1)matlab.ui.control.DropDown


        SFImagesDropDown(1,1)matlab.ui.control.DropDown


        MLImagesDropDown(1,1)matlab.ui.control.DropDown


        VisibleInRECheckBox(1,1)matlab.ui.control.CheckBox


        ViewCommandDropDown(1,1)matlab.ui.control.DropDown


        ResetButton(1,1)matlab.ui.control.Button



        AnimateRECheckBox(1,1)matlab.ui.control.CheckBox


        EditHTMLCommandEditField(1,1)matlab.ui.control.EditField


CurrentFormat
    end

    properties(Access=private,Constant)


        VIEW_KEY="%<FileName>";
        VIEW_CMD_TXT="edit('%<FileName>');";
        VIEW_CMD_WEB="web(rptgen.file2urn('%<FileName>'));";
        VIEW_CMD_DOC="docview('%<FileName>','UpdateFields');";
        VIEW_CMD_SYS="! '%<FileName>' &";
        VIEW_CMD_OPEN="open('%<FileName>');";
        VIEW_CMD_PDF="pdfmanage('open', '%<FileName>');";
        VIEW_CMD_DVI="xdvi '%<FileName>' &";
        VIEW_DEPLOYED="disp('%<FileName> cannot be viewed in a compiled application. Please use an external application to open.')";


        EDIT_HTML_CMD_PLACEHOLDER="%<FileName>";
        EDIT_HTML_CMD_TXT="edit('%<FileName>');";


        VIEW_CMD_SETTING="viewcmd";
        RUNTIME_ANIMATE_SETTING="runtimeanimate";
        EDIT_HTML_CMD_SETTING="edithtmlcmd";
    end

    methods(Access=public)

        function this=RptgenPreferencePanel()




            this.UIFigure=uifigure;





            panelGrid=uigridlayout(this.UIFigure);
            panelGrid.RowHeight={'fit','fit'};
            panelGrid.ColumnWidth={'fit'};


            buildPanelSections(this,panelGrid);
        end

        function result=commit(this)



            import matlab.ui.internal.preferences.preferencePanels.RptgenPreferencePanel
            try
                commitPreferencePanelSection(this,true);
                result=true;
            catch
                result=false;
            end
        end

        function delete(this)


            delete(this.UIFigure);
        end
    end

    methods(Access=private)

        function buildPanelSections(this,panelGrid)



            buildOutputPreferencesPanelSection(this,panelGrid);


            buildOtherPreferencesPanelSection(this,panelGrid);
        end

        function buildOutputPreferencesPanelSection(this,panelGrid)

            import rptgen.internal.output.OutputFormat
            import rptgen.internal.output.ImageFormat


            this.CurrentFormat=OutputFormat.getFormat("html");





            outputPreferencesGrid=uigridlayout(panelGrid);
            outputPreferencesGrid.RowHeight={'fit','fit','fit','fit','fit','fit','fit','fit','fit'};
            outputPreferencesGrid.ColumnWidth={'fit','fit'};


            header1=uilabel(outputPreferencesGrid);
            header1.Text=getPrefLabelForDisplay("OutputPreferences");
            header1.FontWeight="bold";
            header1.Layout.Column=[1,2];


            formatIdLabel=uilabel(outputPreferencesGrid);
            formatIdLabel.Text=getPrefLabelForDisplay("FormatID");
            formatIdLabel.Layout.Row=2;
            formatIdLabel.Layout.Column=1;

            this.FormatIdDropDown=uidropdown(outputPreferencesGrid);
            this.FormatIdDropDown.Items=OutputFormat.listAllDescriptions;
            this.FormatIdDropDown.ItemsData=OutputFormat.listAllIDs;
            this.FormatIdDropDown.Layout.Row=2;
            this.FormatIdDropDown.Layout.Column=2;
            this.FormatIdDropDown.ValueChangedFcn=@(dd,event)this.formatSelectedCallBack(dd);


            extensionLabel=uilabel(outputPreferencesGrid);
            extensionLabel.Text=getPrefLabelForDisplay("Extension");
            extensionLabel.Layout.Row=3;
            extensionLabel.Layout.Column=1;

            this.ExtensionEditField=uieditfield(outputPreferencesGrid);
            this.ExtensionEditField.Layout.Row=3;
            this.ExtensionEditField.Layout.Column=2;
            this.ExtensionEditField.ValueChangedFcn=@(txt,event)this.extensionChangedCallBack(txt);


            SLImagesLabel=uilabel(outputPreferencesGrid);
            SLImagesLabel.Text=getPrefLabelForDisplay("ImageFormatSL");
            SLImagesLabel.Layout.Row=4;
            SLImagesLabel.Layout.Column=1;

            this.SLImagesDropDown=uidropdown(outputPreferencesGrid);
            allSLFormats=ImageFormat.getAllFormatsSL;
            this.SLImagesDropDown.Items=cellfun(@(format)char(format.Name),allSLFormats,'UniformOutput',false);
            this.SLImagesDropDown.ItemsData=cellfun(@(format)char(format.ID),allSLFormats,'UniformOutput',false);
            this.SLImagesDropDown.Layout.Row=4;
            this.SLImagesDropDown.Layout.Column=2;
            this.SLImagesDropDown.ValueChangedFcn=@(dd,event)this.imageSLSelectedCallBack(dd);


            SFImagesLabel=uilabel(outputPreferencesGrid);
            SFImagesLabel.Text=getPrefLabelForDisplay("ImageFormatSF");
            SFImagesLabel.Layout.Row=5;
            SFImagesLabel.Layout.Column=1;

            this.SFImagesDropDown=uidropdown(outputPreferencesGrid);
            allSFFormats=ImageFormat.getAllFormatsSF;
            this.SFImagesDropDown.Items=cellfun(@(format)char(format.Name),allSFFormats,'UniformOutput',false);
            this.SFImagesDropDown.ItemsData=cellfun(@(format)char(format.ID),allSFFormats,'UniformOutput',false);
            this.SFImagesDropDown.Layout.Row=5;
            this.SFImagesDropDown.Layout.Column=2;
            this.SFImagesDropDown.ValueChangedFcn=@(dd,event)this.imageSFSelectedCallBack(dd);


            HGImagesLabel=uilabel(outputPreferencesGrid);
            HGImagesLabel.Text=getPrefLabelForDisplay("ImageFormatML");
            HGImagesLabel.Layout.Row=6;
            HGImagesLabel.Layout.Column=1;

            this.MLImagesDropDown=uidropdown(outputPreferencesGrid);
            allHGFormats=ImageFormat.getAllFormatsHG;
            this.MLImagesDropDown.Items=cellfun(@(format)char(format.Name),allHGFormats,'UniformOutput',false);
            this.MLImagesDropDown.ItemsData=cellfun(@(format)char(format.ID),allHGFormats,'UniformOutput',false);
            this.MLImagesDropDown.Layout.Row=6;
            this.MLImagesDropDown.Layout.Column=2;
            this.MLImagesDropDown.ValueChangedFcn=@(dd,event)this.imageHGSelectedCallBack(dd);


            this.VisibleInRECheckBox=uicheckbox(outputPreferencesGrid);
            this.VisibleInRECheckBox.Text=getPrefLabelForDisplay("VisibleInRE");
            this.VisibleInRECheckBox.Layout.Column=2;
            this.VisibleInRECheckBox.ValueChangedFcn=@(cbx,event)this.visibleChangedCallBack(cbx);


            viewCommandLabel=uilabel(outputPreferencesGrid);
            viewCommandLabel.Text=getPrefLabelForDisplay("ViewCommand");
            viewCommandLabel.Layout.Row=8;
            viewCommandLabel.Layout.Column=1;

            this.ViewCommandDropDown=uidropdown(outputPreferencesGrid);
            this.ViewCommandDropDown.Items=[...
            this.VIEW_CMD_TXT,this.VIEW_CMD_WEB,this.VIEW_CMD_DOC,this.VIEW_CMD_SYS,...
            this.VIEW_CMD_OPEN,this.VIEW_CMD_PDF,this.VIEW_CMD_DVI];
            this.ViewCommandDropDown.Editable="on";
            this.ViewCommandDropDown.Layout.Row=8;
            this.ViewCommandDropDown.Layout.Column=2;
            this.ViewCommandDropDown.ValueChangedFcn=@(dd,event)this.viewCommandSelectedCallBack(dd);


            this.ResetButton=uibutton(outputPreferencesGrid);
            this.ResetButton.Text=getPrefLabelForDisplay("Reset");
            this.ResetButton.Layout.Row=9;
            this.ResetButton.Layout.Column=2;
            this.ResetButton.ButtonPushedFcn=@(btn,event)this.resetButtonPushedCallBack(btn);



            initializeOutputPreferencesPanelSection(this);
        end

        function buildOtherPreferencesPanelSection(this,panelGrid)





            otherPreferencesGrid=uigridlayout(panelGrid);
            otherPreferencesGrid.RowHeight={'fit','fit','fit'};
            otherPreferencesGrid.ColumnWidth={'fit','fit'};


            header2=uilabel(otherPreferencesGrid);
            header2.Text=getPrefLabelForDisplay("OtherPreferences");
            header2.FontWeight="bold";
            header2.Layout.Column=[1,2];


            this.AnimateRECheckBox=uicheckbox(otherPreferencesGrid);
            this.AnimateRECheckBox.Text=getPrefLabelForDisplay("RuntimeAnimate");
            this.AnimateRECheckBox.Layout.Column=2;


            editHTMLCommandLabel=uilabel(otherPreferencesGrid);
            editHTMLCommandLabel.Text=getPrefLabelForDisplay("EditHTMLCommand");
            editHTMLCommandLabel.Layout.Row=3;
            editHTMLCommandLabel.Layout.Column=1;

            this.EditHTMLCommandEditField=uieditfield(otherPreferencesGrid);
            this.EditHTMLCommandEditField.Layout.Row=3;
            this.EditHTMLCommandEditField.Layout.Column=2;



            initializeOtherPreferencesPanelSection(this);
        end

        function initializeOutputPreferencesPanelSection(this)


            if~isempty(this.CurrentFormat)
                this.FormatIdDropDown.Value=this.CurrentFormat.ID;
                this.ExtensionEditField.Value=this.CurrentFormat.getExtension();
                this.SLImagesDropDown.Value=this.CurrentFormat.getImageFormatSL().ID;
                this.SFImagesDropDown.Value=this.CurrentFormat.getImageFormatSF().ID;
                this.MLImagesDropDown.Value=this.CurrentFormat.getImageFormatHG().ID;
                this.VisibleInRECheckBox.Value=this.CurrentFormat.getVisible();
                this.ViewCommandDropDown.Value=this.CurrentFormat.getViewCommand();
            end
        end

        function initializeOtherPreferencesPanelSection(this)

            import matlab.ui.internal.preferences.preferencePanels.RptgenPreferencePanel

            this.AnimateRECheckBox.Value=RptgenPreferencePanel.getRuntimeAnimate();

            srptgen=RptgenPreferencePanel.getRptgenSettings();
            this.EditHTMLCommandEditField.Value=srptgen.(RptgenPreferencePanel.EDIT_HTML_CMD_SETTING).ActiveValue;
        end

        function commitPreferencePanelSection(this,shouldCommit)


            import matlab.ui.internal.preferences.preferencePanels.RptgenPreferencePanel

            if shouldCommit
                RptgenPreferencePanel.setRuntimeAnimate(this.AnimateRECheckBox.Value);
                RptgenPreferencePanel.setEditHTMLCommand(this.EditHTMLCommandEditField.Value);
            else
                initializeOtherPreferencesPanelSection(this);
            end
        end

        function formatSelectedCallBack(this,dd)


            import rptgen.internal.output.OutputFormat
            this.CurrentFormat=OutputFormat.getFormat(dd.Value);



            initializeOutputPreferencesPanelSection(this);
        end

        function extensionChangedCallBack(this,txt)


            this.CurrentFormat.setExtension(txt.Value);



            this.CurrentFormat.setViewCommand(this.ViewCommandDropDown.Value);
        end

        function imageSLSelectedCallBack(this,dd)


            import rptgen.internal.output.ImageFormat
            this.CurrentFormat.setImageFormatSL(ImageFormat.getFormat(dd.Value));
        end

        function imageSFSelectedCallBack(this,dd)


            import rptgen.internal.output.ImageFormat
            this.CurrentFormat.setImageFormatSF(ImageFormat.getFormat(dd.Value));
        end

        function imageHGSelectedCallBack(this,dd)


            import rptgen.internal.output.ImageFormat
            this.CurrentFormat.setImageFormatHG(ImageFormat.getFormat(dd.Value));
        end

        function visibleChangedCallBack(this,cbx)


            this.CurrentFormat.setVisible(cbx.Value);
        end

        function viewCommandSelectedCallBack(this,dd)


            this.CurrentFormat.setViewCommand(dd.Value);
        end

        function resetButtonPushedCallBack(this,btn)%#ok<INUSD>


            this.CurrentFormat.resetToDefaults();
            initializeOutputPreferencesPanelSection(this);
        end

    end

    methods(Static,Access=public)

        function vc=getViewCommand(ext)

            import matlab.ui.internal.preferences.preferencePanels.RptgenPreferencePanel



            if isdeployed
                vc=RptgenPreferencePanel.VIEW_DEPLOYED;
            else
                if isempty(ext)||string(ext)==""
                    vc=RptgenPreferencePanel.VIEW_CMD_TXT;
                else
                    ext=lower(ext);


                    s=RptgenPreferencePanel.getRptgenSettings();
                    vc=s.(RptgenPreferencePanel.VIEW_CMD_SETTING).(ext).ActiveValue;

                    if isempty(vc)||string(vc)==""
                        switch string(ext)
                        case{"xml","sgml","txt","m","fo","tex","latex"}
                            vc=RptgenPreferencePanel.VIEW_CMD_TXT;
                        case{"rtf","doc","docx"}
                            vc=RptgenPreferencePanel.VIEW_CMD_DOC;
                        case{"htm","html","htmt"}
                            vc=RptgenPreferencePanel.VIEW_CMD_WEB;
                        case "pdf"
                            vc=RptgenPreferencePanel.VIEW_CMD_PDF;
                        case{"mif","ps"}
                            vc=RptgenPreferencePanel.VIEW_CMD_SYS;
                        case "dvi"
                            vc=RptgenPreferencePanel.VIEW_CMD_DVI;
                        otherwise
                            vc=RptgenPreferencePanel.VIEW_CMD_OPEN;
                        end
                    end
                end
            end
        end

        function vc=getViewCommandByFile(fileName)

            import matlab.ui.internal.preferences.preferencePanels.RptgenPreferencePanel



            [~,~,ext]=fileparts(fileName);
            ext=strrep(ext,".","");
            viewCmd=RptgenPreferencePanel.getViewCommand(ext);


            fileName=strrep(fileName,"'","''");
            vc=strrep(viewCmd,RptgenPreferencePanel.VIEW_KEY,fileName);
        end

        function setViewCommand(ext,viewCmd)






            import matlab.ui.internal.preferences.preferencePanels.RptgenPreferencePanel

            s=RptgenPreferencePanel.getRptgenSettings();
            s.(RptgenPreferencePanel.VIEW_CMD_SETTING).(lower(ext)).PersonalValue=viewCmd;
        end

        function runtimeAnimate=getRuntimeAnimate()



            import matlab.ui.internal.preferences.preferencePanels.RptgenPreferencePanel

            srptgen=RptgenPreferencePanel.getRptgenSettings();
            runtimeAnimate=srptgen.(RptgenPreferencePanel.RUNTIME_ANIMATE_SETTING).ActiveValue;
        end

        function setRuntimeAnimate(newRuntimeAnimate)





            import matlab.ui.internal.preferences.preferencePanels.RptgenPreferencePanel

            srptgen=RptgenPreferencePanel.getRptgenSettings();
            srptgen.(RptgenPreferencePanel.RUNTIME_ANIMATE_SETTING).PersonalValue=newRuntimeAnimate;
        end

        function setEditHTMLCommand(newCommand)


            import matlab.ui.internal.preferences.preferencePanels.RptgenPreferencePanel

            srptgen=RptgenPreferencePanel.getRptgenSettings();
            srptgen.(RptgenPreferencePanel.EDIT_HTML_CMD_SETTING).PersonalValue=newCommand;
        end

        function editHTMLCommand=getEditHTMLCommand(fileName)


            import matlab.ui.internal.preferences.preferencePanels.RptgenPreferencePanel

            srptgen=RptgenPreferencePanel.getRptgenSettings();
            editHTMLCommand=srptgen.(RptgenPreferencePanel.EDIT_HTML_CMD_SETTING).ActiveValue;

            if~isempty(editHTMLCommand)&&editHTMLCommand~=""


                editHTMLCommand=strrep(editHTMLCommand,RptgenPreferencePanel.EDIT_HTML_CMD_PLACEHOLDER,fileName);
            end
        end

        function helpPage=getHelpInfo()






            helpPage={...
            com.mathworks.mlservices.MLHelpServices.getMapfileName("rptgen","rptgen"),...
"report_generator_pref_help"...
            };
        end

        function showPrefsDialog()




        end

    end

    methods(Static,Access=private)

        function srptgen=getRptgenSettings()

            import matlab.ui.internal.preferences.preferencePanels.RptgenPreferencePanel


            s=settings;


            if~s.hasGroup("rptgen")
                s.addGroup("rptgen");
            end


            srptgen=s.rptgen;


            if~srptgen.hasGroup(RptgenPreferencePanel.VIEW_CMD_SETTING)
                sviewcmd=srptgen.addGroup(RptgenPreferencePanel.VIEW_CMD_SETTING);
                for extn=["xml","sgml","txt","m","fo","tex","latex","rtf","doc","docx","htm","html","htmt","pdf","mif","ps","dvi"]
                    extnSetting=sviewcmd.addSetting(extn);
                    extnSetting.PersonalValue="";
                end
            end


            if~srptgen.hasSetting(RptgenPreferencePanel.RUNTIME_ANIMATE_SETTING)
                runtimeSetting=srptgen.addSetting(RptgenPreferencePanel.RUNTIME_ANIMATE_SETTING);
                runtimeSetting.PersonalValue=true;
            end


            if~srptgen.hasSetting(RptgenPreferencePanel.EDIT_HTML_CMD_SETTING)
                editHTMLCmdSetting=srptgen.addSetting(RptgenPreferencePanel.EDIT_HTML_CMD_SETTING);
                editHTMLCmdSetting.PersonalValue=RptgenPreferencePanel.EDIT_HTML_CMD_TXT;
            end
        end
    end

end

function prefLabel=getPrefLabelForDisplay(key)


    prefLabel=getString(message...
    (sprintf('rptgen:RptgenPreferencePanel:%s',key)));
end
