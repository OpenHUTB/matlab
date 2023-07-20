function[advisor,flusher]=createBenchmarkingAdvisor(varargin)


    options=processOptions(varargin);

    streaming=nargout<2;
    flushFun=[];
    allData=[];

    switch options.SinkType
    case 'web'
        if~streaming
            warning('Web mode only supports streaming results');
        end
        webOpts=weboptions('RequestMethod','post','MediaType','application/json');
        sinkFun=@(d)webwrite(options.SinkDest,d,webOpts);
    case 'file'
        assert(~streaming,'Logging to file does not support streaming');
        sinkFun=@appendData;
        flushFun=@()save(options.SinkDest,allData);
    case 'var'
        if streaming
            sinkFun=@streamToBaseWorkspace;
        else
            sinkFun=@appendData;
            flushFun=@()assignin('base',options.SinkDest,allData);
        end
    otherwise
        sinkFun=@()false;
    end

    altFuncs=options.Alternates;
    altFuncStrs=cellfun(@func2str,altFuncs,'UniformOutput',false);
    resultFields=arrayfun(@(v)['x',num2str(v)],1:numel(altFuncs)+1,...
    'UniformOutput',false);
    logFunc=options.LogFunction;

    advisor=@advisorImpl;

    if~streaming&&~isempty(flushFun)
        flusher=onCleanup(flushFun);
    else
        flusher=[];
    end



    function varargout=advisorImpl(adviseeName,origFunc,outputCount,varargin)
        varargout={};
        dataHolder.functions=[func2str(origFunc),altFuncStrs];
        dataHolder.times=cell2struct(cell(1,numel(resultFields)),resultFields,2);
        if~isempty(logFunc)
            dataHolder.data=dataHolder.times;
        end
        if isa(options.Context,'function_handle')
            context=options.Context(adviseeName,varargin);
        else
            context=options.Context;
        end
        if~isempty(context)
            dataHolder.context=context;
        end

        if options.SingleUse&&numel(varargin)>=1
            cleanup=onCleanup(@()varargin{1}.unadvise(adviseeName));
        end

        for iteration=1:options.Iterations
            ordinal=1;
            if~options.ReverseOrder
                invokeWithTiming(origFunc,true);
            end
            for j=1:numel(altFuncs)
                invokeWithTiming(altFuncs{j},false);
            end
            if options.ReverseOrder
                invokeWithTiming(origFunc,true);
            end
            pause(0.5);
        end

        sinkFun(dataHolder);

        function invokeWithTiming(func,actual)
            outVals=cell(1,outputCount);
            me=[];
            start=tic;
            try
                if outputCount>0
                    [outVals{1:end}]=func(varargin{:});
                else
                    func(varargin{:});
                end
                elapsed=toc(start);
            catch me
                elapsed=toc(start);%#ok<NASGU>
                elapsed=-1;
            end

            subField=resultFields{ordinal};
            dataHolder.times.(subField)(iteration)=elapsed;
            if~isempty(logFunc)
                try
                    dataHolder.data.(subField)(iteration)=logFunc(iteration,ordinal,varargin,outVals);
                catch
                end
            end
            ordinal=ordinal+1;

            if actual
                if isempty(me)
                    varargout=outVals;
                else
                    rethrow(me);
                end
            end
        end
    end

    function appendData(singleData)
        allData(end+1)=singleData;
    end

    function streamToBaseWorkspace(data)
        overwrite=~evalin('base',sprintf('exist(''%s'',''var'')',options.SinkDest));
        if~overwrite
            tempName='x_temp_var_12345';
            try
                assignin('base',tempName,{data});
                evalin('base',sprintf('%s = [%s %s];',options.SinkDest,options.SinkDest,tempName));
            catch me %#ok<NASGU>
                overwrite=true;
            end
            evalin('base',sprintf('clear %s;',tempName));
        end
        if overwrite
            assignin('base',options.SinkDest,{data});
        end
    end
end



function options=processOptions(args)
    ip=inputParser();
    ip.addParameter('SinkType','var',@(v)~isempty(validatestring(v,{'var','web','file','none'})));
    ip.addParameter('SinkDest',[],@(v)validateattributes(v,{'char'},{'scalartext'}));
    ip.addParameter('Iterations',1,@(v)validateattributes(v,{'numeric'},{'scalar','>',0}));
    ip.addParameter('Context','');
    ip.addParameter('LogFunction',[],@(v)isa(v,'function_handle')&&nargin(v)==4&&nargout(v)==1);
    ip.addParameter('Alternates',{},@(v)isa(v,'function_handle')||...
    all(cellfun(@(vv)isa(vv,'function_handle'),v)));
    ip.addParameter('SingleUse',false,@(v)validateattributes(v,{'logical'},{'scalar'}));
    ip.addParameter('ReverseOrder',false,@islogical);
    ip.parse(args{:});
    options=ip.Results;

    switch options.SinkType
    case 'web'
        assert(~isempty(options.SinkDest),'URL for RESTful web service required');
    case 'var'
        options.SinkDest='loggedResults';
    end

    if~iscell(options.Alternates)
        options.Alternates={options.Alternates};
    end
end