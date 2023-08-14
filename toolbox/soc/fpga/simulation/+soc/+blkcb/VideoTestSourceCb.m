function varargout=VideoTestSourceCb(varargin)




    if nargout==0
        feval(varargin{:});
    else
        [varargout{1:nargout}]=feval(varargin{:});
    end
end


function MaskParamCb(paramName,blkH)
    cbH=eval(['@',paramName,'Cb']);
    soc.blkcb.cbutils('MaskParamCb',paramName,blkH,cbH);
end


function InitFcn(blkH)


    if~builtin('license','checkout','SoC_Blockset')
        error(message('soc:utils:NoLicense'));
    end

    hsb.blkcb2.defineTypes(bdroot(blkH));

end

function StopFcn(blkH)


    if~builtin('license','checkout','SoC_Blockset')
        error(message('soc:utils:NoLicense'));
    end

    vble=get_param(blkH,'VbleName');
    evalin('base',['clear ',vble,'Temp;']);

end



function MaskInitFcn(blkH,~)%#ok<*DEFNU>
    persistent hadError
    if isempty(hadError)
        hadError=false;
    end

    if soc.blkcb.cbutils('IsLibContext',blkH),return;end

    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH);

    SetMaskHelp(blkH);

    if strcmp(blkP.VideoSource,'Video file')&&~builtin('license','test','video_and_image_blockset')
        error(message('soc:msgs:noCVTLicenseVideoSource'));
    end

    FrameBlock=[blkPath,'/Frame-based Video Test Source'];
    setSampleTimeFrameBlock=[FrameBlock,'/setSampleTime'];
    reoderFrameBlock=[FrameBlock,'/ReorderFrame'];

    try
        try
            validateattributes(blkP.inFrameSampleTime,{'numeric'},{'row'});
            if numel(blkP.inFrameSampleTime)>2,throw();end
            validateattributes(blkP.inFrameSampleTime(1),{'numeric'},{'positive'});
            if numel(blkP.inFrameSampleTime)>1
                validateattributes(blkP.inFrameSampleTime(2),{'numeric'},{'nonnegative','<',blkP.inFrameSampleTime(1)});
            end
        catch
            error(message('Simulink:SampleTime:InvTsParamSetting_Vector',blkPath,'SampleTime'));
        end

        set_param(FrameBlock,'FrameSize',get_param(blkH,'FrameSize'));
        set_param(FrameBlock,'VideoSource',get_param(blkH,'VideoSource'));
        set_param(FrameBlock,'inputFileName',get_param(blkH,'inputFilename'));
        set_param(FrameBlock,'ColorSpace',get_param(blkH,'ColorSpace'));
        set_param(FrameBlock,'Unpack',blkP.Unpack);
        set_param(FrameBlock,'inFrameSampleTime',get_param(blkH,'inFrameSampleTime'));
        set_param(reoderFrameBlock,'SampleTime',get_param(blkH,'inFrameSampleTime'));
        set_param(setSampleTimeFrameBlock,'SampleTime',get_param(blkH,'inFrameSampleTime'));
        set_param(FrameBlock,'inMode','Frame');
        set_param(FrameBlock,'Datatype',blkP.DataType);
        set_param(FrameBlock,'ReorderFrame',blkP.ReorderFrame);

        SetMaskDisplay(blkH);
        soc.internal.setBlockIcon(blkH,'socicons.VideoTestSource');

    catch ME
        hadError=true;
        rethrow(ME);
    end
end

function[vis,ens]=VideoSourceCb(blkH,val,vis,ens,idxMap)
    mo=get_param(blkH,'maskobject');
    button=mo.getDialogControl('browse');
    switch val
    case 'Color bar'
        vis{idxMap('inputFilename')}='off';
        button.Visible='off';
    case 'Ramp'
        vis{idxMap('inputFilename')}='off';
        button.Visible='off';
    case 'Video file'
        vis{idxMap('inputFilename')}='on';
        button.Visible='on';
    end
end

function browseCb(blkH)
    if ispc
        [file,path]=uigetfile({'*.qt;*.mov;*.avi;*.asf;*.asx;*.wmv;*.mpg;*.mpeg;*.mp2;*.mp4;*.m4v'},'Pick an input file');
    else
        [file,path]=uigetfile({'*.mj2;*.mov;*.avi;*.mp4;*.m4v'},'Pick an input file');
    end
    if file~=0
        set_param(blkH,'inputFilename',[path,file]);
    end
end

function SetMaskHelp(blkH)

    helpTopic='soc_videotestsource';
    fullhelp=sprintf('eval(''soc.internal.helpview(''''%s'''')'');',helpTopic);

    set_param(blkH,'MaskHelp',fullhelp);

end

function SetMaskDisplay(blkH)

    set_param(blkH,'MaskDisplay','');
end



