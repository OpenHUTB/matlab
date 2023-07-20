function varargout=InterruptCb(func,blkH,varargin)
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
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH);

    l_SetMaskHelp(blkH);

    try
        switch blkP.Trigger
        case 'None'
            set_param([blkPath,'/Variant'],'LabelModeActiveChoice','None');

        case 'Positive level'
            set_param([blkPath,'/Variant'],'LabelModeActiveChoice','PLevel');

        case 'Rising edge'
            set_param([blkPath,'/Variant'],'LabelModeActiveChoice','REdge');

        case 'SoC event'
            set_param([blkPath,'/Variant'],'LabelModeActiveChoice','Event');

        end

        SetMaskDisplay(blkH,blkP);
    catch ME
        hadError=true;
        rethrow(ME);
    end
end

function SetMaskDisplay(blkH,blkP)

    fulltext1=sprintf('color(''black'')');
    fulltext2=sprintf('text(0.5,0.7,''{\\bf%s}'',''horizontalAlignment'',''center'',''texmode'',''on'')',blkP.Trigger);
    fulltext3=sprintf('text(0.5,0.5,''{\\bf%s}'',''horizontalAlignment'',''center'',''texmode'',''on'')',num2str(blkP.PortNumber));

    md=sprintf('%s;\n%s;\n%s;',fulltext1,fulltext2,fulltext3);
    set_param(blkH,'MaskDisplay',md);
end

function l_SetMaskHelp(blkH)




    fullhelp='eval(''soc.internal.openDoc()'')';

    set_param(blkH,'MaskHelp',fullhelp);
end

