classdef ExceptionDialog<vision.internal.uitools.OkDlg



















    properties

        Exception MException



        InternalCodeSearchPattern={};


        Panel matlab.ui.container.Panel


TextBox


        TextString=getString(message('vision:labeler:ErrorEncounteredAlgo'));


PanelContainer


TextPanel
LinkPanel
LinkText

    end

    methods

        function this=ExceptionDialog(tool,dlgTitle,exception,windowStyle,...
            textString,internalCodePattern)

            this=this@vision.internal.uitools.OkDlg(tool,dlgTitle);

            this.Exception=exception;

            if nargin>4
                this.TextString=textString;
            end

            if nargin>5
                this.InternalCodeSearchPattern=internalCodePattern;
            end


            this.DlgSize=[600,300];

            createDialog(this);



            this.Dlg.WindowStyle=windowStyle;
            this.Dlg.Tag='ExceptionDialog';

            addExceptionPanel(this);

        end
    end

    methods(Access=private)

        function addExceptionPanel(this)

            heightGap=50;
            widthGap=0;


            this.Panel=uipanel(this.Dlg,'Units','pixels',...
            'Position',[widthGap,heightGap,this.DlgSize(1)-widthGap,this.DlgSize(2)-heightGap]',...
            'Visible','off');

            if useAppContainer

                this.TextBox=uilabel('Parent',this.Panel,...
                'Text',this.TextString,...
                'Position',[2,this.DlgSize(2)-2*heightGap,this.DlgSize(1)-2,heightGap],...
                'WordWrap','on');


                panelHeight=this.Panel.Position(4)-this.TextBox.Position(4);
                this.LinkPanel=uipanel('Parent',this.Panel,...
                'Units','pixels',...
                'Position',[1,1,this.DlgSize(1)-2,panelHeight],...
                'BackgroundColor',[1,1,1],...
                'Scrollable','on');


                labelHeight=calcLabelHeight(this);
                this.LinkText=uilabel('Parent',this.LinkPanel,...
                'Text',this.trimmedReport,...
                'Position',[2,1,this.DlgSize(1)-20,labelHeight],...
                'VerticalAlignment','top',...
                'Interpreter','html',...
                'WordWrap','on');

            else

                this.TextBox=uicontrol('Parent',this.Panel,...
                'Style','text','HorizontalAlignment','left',...
                'Tag','exceptionText','String',this.TextString);

                jlinkHandler=javaObjectEDT(com.mathworks.mlwidgets.MatlabHyperlinkHandler);
                jlinkText=javaObjectEDT(com.mathworks.widgets.HyperlinkTextLabel);
                jlinkText.setAccessibleName('exceptionLinkText');
                jlinkText.setHyperlinkHandler(jlinkHandler);



                report=trimmedReport(this);
                jlinkText.setText(report);
                jlinkText.setBackgroundColor(java.awt.Color.white);


                hPanel=javaObjectEDT('javax.swing.JScrollPane',jlinkText.getComponent());
                hPanel.setBackground(java.awt.Color.white);

                [~,this.PanelContainer]=...
                matlab.ui.internal.JavaMigrationTools.suppressedJavaComponent(hPanel,[1,1,10,10],this.Panel);

                positionControls(this);

                this.Panel.SizeChangedFcn=@this.positionControls;
            end

            set(this.Panel,'Visible','on');

        end


        function report=trimmedReport(this)

            report=vision.internal.getTrimmedReport(...
            this.Exception,this.InternalCodeSearchPattern);


            report=strrep(report,newline,'<br>');
        end


        function positionControls(this,varargin)

            canvas=getpixelposition(this.Panel);

            width=canvas(3);
            height=canvas(4);
            bottom=height;


            bottom=bottom-20;


            headerHeight=20;
            bottom=bottom-headerHeight;
            this.TextBox.Position=...
            [1,bottom,width,headerHeight];


            bottom=bottom-20;


            panelHeight=bottom;
            this.PanelContainer.Position=[1,1,width,panelHeight];

        end

    end
end

function labelHeight=calcLabelHeight(this)


    pixcharFactor=14;

    textHeight1=2*numel(this.Exception.stack)*pixcharFactor;
    panelPosChar=this.DlgSize(1)/pixcharFactor;
    nlines=numel(this.trimmedReport)/floor(panelPosChar);
    textHeight2=nlines*pixcharFactor;
    textHeight=min(textHeight1,textHeight2);

    needsScroll=textHeight>this.LinkPanel.Position(4);
    if needsScroll

        labelHeight=max(textHeight,this.LinkPanel.Position(4));
        drawnow();
        scroll(this.LinkPanel,'top');
    else

        labelHeight=min(textHeight,this.LinkPanel.Position(4)-20);
    end
end

function tf=useAppContainer(~)
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end