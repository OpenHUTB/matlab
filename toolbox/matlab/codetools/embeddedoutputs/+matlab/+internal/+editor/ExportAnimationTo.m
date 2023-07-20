function ExportAnimationTo(evd)


    persistent wasFunctionCalled;
    if~isempty(wasFunctionCalled)&&wasFunctionCalled
        return
    end

    if evd.animationTooLarge
        if isempty(wasFunctionCalled)||~wasFunctionCalled
            wasFunctionCalled=true;
        end
        dialog=questdlg(getString(message('rich_text_component:embeddedOutputs:questDialogAnimationTooLarge')),...
        'Export Animation',...
        'Yes','No','Cancel','Yes');
        if any(strcmp(dialog,{'No','Cancel'}))||isempty(dialog)
            wasFunctionCalled=false;
            return
        end
    end

    options={'*.mp4','MPEG-4 Video (*.mp4)';...
    '*.avi','Video format (*.avi)';...
    '*.gif','Animated GIF (*.gif)'};

    isLinux=~(ismac||ispc);

    if isLinux
        options={'*.avi','Video format (*.avi)';...
        '*.gif','Animated GIF (*.gif)'};
    end

    if isempty(wasFunctionCalled)||~wasFunctionCalled
        wasFunctionCalled=true;
    end


    dlgTitle=getString(message('rich_text_component:embeddedOutputs:exportDialogTitle'));
    [file,path,indx]=uiputfile(options,dlgTitle);

    if~ischar(file)&&(file==0||path==0)
        wasFunctionCalled=false;
        return;
    end
    makeGif=false;
    profile='Motion JPEG AVI';

    if indx==1&&~isLinux
        profile='MPEG-4';
    elseif indx==3||(indx==2&&isLinux)
        makeGif=true;
    end
    isFirstFrame=true;
    waitBar=waitbar(0,dlgTitle);

    if~makeGif

        vw=VideoWriter(strcat(path,file),profile);
        open(vw);
    end

    numberOfFrame=length(evd.arrOfURIandTime);
    baseWaitBarIteractions=1/numberOfFrame;
    waitBarIteractions=baseWaitBarIteractions;
    for i=1:numberOfFrame
        if~isvalid(waitBar)
            break;
        else
            waitbar(waitBarIteractions,waitBar,dlgTitle);
            waitBarIteractions=waitBarIteractions+baseWaitBarIteractions;
        end


        newStr=extractAfter(evd.arrOfURIandTime(i).imageURI,"base64,");

        imageBytes=matlab.net.base64decode(string(newStr));
        cdata=matlab.graphics.internal.convertImageBytesToCData(imageBytes);
        frame.cdata=cdata;
        frame.colormap=[];
        if makeGif
            im=frame2im(frame);
            [imind,cm]=rgb2ind(im,256);
            fullPathFile=strcat(path,file);
            if isFirstFrame
                imwrite(imind,cm,fullPathFile,'gif','DelayTime',0.1,'Loopcount',inf);
                isFirstFrame=false;
            else
                imwrite(imind,cm,fullPathFile,'gif','DelayTime',0.1,'WriteMode','append');
            end
        else

            writeVideo(vw,frame);
        end
    end
    wasFunctionCalled=false;
    if~makeGif
        close(vw);
    end
    if isvalid(waitBar)
        waitbar(1,waitBar,dlgTitle);
        close(waitBar);
        delete(waitBar);
    end
end