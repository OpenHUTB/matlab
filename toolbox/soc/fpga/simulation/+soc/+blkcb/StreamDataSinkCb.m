function varargout=StreamDataSinkCb(varargin)




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

    try

        if strcmp(blkP.SaveData,'on')
            vs='Logger';
        else
            vs='NoLogger';
        end
        set_param([blkPath,'/Log/LogInput'],'OverrideUsingVariant',vs);




        SetMaskDisplay(blkH);
        soc.internal.setBlockIcon(blkH,'socicons.StreamDataSink');

    catch ME
        hadError=true;
        rethrow(ME);
    end
end

function[vis,ens]=SaveDataCb(~,val,vis,ens,idxMap)
    vis{idxMap('SavedName')}=val;
end

function SetMaskHelp(blkH)

    helpTopic='soc_streamdatasink';
    fullhelp=sprintf('eval(''soc.internal.helpview(''''%s'''')'');',helpTopic);

    set_param(blkH,'MaskHelp',fullhelp);

end

function SetMaskDisplay(blkH)

    set_param(blkH,'MaskDisplay','');
end



