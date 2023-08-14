function pfile=reload(h,timeout)

















    narginchk(1,2);


    timeoutParamOrder=2;
    if(nargin<timeoutParamOrder)
        timeout=[];
    end
    dtimeout=linkfoundation.util.checkTimeoutParam(nargin,timeoutParamOrder,timeout,[]);



    pfile={};
    for k=1:length(h)
        pfile{k}=ReloadProgram(h(k),dtimeout);
    end


    if length(pfile)==1,
        pfile=pfile{1};
    end


    function pfile=ReloadProgram(h,dtimeout)

        pfile=h.mIdeModule.GetLastLoadedProgram();

        if isempty(pfile),

            warning(message('ERRORHANDLER:autointerface:NoProgramPreviouslyLoaded'));
        else

            if isempty(dtimeout)
                dtimeout=double(h.timeout);
            end


            h.load(pfile,dtimeout);
        end

