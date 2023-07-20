function varargout=VideoTestSinkCb(varargin)




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


function MaskInitFcn(blkH,~)%#ok<*DEFNU>
    persistent hadError
    if isempty(hadError)
        hadError=false;
    end

    if soc.blkcb.cbutils('IsLibContext',blkH),return;end

    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH);

    SetMaskHelp(blkH);

    if strcmp(blkP.viewoutput,'on')&&~builtin('license','test','video_and_image_blockset')
        error(message('soc:msgs:noCVTLicenseVideoSink'));
    end

    try
        ff=hsb.blkcb2.socVideoTestStimulusMap(blkP.FrameSize);

        switch get_param(blkH,'ColorSpace')
        case 'YCbCr422'
            variantSelect='YCbCrUnpack';
            numPorts='2';
        case 'RGB'
            variantSelect='RGBUnpack';
            numPorts='3';
        case 'YOnly'
            variantSelect='YOnly';
            numPorts='1';
        end

        set_param([blkPath,'/Enabled Subsystem/Visualize'],'OverrideUsingVariant',variantSelect);
        set_param([blkPath,'/Enabled Subsystem/Visualize/',variantSelect,'/visualize'],'OverrideUsingVariant',blkP.viewoutput);
        set_param([blkPath,'/Enabled Subsystem/DataLogging'],'OverrideUsingVariant',blkP.loginput);
        set_param([blkPath,'/Enabled Subsystem/DataLogging/Logging/To Workspace'],'VariableName',get_param(blkH,'variablename'));
        set_param([blkPath,'/Enabled Subsystem/Visualize/YOnly/visualize/display/Constant'],'Value',['128*ones(',num2str(ff.ActiveVideoLines),',',num2str(ff.ActivePixelsPerLine/2),')']);

        if strcmp(blkP.ReorderFrame,'on')
            set_param([blkPath,'/ReorderFrame'],'Value','1');
        else
            set_param([blkPath,'/ReorderFrame'],'Value','0');
        end

        if strcmp(get_param(blkH,'outMode'),'Frame')
            if strcmp(blkP.Unpack,'on')
                set_param([blkPath,'/Reshape'],'OutputDimensions',['[',num2str(ff.ActivePixelsPerLine),' ',num2str(ff.ActiveVideoLines),' ',numPorts,']']);
            else
                set_param([blkPath,'/Reshape'],'OutputDimensions',['[',num2str(ff.ActivePixelsPerLine),' ',num2str(ff.ActiveVideoLines),']']);
            end
        end

        if strcmp(blkP.Porch,'on')
            TotalPixelsPerLine=ff.TotalPixelsPerLine;
            TotalVideoLines=ff.TotalVideoLines;
        else

            TotalPixelsPerLine=ff.ActivePixelsPerLine;
            TotalVideoLines=ff.ActiveVideoLines;
        end

        SetMaskDisplay(blkH);
        soc.internal.setBlockIcon(blkH,'socicons.VideoTestSink');

    catch ME
        hadError=true;
        rethrow(ME);
    end
end

function[vis,ens]=loginputCb(~,val,vis,ens,idxMap)
    vis{idxMap('variablename')}=val;
end

function SetMaskHelp(blkH)

    helpTopic='soc_videotestsink';
    fullhelp=sprintf('eval(''soc.internal.helpview(''''%s'''')'');',helpTopic);

    set_param(blkH,'MaskHelp',fullhelp);

end

function SetMaskDisplay(blkH)

    set_param(blkH,'MaskDisplay','');
end



