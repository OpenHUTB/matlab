function removebrkpt(h,inputFormat,varargin)







































    narginchk(3,6);
    linkfoundation.util.errorIfArray(h);


    dtimeout=h.timeout;
    debugptType='break';
    numArgs=numel(varargin);

    switch(inputFormat)

    case 'FILE-LINE',




        fileName=varargin{1};
        lineNum=varargin{2};

        if numArgs>3
            debugptType=varargin{3};
        end
        if numArgs>4
            dtimeout=varargin{4};
            CheckTimeOutParam(h,dtimeout);
        end


        if numArgs<2,
            error(message('ERRORHANDLER:autointerface:Breakpoint_RequiresFilenameAndLineNum'));
        elseif~isnumeric(lineNum)||lineNum<0,
            error(message('ERRORHANDLER:autointerface:Breakpoint_InvalidLineNumber'));
        end


        action=GetActionId(h,debugptType);


        [~,fName,fExt]=fileparts(fileName);
        switch(action)
        case 1,
            try
                h.mIdeModule.ClearAllRequests;
                h.mIdeModule.DeleteBreakPointFileLine([fName,fExt],lineNum,dtimeout*1000);
            catch delException
                ThrowError(delException,debugptType,inputFormat);
            end
        case 2,
            try
                h.mIdeModule.ClearAllRequests;
                h.mIdeModule.DeleteProbePointFileLine([fName,fExt],lineNum,dtimeout*1000);
            catch delException
                ThrowError(delException,debugptType,inputFormat);
            end
        otherwise
            error(message('ERRORHANDLER:autointerface:Breakpoint_UnsupportedDebugType',debugptType));
        end

    case 'ALL',




        if numArgs>2
            debugptType=varargin{2};
        end
        if numArgs>3
            dtimeout=varargin{3};
            CheckTimeOutParam(h,dtimeout);
        end


        if nargin>5,
            error(message('ERRORHANDLER:autointerface:Breakpoint_InvalidNumOfArgs','all'));
        end


        action=GetActionId(h,debugptType);


        if(action~=1)
            error(message('ERRORHANDLER:autointerface:Breakpoint_InvalidArgsForAllMode'));
        end


        try
            h.mIdeModule.ClearAllRequests;
            h.mIdeModule.DeleteAllBreakPoints(dtimeout*1000);
        catch delException
            ThrowError(delException,debugptType,inputFormat);
        end

    case 'ADDRESS',




        debugptAddr=varargin{1};
        if numArgs>1
            debugptType=varargin{2};
        end
        if numArgs>2
            dtimeout=varargin{3};
            CheckTimeOutParam(h,dtimeout);
        end

        if ischar(debugptAddr)
            debugptAddr=hex2dec(debugptAddr);
        end
        debugptAddr=ide_getCompleteAddress(h,debugptAddr);


        if nargin>5,
            DAStudio.error('ERRORHANDLER:autointerface:Breakpoint_InvalidNumOfArgs','address');
        elseif isempty(debugptAddr),
            DAStudio.error('ERRORHANDLER:autointerface:Breakpoint_InvalidAddressArg');
        end


        action=GetActionId(h,debugptType);


        switch(action)
        case 1,
            try
                h.mIdeModule.ClearAllRequests;
                h.mIdeModule.DeleteBreakPointAddr(debugptAddr(1),debugptAddr(2),dtimeout*1000);
            catch delException
                ThrowError(delException,debugptType,inputFormat);
            end
        case 2,
            try
                h.mIdeModule.ClearAllRequests;
                h.mIdeModule.DeleteProbePointAddr(debugptAddr(1),debugptAddr(2),dtimeout*1000);
            catch delException
                ThrowError(delException,debugptType,inputFormat);
            end
        otherwise
            DAStudio.error('ERRORHANDLER:autointerface:Breakpoint_UnsupportedDebugType',debugptType);
        end

    otherwise

        error(message('ERRORHANDLER:autointerface:Breakpoint_InvalidFirstParam'));

    end


    function action=GetActionId(h,debugptType)
        if isempty(debugptType),
            action=1;
        else
            if~ischar(debugptType),
                error(message('ERRORHANDLER:autointerface:Breakpoint_InvalidDebugTypeValue'));
            else
                action=find(strcmpi(debugptType,{'break','probe'}));
                if isempty(action)
                    DAStudio.error('ERRORHANDLER:autointerface:Breakpoint_UnsupportedDebugType',debugptType);
                end
            end
        end


        function ThrowError(delException,debugtype,inputformat)
            if strfind(delException.identifier,'Timeout')
                switch(inputformat)
                case{'FILE-LINE','ADDRESS'}

                otherwise
                    throwAsCaller(delException);
                end
            else
                throwAsCaller(delException);
            end


            function CheckTimeOutParam(h,dtimeout)
                if~isnumeric(dtimeout)||(dtimeout<0),
                    error(message('ERRORHANDLER:autointerface:InvalidTimeoutValue'));
                end



