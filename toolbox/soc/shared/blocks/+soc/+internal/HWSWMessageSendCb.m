function varargout=HWSWMessageSendCb(func,blkH,varargin)




    if nargout==0
        feval(func,blkH,varargin{:});
    else
        [varargout{1:nargout}]=feval(func,blkH,varargin{:});
    end
end

function MaskInitFcn(blkH)%#ok<*DEFNU>

    persistent hadError
    if isempty(hadError)
        hadError=false;
    end



    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH,'slResolve');

    try

        MessageType=get_param(blkH,'MessageType');
        set_param(blkH,'MessageID',['HWSWMetadataID.',MessageType]);


        EnableDonePort=get_param(blkH,'EnableDonePort');
        hDoneVariant=[blkPath,'/Done Variant'];

        switch EnableDonePort
        case 'on'
            set_param(hDoneVariant,'LabelModeActiveChoice','DoneOn');
        case 'off'
            set_param(hDoneVariant,'LabelModeActiveChoice','DoneOff');
        end


        EnableEventPort=get_param(blkH,'EnableEventPort');
        hEventVariant=[blkPath,'/Event Variant'];
        switch EnableEventPort
        case 'on'
            set_param(hEventVariant,'LabelModeActiveChoice','EventOn');
        case 'off'
            set_param(hEventVariant,'LabelModeActiveChoice','EventOff');
        end
        hDataPack=[blkPath,'/Data Pack'];
        set_param(hDataPack,'QueueLength',get_param(blkH,'QueueLength'));
    catch ME
        hadError=true;
        rethrow(ME);
    end

end

function InitFcn(blkH)

    if~builtin('license','checkout','SoC_Blockset')
        error(message('soc:utils:NoLicense'));
    end


    soc.internal.HWSWMessageTypeDef();
































































end

function CopyFcn(blkH)





end

function DeleteFcn(blkH)


























end

function EventportH=l_eventPort(blkH,blkPath,EventPortStr)

    blkportH=get_param(blkH,'PortHandles');
    if strcmp(get_param([blkPath,'/',EventPortStr],'BlockType'),'Outport')
        EventportH=blkportH.Outport(end);
    else
        EventportH=[];
    end
end
