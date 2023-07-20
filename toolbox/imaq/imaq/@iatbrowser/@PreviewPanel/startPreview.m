function startPreview(this,vidObj,acqStarting)





    assert(exist('vidObj','var')==1,'vidObj undefined');
    assert(strcmpi(class(vidObj),'videoinput'),'vidObj should be a videoinput object');
    assert(isvalid(vidObj),'vidObj should be valid');

    wasPreviewing=this.isPreviewing;

    this.clearFrames();

    set(this.fig,'HandleVisibility','on');
    set(this.fig,'WindowButtonMotionFcn',[]);


    vidRes=get(vidObj,'ROIPosition');
    this.imWidth=vidRes(3);
    this.imHeight=vidRes(4);
    nBands=get(vidObj,'NumberOfBands');
    this.image=image(zeros(this.imHeight,this.imWidth,nBands),'Parent',this.axis);

    set(this.axis,'XLim',[0,this.imWidth]);
    set(this.image,'XData',get(this.image,'XData')-0.5);
    set(this.axis,'YLim',[0,this.imHeight]);
    set(this.image,'YData',get(this.image,'YData')-0.5);
    set(this.fig,'ResizeFcn',@resizePreview);


    setappdata(this.image,'UpdatePreviewWindowFcn',@updatePreview);
    setappdata(this.image,'UpdatePreviewStatusFcn',@updateStatus);


    setappdata(this.image,'HandleToStatusLabel',this.statLabel);
    setappdata(this.image,'HandleToTimeLabel',this.timeLabel);
    setappdata(this.image,'HandleToFrameRateLabel',this.frameRateLabel);
    set(this.image,'Visible','on');
    if ishghandle(this.helpText)&&isvalid(this.helpText)
        set(this.helpText,'Visible','off');
    end
    set(this.statLabel,'String',...
    imaqgate('privateGetJavaResourceString',...
    'com.mathworks.toolbox.imaq.browser.resources.RES_DESKTOP',...
    'PreviewPanel.waitingForStart'));

    this.showRuntimeLabels();
    resizePreview();

    preview(vidObj,this.image);













    this.previewing=true;

    if wasPreviewing==false


        if com.mathworks.toolbox.imaq.browser.IATBrowserDesktop.hasInstance()
            ed=iatbrowser.SessionLogEventData(vidObj,'preview(vid);\n\n');
            iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);
        end
    end

    set(this.fig,'HandleVisibility','off');

    function resizePreview(src,evt)%#ok<INUSD, INUSD>
        this.setButtonPanelPosition();
        this.setStatLabelPosition();
        this.setTimeLabelPosition();
        this.setFrameRateLabelPosition();
        [minX,minY,maxWidth,maxHeight]=this.findExtents();

        if((this.imWidth<=maxWidth)&&(this.imHeight<=maxHeight))

            newY=this.imHeight;
            halfY=floor((maxHeight-newY)/2);
            newX=this.imWidth;
            halfX=floor((maxWidth-newX)/2);
            set(this.axis,'Units','Pixels',...
            'Position',[minX+halfX,minY+halfY,max(this.imWidth,1),max(this.imHeight,1)]);
        elseif((this.imWidth/this.imHeight>=1))


            scale=maxWidth/this.imWidth;
            newY=scale*this.imHeight;
            newX=maxWidth;
            if(newY>maxHeight)
                scale=maxHeight/newY;
                newY=scale*newY;
                newX=scale*newX;

                halfY=floor((maxHeight-newY)/2);
                halfX=floor((maxWidth-newX)/2);
                set(this.axis,'Units','Pixels',...
                'Position',[minX+halfX,minY+halfY,max(newX,1),max(newY,1)]);
            else
                halfY=floor((maxHeight-newY)/2);
                set(this.axis,'Units','Pixels',...
                'Position',[minX,minY+halfY,max(newX,1),max(newY,1)]);
            end
        else


            scale=maxHeight/this.imHeight;
            newX=scale*this.imWidth;
            newY=maxHeight;
            if(newX>maxWidth)
                scale=maxWidth/newX;
                newX=scale*newX;
                newY=scale*newY;

                halfX=floor((maxWidth-newX)/2);
                halfY=floor((maxHeight-newY)/2);
                set(this.axis,'Units','Pixels',...
                'Position',[minX+halfX,minY+halfY,max(newX,1),max(newY,1)]);
            else
                halfX=floor((maxWidth-newX)/2);
                set(this.axis,'Units','Pixels',...
                'Position',[minX+halfX,minY,max(newX,1),max(newY,1)]);
            end
        end
    end

    function updateStatus(obj,event,himage)%#ok<INUSL>

        stat=event.Status;
        timestamp=event.Timestamp;
        framerate=event.FrameRate;
        setStatusLabels(himage,stat,timestamp,framerate);
    end

    function setStatusLabels(himage,stat,timestamp,framerate)

        hs=getappdata(himage,'HandleToStatusLabel');
        ht=getappdata(himage,'HandleToTimeLabel');
        hf=getappdata(himage,'HandleToFrameRateLabel');
        if acqStarting
            set(hs,'String',translateStatusIfNeeded(stat));
        end
        set(ht,'String',timestamp);
        if~isempty(framerate)
            set(hf,'String',framerate);
        end
    end

    function updatePreview(obj,event,himage)


        stat=event.Status;
        timestamp=event.Timestamp;
        frameRate=event.FrameRate;
        setStatusLabels(himage,stat,timestamp,frameRate);


        set(himage,'CData',event.Data);

        roiPosition=obj.ROIPosition;

        if~isequal([this.imWidth,this.imHeight],roiPosition([3,4]))
            this.imWidth=roiPosition(3);
            this.imHeight=roiPosition(4);
            resizePreview();
        end
    end

    function out=translateStatusIfNeeded(in)
        if strfind(in,'Waiting for manual TRIGGER')

            out=strrep(in,'TRIGGER','trigger');
        elseif strfind(in,'STOPPREVIEW')

            out='';
        else

            out=in;
        end
    end
end