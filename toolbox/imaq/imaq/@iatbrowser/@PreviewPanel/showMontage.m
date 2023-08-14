function framesAvailableForExport=showMontage(this,vidObj)






    assert(nargin==2,'2 input arguments required!');
    this.previewing=false;

    set(this.fig,'HandleVisibility','on');

    this.image=[];
    axis(this.axis);
    set(this.fig,'ResizeFcn',@resizeMontage);

    this.hideRuntimeLabels();

    try
        framesAvailableForExport=vidObj.FramesAvailable;
        this.data=peekdata(vidObj,framesAvailableForExport);
    catch err
        framesAvailableForExport=0;
        if(strcmp(err.identifier,'imaq:imaqmex:outofmemory'))


            od=iatbrowser.OptionDialog;
            od.showOptionDialog(...
            com.mathworks.toolbox.imaq.browser.IATBrowserDesktop.getInstance.getMainFrame,...
            'GETDATA_FAILED',...
            imaqgate('privateGetField',vidObj,'uddobject'),...
            @saveAvailFrames,...
            @discardAvailFrames);
            return;
        else

            md=iatbrowser.MessageDialog();
            md.showMessageDialogWithAdditionalMessage(...
            iatbrowser.getDesktopFrame(),...
            'START_ACQUISITION_FAILED',...
            err.getReport('basic','hyperlinks','off'),...
            [],...
            []);
            return;
        end
    end

    maxFrames=9;
    if(length(this.data(1,1,1,:))>maxFrames)
        indices=floor(linspace(1,length(this.data(1,1,1,:)),maxFrames));
        this.image=imaqmontage(this.data(:,:,:,indices),'Parent',this.axis);
        statMsg=imaqgate('privateGetJavaResourceString',...
        'com.mathworks.toolbox.imaq.browser.resources.RES_DESKTOP',...
        'PreviewPanel.Disp9Frames');
        set(this.statLabel,'String',sprintf(statMsg,length(this.data(1,1,1,:)),indices(:)));
    else
        indices=1:1:size(this.data,4);
        this.image=imaqmontage(this.data,'Parent',this.axis);
        statMsg=imaqgate('privateGetJavaResourceString',...
        'com.mathworks.toolbox.imaq.browser.resources.RES_DESKTOP',...
        'PreviewPanel.DispAllFrames');
        set(this.statLabel,'String',statMsg);
    end


    this.toolTip=text(0,0,'');
    set(this.toolTip,'Visible','off');
    set(this.toolTip,'Units','normalized');

    toolTipColor=java.awt.SystemColor.info;
    set(this.toolTip,'BackgroundColor',[toolTipColor.getRed,toolTipColor.getGreen,toolTipColor.getBlue]/255);
    textColor=java.awt.SystemColor.infoText;
    set(this.toolTip,'Color',[textColor.getRed,textColor.getGreen,textColor.getBlue]/255);

    set(this.fig,'WindowButtonMotionFcn',{@windowButtonMotionFcn,indices});
    set(this.fig,'HandleVisibility','off');

    resizeMontage();

    drawnow;

    function resizeMontage(src,evt)%#ok<INUSD>
        this.setButtonPanelPosition();
        this.setStatLabelPosition();
        this.setTimeLabelPosition();
        [minX,minY,maxWidth,maxHeight]=this.findExtents();

        montageSize=size(get(this.image,'CData'));
        montageWidth=montageSize(2);
        montageHeight=montageSize(1);
        if montageWidth<maxWidth&&montageHeight<maxHeight
            set(this.axis,'Units','Pixels',...
            'Position',...
            [minX+(maxWidth/2)-(montageWidth/2),...
            minY+(maxHeight/2)-(montageHeight/2),...
            max(montageWidth,1),max(montageHeight,1)]);
        else
            set(this.axis,'Units','Pixels',...
            'Position',[minX,minY,max(maxWidth,1),max(maxHeight,1)]);
        end

        axis(this.axis,'image');
    end

    function windowButtonMotionFcn(src,event,indices)
        this.handleToolTipMotion(src,event,indices);
    end

    function saveAvailFrames(cb,obj)
        vidObj=imaqgate('privateUDDToMATLAB',handle(obj.JavaEvent));
        [filename,pathname]=uiputfile('*.mat',iatbrowser.getResourceString('RES_DESKTOP','DataExport.SaveConfirmDialog.MATFileTitle'));
        if ischar(filename)&&ischar(pathname)
            this.saveAvailableFrames(fullfile(pathname,filename),vidObj);
        else
            discardAvailFrames(cb,obj);
        end
    end

    function discardAvailFrames(cb,obj)%#ok<INUSL>
        vidObj=imaqgate('privateUDDToMATLAB',handle(obj.JavaEvent));
        flushdata(vidObj);
    end

end