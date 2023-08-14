classdef RichTextComparisonDialog<handle

    properties(Access=private)
        dlghandle;
        propertyName='description';
        leftHTML='';
        rightHTML='';
        leftFile='';
        rightFile='';
        leftFileFull='';
        rightFileFull='';
        isRevisionComparison=false;
        token;
    end
    properties(Constant,Hidden)
        PANEL_TAG='ComparisonPanel_';
        RTC_DIALOG_TAG='RichTextComparisonDialog';
        SIDE_LEFT='left';
        SIDE_RIGHT='right';
        SIDE_DISPLAY_STRING_NO_REVISION=struct(...
        'left',getString(message('Slvnv:slreq:RichTextCompDialogLeftLabelNoRevision')),...
        'right',getString(message('Slvnv:slreq:RichTextCompDialogRightLabelNoRevision')));
        SIDE_DISPLAY_STRING_REVISION=struct(...
        'left',getString(message('Slvnv:slreq:RichTextCompDialogLeftLabelRevision')),...
        'right',getString(message('Slvnv:slreq:RichTextCompDialogRightLabelRevision')));
        SIDE_INDICATOR_TAG_PREFIX='sideIndicator_';
        FILENAME_LABEL_TAG_PREFIX='fileNameLabel_';
        COMPARISON_PROPERTY_TAG_PREFIX='comparisonProperty_';
        RICHTEXT_DISPLAY_TAG_PREFIX='richTextDisplay_';

    end

    methods
        function this=RichTextComparisonDialog()
        end

        function showComparisonWindow(this,property,leftFile,leftHTML,rightFile,rightHTML,isRevisionComparison,token)
            this.setProperty(property);
            this.setHTML(leftHTML,rightHTML);
            this.setFilenames(leftFile,rightFile);
            this.isRevisionComparison=isRevisionComparison;
            this.token=token;
            if isempty(this.dlghandle)
                this.dlghandle=DAStudio.Dialog(this);
            else
                this.dlghandle.refresh();
            end
            this.dlghandle.show();
        end

        function isSameRTC=isRTCDialogFor(this,token)


            isSameRTC=strcmp(this.token,token);
        end

        function dialogStruct=getDialogSchema(this)

            leftPanel=this.makeComparisonPanel(this.SIDE_LEFT);
            rightPanel=this.makeComparisonPanel(this.SIDE_RIGHT);
            leftPanel.ColSpan=[1,1];
            leftPanel.RowSpan=[1,1];
            rightPanel.ColSpan=[2,2];
            rightPanel.RowSpan=[1,1];
            dialogStruct=struct('DialogTitle',this.makeDialogTitle()...
            ,'DialogTag',this.RTC_DIALOG_TAG...
            ,'LayoutGrid',[1,2]...
            ,'DialogStyle','normal');

            dialogStruct.EmbeddedButtonSet={''};
            dialogStruct.StandaloneButtonSet={''};
            dialogStruct.Items={leftPanel,rightPanel};
            dialogStruct.CloseCallback='slreq.internal.comparisons.RichTextComparisonDialog.onClose';
            dialogStruct.CloseArgs={'%dialog','%closeaction'};
        end

    end

    methods(Static)
        function onClose(dialog,~)
            src=dialog.getSource();
            src.dlghandle=[];
        end

        function buildComparisonWindow(property,leftFile,leftHTML,rightFile,rightHTML,isRevisionComparison,token)
            existingRichTextDialog=slreq.internal.comparisons.RichTextComparisonDialog.findExistingComparisonWindows(token);
            if isempty(existingRichTextDialog)
                rtcd=slreq.internal.comparisons.RichTextComparisonDialog();
            else
                rtcd=existingRichTextDialog.getDialogSource();
            end
            rtcd.showComparisonWindow(property,leftFile,leftHTML,rightFile,rightHTML,isRevisionComparison,token);
        end

        function dlg=findExistingComparisonWindows(token)


            dlg=[];
            allRTCDlgs=DAStudio.ToolRoot.getOpenDialogs.find('DialogTag',...
            slreq.internal.comparisons.RichTextComparisonDialog.RTC_DIALOG_TAG);

            for i=1:length(allRTCDlgs)
                if matchExistingDialog(allRTCDlgs(i))
                    dlg=allRTCDlgs(i);
                    return;
                end
            end

            function tf=matchExistingDialog(d)
                dialogSource=d.getDialogSource;
                tf=dialogSource.isRTCDialogFor(token);
            end
        end


    end

    methods(Access=private)

        function setProperty(this,property)
            this.propertyName=property;
        end

        function setHTML(this,left,right)
            this.leftHTML=left;
            this.rightHTML=right;
        end

        function setFilenames(this,left,right)
            [~,pLeftFile,pLeftExt]=fileparts(left);
            [~,pRightFile,pRightExt]=fileparts(right);
            this.leftFile=[pLeftFile,pLeftExt];
            this.rightFile=[pRightFile,pRightExt];
            this.leftFileFull=left;
            this.rightFileFull=right;
        end

        function out=makeDialogTitle(this)
            out=getString(message('Slvnv:slreq:RichTextCompDialogTitleFormat',this.leftFile,this.rightFile));
        end

        function panelStruct=makeComparisonPanel(this,side)

            sideIndicator.Type='text';
            sideIndicator.Tag=[this.SIDE_INDICATOR_TAG_PREFIX,side];
            sideIndicator.RowSpan=[1,1];
            sideIndicator.ColSpan=[1,1];
            sideIndicator.Bold=true;

            fileNameLabel.Type='text';
            fileNameLabel.Tag=[this.FILENAME_LABEL_TAG_PREFIX,side];
            fileNameLabel.RowSpan=[1,1];
            fileNameLabel.ColSpan=[2,2];


            comparisonProperty.Type='text';
            comparisonProperty.Tag=[this.COMPARISON_PROPERTY_TAG_PREFIX,side];
            comparisonProperty.RowSpan=[3,3];
            comparisonProperty.ColSpan=[1,1];
            comparisonProperty.Name=[this.propertyName,':'];

            richtextDisplay.Type='webbrowser';
            richtextDisplay.Tag=[this.RICHTEXT_DISPLAY_TAG_PREFIX,side];
            richtextDisplay.WebKit=false;
            richtextDisplay.RowSpan=[4,4];
            richtextDisplay.ColSpan=[1,1];
            richtextDisplay.FontPointSize=8;
            richtextDisplay.MinimumSize=[500,300];

            if this.isRevisionComparison
                sideIndicatorStruct=this.SIDE_DISPLAY_STRING_REVISION;
            else
                sideIndicatorStruct=this.SIDE_DISPLAY_STRING_NO_REVISION;
            end

            if strcmp(side,this.SIDE_LEFT)
                richtextDisplay.HTML=this.leftHTML;
                sideIndicator.Name=[upper(sideIndicatorStruct.(this.SIDE_LEFT)),': '];
                fileNameLabel.Name=this.leftFile;
                fileNameLabel.ToolTip=this.leftFileFull;
            else
                richtextDisplay.HTML=this.rightHTML;
                sideIndicator.Name=[upper(sideIndicatorStruct.(this.SIDE_RIGHT)),': '];
                fileNameLabel.Name=this.rightFile;
                fileNameLabel.ToolTip=this.rightFileFull;
            end

            filePanel.Type='panel';
            filePanel.LayoutGrid=[1,2];
            filePanel.ColStretch=[0,1];
            filePanel.RowSpan=[1,1];
            filePanel.ColSpan=[1,1];
            filePanel.Items={sideIndicator,fileNameLabel};

            panelStruct.Type='panel';
            panelStruct.Tag=[this.PANEL_TAG,side];
            panelStruct.LayoutGrid=[5,1];
            panelStruct.RowStretch=[0,0,0,1,0];

            topEllipsis.Type='text';
            topEllipsis.Name='...';
            topEllipsis.Alignment=6;
            topEllipsis.RowSpan=[2,2];
            topEllipsis.ColSpan=[1,1];

            bottomEllipsis=topEllipsis;
            bottomEllipsis.RowSpan=[5,5];

            panelStruct.Items={filePanel,topEllipsis,comparisonProperty,richtextDisplay,bottomEllipsis};
        end
    end
end
