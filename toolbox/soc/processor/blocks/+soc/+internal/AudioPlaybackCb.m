function varargout=AudioPlaybackCb(func,blkH,varargin)




    if nargout==0
        feval(func,blkH,varargin{:});
    else
        [varargout{1:nargout}]=feval(func,blkH,varargin{:});
    end
end


function LoadFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
end


function InitFcn(~)
    soc.internal.HWSWMessageTypeDef();
end


function PreSaveFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
end


function MaskInitFcn(blkH)%#ok<*DEFNU>
    persistent hadError
    if isempty(hadError)
        hadError=false;
    end
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');
    try
        codeGenBlk=[blkPath,'/Variant/CODEGEN/Audio Playback'];





        set_param(blkPath,'BlockSID',codertarget.peripherals.utils.getBlockSID(blkH,false));


        blockSID=codertarget.peripherals.utils.getBlockSID(blkH,true);
        set_param(codeGenBlk,'BlockID',blockSID);
        set_param(codeGenBlk,'NumberOfChannels',num2str(blkP.NumberOfChannels));
        soc.internal.setBlockIcon(blkH,'socicons.AudioPlayback');
        locSetMaskHelp(blkH);
    catch ME
        hadError=true;
        rethrow(ME);
    end
end


function setPeripheralConfigButtonVisibility(blkH)

    codertarget.peripherals.utils.setBlockMaskButtonVisibility(blkH,'PeripheralConfigBtn');
end


function locSetMaskHelp(blkH)
    helpcmd='eval(''soc.internal.helpview(''''soc_audioplayback'''')'')';
    set_param(blkH,'MaskHelp',helpcmd);
end
