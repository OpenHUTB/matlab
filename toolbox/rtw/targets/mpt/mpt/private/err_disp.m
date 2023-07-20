function err_disp(modelName,msgType,errMsg,varargin)












    mpmResult=rtwprivate('rtwattic','AtticData','mpmResult');

    if isempty(mpmResult)|isfield(mpmResult,'err')==0
        mpmResult.err.MemMode=0;
    end

    if mpmResult.err.MemMode==0

        if isempty(modelName)
            mpmResult.err.MemMode=2;
        else
            mpmResult.err.MemMode=1;
        end
    end
    if mpmResult.err.MemMode==2&&~isempty(modelName)
        mpmResult.err.MemMode=1;
    end
    rtwprivate('rtwattic','AtticData','mpmResult',mpmResult);
    switch msgType
    case 'Error'
        msgtype='Error';
    case 'Warning'
        msgtype='Warning';
    otherwise
        disp('Unknown type');
    end
    if isempty(varargin)==0
        errDetail=varargin{1};
        msg=sprintf('Model: "%s"\n  %s',modelName,errDetail);
    else
        msg=sprintf('Model: "%s"\n  %s',modelName,errMsg);
    end
    if strcmpi(msgtype,'Error')
        sldiagviewer.reportError(msg,'Component','MPT','Category','MPT');
    elseif strcmpi(msgtype,'Warning')
        sldiagviewer.reportWarning(msg,'Component','MPT','Category','MPT');
    end

