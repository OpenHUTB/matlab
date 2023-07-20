function stop=slbiCallback(varargin)














    stop=0;


    slbiOutputFcns=getappdata(0,'slbiOutputFcns');
    slbiPlotFcns=getappdata(0,'slbiPlotFcns');
    slbiOutputFcnException=getappdata(0,'slbiOutputFcnException');



    if nargin>=2
        if strcmp(varargin{1},'init')
            options=varargin{3};
            if isempty(options.OutputFcn)&&isempty(options.PlotFcns)
                return;
            else
                slbiOutputFcns=options.OutputFcn;
                if~isempty(slbiOutputFcns)&&~iscell(slbiOutputFcns)

                    slbiOutputFcns={slbiOutputFcns};
                end
                slbiPlotFcns=options.PlotFcns;
                if~isempty(slbiPlotFcns)&&~iscell(slbiPlotFcns)

                    slbiPlotFcns={slbiPlotFcns};
                end
            end


            setappdata(0,'slbiFvals',[])

            setappdata(0,'slbiTime',tic)

            setappdata(0,'numfeaspoints',0)

            setappdata(0,'slbiPlotFcns',slbiPlotFcns);

            setappdata(0,'slbiOutputFcns',slbiOutputFcns);

            setappdata(0,'slbiOutputFcnException',[]);

            xOutputfcn=[];
            optimValues=createCBstruct(varargin{2});
        elseif strcmp(varargin{1},'done')
            if isempty(slbiOutputFcns)&&isempty(slbiPlotFcns)
                return;
            end

            if~isempty(slbiOutputFcnException)
                rethrow(slbiOutputFcnException)
            end
            optimValues=varargin{2};





            if~isempty(optimValues.x)&&getappdata(0,'numfeaspoints')~=0
                xOutputfcn=[];
            else
                xOutputfcn=optimValues.x;
                setappdata(0,'numfeaspoints',getappdata(0,'numfeaspoints')+1)
            end
            optimValues=createCBstruct(optimValues);

            rmappdata(0,'slbiFvals')
            rmappdata(0,'slbiTime')
            rmappdata(0,'numfeaspoints')
            rmappdata(0,'slbiPlotFcns')
            rmappdata(0,'slbiOutputFcns')
            rmappdata(0,'slbiOutputFcnException')
        end

        state=varargin{1};

    elseif nargin==1
        state='iter';
        optimValues=varargin{1};



        if isfield(optimValues,'fval')&&isfield(optimValues,'x')
            fvalPrior=getappdata(0,'slbiFvals');
            if ismember(optimValues.fval,fvalPrior)
                return
            else
                fvalPrior(end+1)=optimValues.fval;
                setappdata(0,'slbiFvals',fvalPrior)
            end
        end

        if isfield(optimValues,'x')
            setappdata(0,'numfeaspoints',getappdata(0,'numfeaspoints')+1)
            xOutputfcn=optimValues.x;

        else
            xOutputfcn=[];
        end
        optimValues=createCBstruct(optimValues);
    end

    stopOutput=false;
    stopPlot=false;
    try
        if~isempty(slbiOutputFcns)
            stopOutput=callAllOptimOutputFcns(slbiOutputFcns,xOutputfcn,optimValues,state);
        end
        if~isempty(slbiPlotFcns)
            stopPlot=callAllOptimPlotFcns(slbiPlotFcns,xOutputfcn,optimValues,state);
        end

        stop=double(stopOutput||stopPlot);
    catch ME
        if strcmp(state,'done')||strcmp(state,'init')


            rethrow(ME)
        else


            setappdata(0,'slbiOutputFcnException',ME);

            stop=1.0;
        end
    end

    function optimValues=createCBstruct(useValues)

        optimValues=struct('phase','',...
        'time',toc(getappdata(0,'slbiTime')),...
        'numnodes',0,...
        'numfeaspoints',getappdata(0,'numfeaspoints'),...
        'fval',[],...
        'lowerbound',[],...
        'relativegap',[]);




        fields=intersect(fieldnames(useValues),fieldnames(optimValues));
        for i=1:length(fields)
            optimValues.(fields{i})=useValues.(fields{i});
        end


