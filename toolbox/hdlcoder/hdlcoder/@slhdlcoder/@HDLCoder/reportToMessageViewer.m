








function reportToMessageViewer(error_or_warning,msgID_or_string,varargin)

    assert(nargin>=2,['see, help',mfilename])

    hdl_coder_auto_build_stage=Simulink.output.Stage('HDLCoder','ModelName',gcs(),'UIMode',true);



    exceptionMsg=msgID_or_string;
    if(strcmpi(error_or_warning,'message'))

        if(nargin>2)
            exceptionMsg=[msgID_or_string,strjoin(varargin)];
        end
    else

        if(nargin>2)
            exceptionMsg=message(msgID_or_string,strjoin(varargin));
        else
            exceptionMsg=message(msgID_or_string);
        end
    end

    switch(lower(error_or_warning))
    case 'error'
        Simulink.output.error(MException(exceptionMsg),'Component','HDLCoder','Category','HDL');
    case 'warning'
        MSLDiagnostic(MException(exceptionMsg),'COMPONENT','HDLCoder','CATEGORY','HDL').reportAsWarning;
    case 'message'
        Simulink.output.info(exceptionMsg,'Component','HDLCoder','Category','HDL');
    otherwise
        assert(false,' first argument to slhdlcoder.HDLCoder.reportToMessageViewer should be ''warning'' or ''error'' or ''message''')
    end

    return
end
