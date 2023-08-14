function varargout=profile(h,opt,fmt,varargin)















































    narginchk(1,4);
    linkfoundation.util.errorIfArray(h);




    if nargin==1,
        DAStudio.error('ERRORHANDLER:autointerface:ProfileObsoleteSyntax');
    elseif nargin==2,
        arg2=opt;
        if~isempty(arg2)&&isnumeric(arg2),
            DAStudio.error('ERRORHANDLER:autointerface:ProfileObsoleteSyntaxTimeout');
        elseif ischar(arg2)&&strcmpi(arg2,'report'),
            DAStudio.error('ERRORHANDLER:autointerface:ProfileObsoleteSyntaxFormat');
        end
    elseif nargin==3,
        arg2=opt;
        arg3=fmt;
        if ischar(arg2)&&strcmpi(arg2,'report'),
            opt='execution';
            fmt=arg2;
            if~isempty(arg3)&&isnumeric(arg3),
                DAStudio.error('ERRORHANDLER:autointerface:ProfileObsoleteSyntaxFormatAndTimeout');
            else
                DAStudio.error('ERRORHANDLER:autointerface:ProfileObsoleteSyntaxFormatAndEmptyTimeout');
            end
        end
    end




    if nargin>=2,
        if ischar(opt)&&any(strcmpi(opt,{'execution','stack'}))
            if nargin==2,
                fmt='report';
                if strcmpi(opt,'execution')
                    dtimeout=h.timeout;
                elseif strcmpi(opt,'stack')
                    internalUseFlag='';
                end
            end
        else
            DAStudio.error('ERRORHANDLER:autointerface:ProfileInvalidSecondInput');
        end
    end
    if nargin>=3,
        if~ischar(opt)
            DAStudio.error('ERRORHANDLER:autointerface:ProfileInvalidSecondInput');
        end
        if~ischar(fmt)
            DAStudio.error('ERRORHANDLER:autointerface:ProfileInvalidThirdInput');
        end
        if nargin==3
            if strcmpi(opt,'execution')
                dtimeout=h.timeout;
            elseif strcmpi(opt,'stack')
                if strcmpi(fmt,'setup')
                    internalUseFlag='';
                elseif strcmpi(fmt,'report')
                    internalUseFlag='';
                end
            end
        elseif nargin==4
            arg4=varargin{1};
            if strcmpi(opt,'execution')
                if isnumeric(arg4),
                    if isempty(arg4)
                        dtimeout=h.timeout;
                    else
                        dtimeout=arg4;
                    end
                else
                    DAStudio.error('ERRORHANDLER:autointerface:ProfileInvalidFourthInput');
                end
            elseif strcmpi(opt,'stack')
                if strcmpi(fmt,'setup')
                    if strcmp(arg4,'internalUseFlag')
                        internalUseFlag='internalUseFlag';
                    end
                elseif strcmpi(fmt,'report')
                    internalUseFlag=arg4;
                end
            end
        end
    end

    if exist('dtimeout','var')

        dtimeout=linkfoundation.util.checkTimeoutParam(nargin,1,dtimeout,h.timeout);
        dtimeout=dtimeout*1000;
    end

    if ispref('Embedded_IDE_Link_Testing')&&ispref('Embedded_IDE_Link_Testing','Check_Method_Inputs')
        diagnostics.opt=opt;
        diagnostics.fmt=fmt;
        if exist('dtimeout','var')
            diagnostics.timeout=dtimeout/1000;
        end
        if exist('internalUseFlag','var')
            diagnostics.internalUseFlag=internalUseFlag;
        end
        varargout{1}=diagnostics;
        return;
    end




    switch lower(opt)
    case 'execution'
        switch fmt
        case 'report',
            varargout{1}=h.getExeProfileReport;
        otherwise,
            DAStudio.error('ERRORHANDLER:autointerface:ProfileInvalidFormattingOption',fmt);
        end
    case 'stack'
        switch fmt
        case 'setup',
            if exist('internalUseFlag','var')&&~isempty(internalUseFlag)&&strcmpi(internalUseFlag,'internalUseFlag')
                if nargin==4
                    [varargout{1},varargout{2}]=h.profilestack('setup',internalUseFlag,true);
                else

                    DAStudio.error('ERRORHANDLER:autointerface:ProfileTooManyInputArgs');
                end
            else
                h.profilestack('setup');
            end
        case 'report',
            if exist('internalUseFlag','var')&&~isempty(internalUseFlag)
                if strcmpi(internalUseFlag,'internalUseFlag')
                    [varargout{1},varargout{2}]=h.profilestack('report',internalUseFlag,true);
                else

                    DAStudio.error('ERRORHANDLER:autointerface:ProfileTooManyInputArgs');
                end
            else
                h.profilestack('report');
            end
        otherwise,
            DAStudio.error('ERRORHANDLER:autointerface:StackProfileInvalidAction',fmt);
        end
    otherwise
        DAStudio.error('ERRORHANDLER:autointerface:ProfileInvalidProfilingOperation',opt);
    end


