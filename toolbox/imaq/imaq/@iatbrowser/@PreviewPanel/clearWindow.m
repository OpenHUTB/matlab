function clearWindow(this,nodeClass,specificHelpText)











    assert(exist('nodeClass','var')==1,'nodeClass undefined');
    assert(ischar(nodeClass),'nodeClass should be a string');

    set(this.fig,'WindowButtonMotionFcn',[]);

    if ishghandle(this.toolTip)
        set(this.toolTip,'Visible','off');
    end



    this.image=image(zeros(300,300,1),'Parent',this.axis);

    delete(this.image);

    set(this.axis,'Units','Pixels','XTick',[],'YTick',[]);
    set(this.timeLabel,'String','');
    set(this.frameRateLabel,'String','');
    set(this.fig,'ResizeFcn',@resizeClearedWindow);

    resizeClearedWindow();

    function resizeClearedWindow(src,evt)%#ok<INUSD, INUSD>
        set(this.axis,'Color',get(this.fig,'Color'));

        this.setButtonPanelPosition();
        this.setStatLabelPosition();
        this.setTimeLabelPosition();


        [minX,minY,maxWidth,maxHeight]=this.findExtents();
        set(this.axis,'Units','Pixels')
        set(this.axis,...
        'Position',floor([minX,minY,max(maxWidth,1),max(maxHeight,1)]));

        set(this.axis,'Color',get(this.fig,'Color'));


        set(this.axis,'XColor',[153,153,153]/255);
        set(this.axis,'YColor',[153,153,153]/255);


        axis(this.axis,'normal');

        if ishghandle(this.helpText)

            if exist('specificHelpText','var')
                set(this.helpText,'String',specificHelpText);
            else
                set(this.helpText,'String',iatbrowser.getResourceString('RES_DESKTOP','PreviewPanel.HelpMessage'));
            end
        else

            if exist('specificHelpText','var')
                textToShow=specificHelpText;
            else
                textToShow=iatbrowser.getResourceString('RES_DESKTOP','PreviewPanel.HelpMessage');
            end

            this.helpText=text(maxWidth/2,maxHeight/2,...
            textToShow,...
            'HorizontalAlignment','Center','Parent',this.axis);

            if ispc


                defaults=javaMethodEDT('getLookAndFeelDefaults','javax.swing.UIManager');
                defaultFont=defaults.getFont('Label.font');

                set(this.helpText,'FontName',char(defaultFont.getFontName));
            end
        end
        set(this.helpText,...
        'Units','Pixels','Position',[maxWidth/2,maxHeight/2,0]);
        set(this.helpText,'Visible','on');
    end
end
