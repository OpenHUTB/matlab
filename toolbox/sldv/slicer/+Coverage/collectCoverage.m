function[cvd,xFinal]=collectCoverage(mdl,varargin)















    cvd=[];
    xFinal=[];
    getCvd=true;

    if nargin>2

        tstart=varargin{1};
        tstop=varargin{2};
        if nargin>3
            getCvd=varargin{3};
        end
    elseif nargin==2
        tstart=0;
        tstop=varargin{1};
    else
        error('CollectCoverage:WrongInput',getString(message('Sldv:ModelSlicer:Coverage:Usage')));
    end
    if tstart==0
        hasStart=false;
    else
        hasStart=true;
    end

    modelH=get_param(mdl,'Handle');
    msObj=modelslicerprivate('slicerMapper','get',modelH);

    if(~isempty(msObj)&&~isempty(msObj.simHandler)&&...
        isa(msObj.simHandler,'Coverage.SimulationHandler'))
        simHandler=msObj.simHandler;
    else
        simHandler=ModelSlicer.getSimHandlerForSlicer(modelH);
    end

    try
        if hasStart
            simStateName='simState';
            opt=struct('SaveFinalState','on',...
            'SaveCompleteFinalSimState','on',...
            'FinalStateName',simStateName,...
            'StopTime',num2str(tstart,'%15.15g'));
            simOut=sim(mdl,opt);
            xFinal=simOut.(simStateName);
        end

        if getCvd
            in=Simulink.SimulationInput(get_param(mdl,'name'));


            if~simHandler.isInitialized
                in=in.setModelParameter('SaveTime','on',...
                'LimitDataPoints','off');
            end
            in=in.setModelParameter('StopTime',num2str(tstop,'%15.15g'));
            if hasStart
                in=in.setInitialState(xFinal);
            end
            simHandler.run(false,in);
            cvd=simHandler.getCoverage();
        end
    catch mex
        rethrow(mex);
    end
    if hasStart&&exist('simStateName','var')
        evalin('base',['clear ',simStateName]);
    end

end
