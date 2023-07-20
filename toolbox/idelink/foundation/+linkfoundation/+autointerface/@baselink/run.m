function run(h,runopt,funcname,timeout)




















































    narginchk(1,4);
    focusstate=linkfoundation.util.getCmdWndFocus;


    if nargin==1,
        runopt='run';
    end


    if nargin==1
        dtimeout=double(get(h(1),'timeout'));
    else
        if strcmp(runopt,'tofunc')
            if nargin==3,dtimeout=GetRunToFuncTimeout(h(1),nargin,funcname);
            elseif nargin==4,dtimeout=GetRunToFuncTimeout(h(1),nargin,funcname,timeout);
            else dtimeout=GetRunToFuncTimeout(h(1),nargin);
            end
        else
            if nargin==2,dtimeout=GetRunTimeout(h(1),nargin);
            else dtimeout=GetRunTimeout(h(1),nargin,funcname);
            end
        end
    end



    numHdls=numel(h);
    for i=1:numHdls


        if isempty(dtimeout)
            dtimeout=h(i).timeout;
        end


        dtimeoutms=dtimeout*1000;

        try
            switch(runopt)
            case 'run'
                h(i).mIdeModule.ClearAllRequests;
                h(i).mIdeModule.Run(dtimeoutms);
            case 'runtohalt'
                h(i).mIdeModule.ClearAllRequests;
                h(i).mIdeModule.RunToHalt(dtimeoutms);
            case 'tohalt'
                h(i).mIdeModule.ClearAllRequests;
                h(i).mIdeModule.ToHalt(dtimeoutms);
            case 'main'
                runto(h,'main','restart',dtimeout);
            case 'tofunc'
                runto(h,funcname,'',dtimeout);
            otherwise
                error(message('ERRORHANDLER:autointerface:InvalidRunOption',runopt));
            end
        catch runException
            DisplayError(i-1,numHdls,runException);
        end
    end

    linkfoundation.util.grabCmdWndFocus(focusstate);


    function DisplayError(procnum,numcc,runException)
        if numcc==1
            rethrow(runException);
        else
            procExcep=MException(runException.identifier,'PROCESSOR %d:\n%s',procnum,runException.message);
            throwAsCaller(procExcep);
        end

        function dtimeout=GetRunTimeout(h,nargs,timeout)
            timeoutParamOrder=3;
            if(nargs<timeoutParamOrder)
                timeout=[];
            end
            dtimeout=linkfoundation.util.checkTimeoutParam(nargs,timeoutParamOrder,timeout,[]);


            function dtimeout=GetRunToFuncTimeout(h,nargs,funcname,timeout)
                if nargs==4
                    if~isnumeric(timeout)||length(timeout)~=1,
                        DAStudio.error('ERRORHANDLER:autointerface:InvalidTimeoutValue');
                    end
                    dtimeout=double(timeout);
                elseif nargs==3
                    dtimeout=double(get(h,'timeout'));
                else
                    error(message('ERRORHANDLER:autointerface:FunctionNameNotSpecified'));
                end
                if isempty(funcname)
                    error(message('ERRORHANDLER:autointerface:FunctionNameNotSpecified'));
                elseif~ischar(funcname)
                    error(message('ERRORHANDLER:autointerface:InvalidFunctionName'));
                end

