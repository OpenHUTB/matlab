function varargout=util_check_timer(varargin)



    if nargin>2
        error(message('Sldv:util_check_timer:InvalidNumInputs'));
    end

    if nargin==0
        varargout{1}=double(slavteng('feature','TimerOptimization'));
        varargout{2}=false;
    else
        arg=varargin{1};
        if~isstruct(arg)&&~ischar(arg)&&(islogical(arg)||arg==1||arg==0||arg==2)
            if arg==2
                varargout{1}=double(slavteng('feature','TimerOptimization',1));
                varargout{1}=double(slavteng('feature','TimerPredicates','On'));
            else
                varargout{1}=double(slavteng('feature','TimerOptimization',arg));
            end
            varargout{2}=false;
        else
            if nargin<2
                argDisplay=false;
            else
                argDisplay=varargin{2};
            end
            if~(islogical(argDisplay)||argDisplay==1||argDisplay==0)
                error(message('Sldv:util_check_timer:InvalidBoolArg'));
            end
            sldvData=[];
            fromModel=false;
            [modelH,errStr]=Sldv.utils.getObjH(arg);
            if~isempty(errStr)||...
                isempty(modelH)||...
                strcmp(get_param(bdroot(modelH),'BlockDiagramType'),'library')
                if ischar(arg)
                    try
                        sldvData=load(arg);
                        dataFields=fields(sldvData);
                        if length(dataFields)==1
                            sldvData=sldvData.(dataFields{1});
                        end
                    catch Mex %#ok<NASGU>
                        sldvData=[];
                    end
                elseif isstruct(arg)
                    sldvData=arg;
                end
                if~isstruct(sldvData)||...
                    ~isfield(sldvData,'AnalysisInformation')
                    error(message('Sldv:util_check_timer:InvalidsldvData'));
                end
            else
                argDisplay=true;
                fromModel=true;

                opts=sldvoptions;
                opts.Mode='TestGeneration';

                modelH=bdroot(modelH);
                origDirtyFlag=get_param(modelH,'Dirty');
                set_param(modelH,'Dirty','off');

                modelName=getfullname(modelH);%#ok<NASGU>
                logstr=getString(message('Sldv:util_check_timer:DetectingTimerPatternsOptimized'));
                disp(logstr);
                try
                    [~,status,~,sldvData]=...
                    evalc('sldvprivate(''sldvCompatibility'',modelName,[],opts,false,[])');
                catch Mex %#ok<NASGU>
                    sldvData=[];
                    status=false;
                end

                set_param(modelH,'Dirty',origDirtyFlag);

                if~status||isempty(sldvData)
                    error(message('Sldv:util_check_timer:UnableToRecog'));
                end
            end

            if~isfield(sldvData.AnalysisInformation,'TimerOptimizations')
                if fromModel
                    error(message('Sldv:util_check_timer:UnableToRecog'));
                else
                    varargout{1}=-1;
                    varargout{2}=false;
                end
            else
                displayTimers=logical(argDisplay);
                timerOptimizations=sldvData.AnalysisInformation.TimerOptimizations;
                statustimerOptimizations=~isempty(timerOptimizations);
                varargout{1}=statustimerOptimizations;
                if~fromModel
                    varargout{2}=false;
                else
                    varargout{2}=true;
                    if statustimerOptimizations
                        logstr=getString(message('Sldv:util_check_timer:DetectedTimerPatternsSuccessfully'));
                    else
                        logstr=getString(message('Sldv:util_check_timer:ModelDoesNotInclude'));
                    end
                    disp(logstr);
                end
                if displayTimers&&statustimerOptimizations
                    modelinfo=sldvData.ModelInformation;
                    if~bdIsLoaded(modelinfo.Name)
                        try
                            load_system(modelinfo.Name);
                        catch Mex
                            error(message('Sldv:util_check_timer:NoModel',modelinfo.Name));
                        end
                    end
                    modelH=get_param(modelinfo.Name,'Handle');
                    open_system(modelH);
                    sldvshareprivate('avtcgirunsupcollect','clear');
                    for idx=1:length(timerOptimizations)
                        timerOpt=timerOptimizations(idx);
                        msg=getString(message('Sldv:util_check_timer:ModelItemsInvolvedIn',idx));
                        modelitems='';
                        for jdx=1:length(timerOpt.designSid)



                            if isempty(timerOpt.replacementSid{jdx})
                                failedToFind=false;
                                try
                                    [blockH,sfId,emlStart,emlEnd]=sldvprivate('util_sid',timerOpt.designSid{jdx},true);
                                catch Mex %#ok<NASGU>
                                    blockH=-1;
                                    sfId=0;
                                    failedToFind=true;
                                end
                                if~failedToFind&&blockH~=modelH
                                    if sfId>0
                                        [sourceFullName,sourceName]=getsfname(sfId);
                                        if~isempty(sourceFullName)
                                            if isempty(sourceName)||...
                                                strcmp(sourceFullName,sourceName)
                                                if emlStart~=0&&emlEnd~=0
                                                    modelitems=...
                                                    sprintf('%s ''%s''(#%d.%d.%d)',modelitems,...
                                                    sourceFullName,...
                                                    sfId,emlStart,emlEnd);
                                                else
                                                    modelitems=...
                                                    sprintf('%s ''%s''(#%d)',modelitems,...
                                                    sourceFullName,...
                                                    sfId);
                                                end
                                            else
                                                modelitems=...
                                                sprintf('%s ''%s''',modelitems,...
                                                sourceFullName);
                                            end
                                        else
                                            failedToFind=true;
                                        end
                                    elseif blockH~=-1
                                        modelitems=...
                                        sprintf('%s ''%s''',modelitems,getfullname(blockH));
                                    end
                                    if~failedToFind&&jdx~=length(timerOpt.designSid)
                                        modelitems=sprintf('%s,',modelitems);
                                    end
                                end
                            end
                        end
                        if isempty(modelitems)
                            modelitems=getString(message('Sldv:util_check_timer:UnableDisplayRecognizedTimer'));
                        end
                        msg=sprintf('%s %s.',msg,modelitems);
                        sldvshareprivate('avtcgirunsupcollect','push',modelH,'sldv_warning',msg,...
                        'Sldv:util_check_timer:modelitem');
                    end
                    msg=getString(message('Sldv:util_check_timer:ThereAre0numberintegerTimer',length(timerOptimizations),getfullname(modelH)));
                    sldvshareprivate('avtcgirunsupcollect','push',modelH,'sldv_warning',msg,...
                    'Sldv:util_check_timer:summary');
                    sldvshareprivate('avtcgirunsupdialog',modelH,true);
                end
            end
        end
    end
end

function[sourceFullName,sourceName]=getsfname(id)
    sourceFullName='';
    sourceName='';

    if sf('Private','is_eml_script',id)
        sourceName=sf('get',id,'script.filePath');
        sourceFullName=sourceName;
        return;
    end

    idIsa=sf('get',id,'.isa');

    if isempty(idIsa)
        return;
    end

    MACHINE=sf('get','default','machine.isa');
    CHART=sf('get','default','chart.isa');
    STATE=sf('get','default','state.isa');
    JUNCTION=sf('get','default','junction.isa');
    TRANSITION=sf('get','default','transition.isa');
    EVENT=sf('get','default','event.isa');
    DATA=sf('get','default','data.isa');
    TARGET=sf('get','default','target.isa');
    SCRIPT=sf('get','default','script.isa');

    chartId=[];
    isDE=false;

    switch idIsa
    case{MACHINE,TARGET,SCRIPT}

    case CHART
        chartId=id;
    case{STATE,TRANSITION,JUNCTION}
        chartId=sf('get',id,'.chart');
    case{EVENT,DATA}
        isDE=true;
        parentId=sf('ParentOf',id);
        switch sf('get',parentId,'.isa'),
        case STATE
            chartId=sf('get',parentId,'.chart');
        case CHART
            chartId=parentId;
        end
    end

    if sf('Private','is_eml_chart',chartId)
        if~isDE

            id=chartId;
            idIsa=CHART;
        end
    elseif sf('Private','is_truth_table_chart',chartId)
        if~isDE

            id=chartId;
            idIsa=CHART;
        end
    end

    switch idIsa,
    case{MACHINE,CHART,STATE,EVENT,DATA,TARGET},
        sourceFullName=sf('FullNameOf',id,'.');
    case JUNCTION,
        sourceName=['Junct(#',int2str(id),')'];
        parentId=sf('ParentOf',id);
        sourceFullName=[sf('FullNameOf',parentId,'.'),'.',sourceName];
    case TRANSITION,
        sourceName=['Trans(#',int2str(id),')'];
        parentId=sf('ParentOf',id);
        sourceFullName=[sf('FullNameOf',parentId,'.'),'.',sourceName];
    end
end
