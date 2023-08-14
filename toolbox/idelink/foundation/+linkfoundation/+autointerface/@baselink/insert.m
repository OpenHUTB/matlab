function insert(h,varargin)






























    narginchk(2,5);
    linkfoundation.util.errorIfArray(h);


    dtimeout=h.timeout;
    debugptType='break';


    inputFormat=GetInputFormat(varargin,nargin);

    switch(inputFormat)

    case 'FILE-LINE',

        fileName=varargin{1};
        lineNum=varargin{2};
        if nargin>3
            debugptType=varargin{3};
        end
        if nargin>4
            dtimeout=varargin{4};
            CheckTimeOutParam(h,dtimeout);
        end


        if nargin==2,
            DAStudio.error('ERRORHANDLER:autointerface:Breakpoint_RequiresFilenameAndLineNum');
        elseif~isnumeric(lineNum)||lineNum<0,
            DAStudio.error('ERRORHANDLER:autointerface:Breakpoint_InvalidLineNumber');
        end


        action=GetActionId(h,debugptType);


        [~,fName,fExt]=fileparts(fileName);
        switch(action)
        case 1,
            try
                h.mIdeModule.ClearAllRequests;
                h.mIdeModule.InsertBreakPointFileLine([fName,fExt],lineNum,dtimeout*1000);
            catch insException
                ThrowError(h,insException,debugptType,inputFormat,[fName,fExt],lineNum);
            end
        case 2,
            try
                h.mIdeModule.ClearAllRequests;
                h.mIdeModule.InsertProbePointFileLine([fName,fExt],lineNum,dtimeout*1000);
            catch insException
                ThrowError(h,insException,debugptType,inputFormat,[fName,fExt],lineNum);
            end
        otherwise
            DAStudio.error('ERRORHANDLER:autointerface:Breakpoint_UnsupportedDebugType',debugptType);
        end

    case 'ADDRESS',

        debugptAddr=varargin{1};
        if nargin>2
            debugptType=varargin{2};
        end
        if nargin>3
            dtimeout=varargin{3};
            CheckTimeOutParam(h,dtimeout);
        end

        if ischar(debugptAddr)
            debugptAddr=hex2dec(debugptAddr);
        end
        debugptAddr=ide_getCompleteAddress(h,debugptAddr);


        if nargin==5,
            DAStudio.error('ERRORHANDLER:autointerface:Breakpoint_InvalidNumOfArgs','address');
        elseif isempty(debugptAddr),
            DAStudio.error('ERRORHANDLER:autointerface:Breakpoint_InvalidAddressArg');
        end


        action=GetActionId(h,debugptType);


        switch(action)
        case 1,
            try
                h.mIdeModule.ClearAllRequests;
                h.mIdeModule.InsertBreakPointAddr(debugptAddr(1),debugptAddr(2),dtimeout*1000);
            catch insException
                ThrowError(h,insException,debugptType,inputFormat,debugptAddr);
            end
        case 2,
            try
                h.mIdeModule.ClearAllRequests;
                h.mIdeModule.InsertProbePointAddr(debugptAddr(1),debugptAddr(2),dtimeout*1000);
            catch insException
                ThrowError(h,insException,debugptType,inputFormat,debugptAddr);
            end
        otherwise
            DAStudio.error('ERRORHANDLER:autointerface:Breakpoint_UnsupportedDebugType',debugptType);
        end

    otherwise

        DAStudio.error('ERRORHANDLER:autointerface:Breakpoint_InvalidFirstParam');
    end


    function action=GetActionId(h,debugptType)
        if isempty(debugptType),
            action=1;
        else
            if~ischar(debugptType),
                DAStudio.error('ERRORHANDLER:autointerface:Breakpoint_InvalidDebugTypeValue');
            else
                action=find(strcmpi(debugptType,{'break','probe'}));
                if isempty(action)
                    DAStudio.error('ERRORHANDLER:autointerface:Breakpoint_UnsupportedDebugType',debugptType);
                end
            end
        end


        function ThrowError(h,insException,debugtype,varargin)
            if strfind(insException.identifier,'Timeout')
                try

                    switch(varargin{1})
                    case 'FILE-LINE'
                        remove(h,varargin{2},varargin{3},debugtype,0);
                    case 'ADDRESS'
                        remove(h,varargin{2},debugtype,0);
                    otherwise

                    end
                catch rmException %#ok<NASGU>

                end
                nInsException=MException(insException.identifier,...
                'The %spoint is not inserted. The location you specified may be invalid.',...
                lower(debugtype));
                throwAsCaller(nInsException);
            else
                throwAsCaller(insException);
            end


            function CheckTimeOutParam(h,dtimeout)
                if~isnumeric(dtimeout)||(dtimeout<0),
                    DAStudio.error('ERRORHANDLER:autointerface:InvalidTimeoutValue');
                end


                function inputFormat=GetInputFormat(args,nargs)
                    if(nargs>=3)&&isnumeric(args{2}),
                        inputFormat='FILE-LINE';
                    elseif isnumeric(args{1})||ischar(args{1}),
                        inputFormat='ADDRESS';
                    else
                        inputFormat='';
                    end


