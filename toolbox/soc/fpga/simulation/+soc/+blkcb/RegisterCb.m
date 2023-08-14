function varargout=RegisterCb(func,blkH,varargin)
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
    REG_MAX_WORDLEN=32;
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH);

    l_SetMaskHelp(blkH);

    try
        hHWSWMessageSend=[blkPath,'/Variant/HW To SW/HWSW Message Send'];
        hHWSWMessageReceive=[blkPath,'/Variant/SW To HW/HWSW Message Receive'];
        hRegisterDataPort=[blkPath,'/Variant/SW To HW/Out'];

        switch(class(blkP.DataTypeStr))

        case 'Simulink.NumericType'
            assert(blkP.DataTypeStr.WordLength<=REG_MAX_WORDLEN,message('soc:msgs:MaxRegistersWordLength',REG_MAX_WORDLEN));
        case 'char'
            ;%#ok<NOSEMI> %do nothing
        case 'Simulink.AliasType'
            try
                DataType=blkP.DataTypeStr.BaseType;
                DataType=evalin('base',DataType);
            catch ME %#ok<NASGU>

            end
            switch class(DataType)
            case 'Simulink.NumericType'
                assert(DataType.WordLength<=REG_MAX_WORDLEN,message('soc:msgs:MaxRegistersWordLength',REG_MAX_WORDLEN));
            case 'char'
                ;%#ok<NOSEMI> %do nothing
            otherwise
                error('Data type not supported');
            end
        otherwise
            error('Data type not supported');
        end

        set_param(hRegisterDataPort,'OutDataTypeStr',get_param(blkH,'DataTypeStr'));
        set_param(hRegisterDataPort,'PortDimensions',get_param(blkH,'VectorSize'));

        set_param(hHWSWMessageReceive,'DataTypeStr',get_param(blkH,'DataTypeStr'));
        set_param(hHWSWMessageReceive,'Dimensions',num2str(blkP.VectorSize));

        switch blkP.Direction
        case 'None'
            set_param([blkPath,'/Variant'],'LabelModeActiveChoice','None');
        case 'HW to SW'
            set_param([blkPath,'/Variant'],'LabelModeActiveChoice','HWToSW');
        case 'SW to HW'
            set_param([blkPath,'/Variant'],'LabelModeActiveChoice','SWToHW');
        end

        SetMaskDisplay(blkH,blkP);
    catch ME
        hadError=true;
        rethrow(ME);
    end
end

function SetMaskDisplay(blkH,blkP)

    fulltext1=sprintf('color(''black'')');
    fulltext2=sprintf('text(0.5,0.7,''{\\bf%s}'',''horizontalAlignment'',''center'',''texmode'',''on'')',blkP.Direction);

    md=sprintf('%s;\n%s;',fulltext1,fulltext2);
    set_param(blkH,'MaskDisplay',md);
end

function l_SetMaskHelp(blkH)




    fullhelp='eval(''soc.internal.openDoc()'')';

    set_param(blkH,'MaskHelp',fullhelp);
end

