function out=modelsimulationhandler(action,varargin)











    out={action};

    switch action
    case 'configureColor'
        configureColor(varargin{:});
    case 'exportPlots'
        exportPlots([varargin{:}]);
    case 'generateFigure'
        out=generateFigure([varargin{:}]);
    case 'moveStatesToPlot'
        out=moveStatesToPlot(varargin{:});
    case 'showLine'
        showLine(varargin{:});
    case 'removeLine'
        removeLine(varargin{:});
    case 'runSimulation'
        out=runSimulation(varargin{:});
    case 'updateScale'
        updateScale(varargin{:});
    end

end

function out=generateFigure(inputs)

    template=struct('plotID',-1,'handle',-1,'embeddedFigurePacket',[]);
    plotID=[inputs.plotID];
    out=repmat(template,1,numel(plotID));

    for i=1:numel(plotID)
        f=matlab.ui.internal.embeddedfigure;
        set(f,'Color','w','HandleVisibility','off','IntegerHandle','off','AutoResizeChildren','on','Visible','on');

        pos=get(f,'Position');
        set(f,'Position',[pos(1:3),200]);

        settings.Parent=f;
        settings.Visible='on';
        settings.Box='on';
        settings.Color='white';
        settings.PickableParts='all';
        settings.xgrid='on';
        settings.ygrid='on';
        settings.NextPlot='replacechildren';
        settings.LooseInset=[0.089,0.012,0.018,0.012];
        settings.TickLabelInterpreter='none';
        ax=axes(settings);%#ok<LAXES>

        updateAxesScale(ax,inputs(i).plotScale)
        axtoolbar(ax,{'zoomin','zoomout','pan','restoreview'});


        disableDefaultInteractivity(ax);

        out(i).plotID=plotID(i);
        out(i).handle=double(f);
        out(i).embeddedFigurePacket=matlab.ui.internal.FigureServices.getEmbeddedFigurePacket(f);
    end

end

function out=runSimulation(input)


    out.msg='';


    model=SimBiology.web.modelhandler('getModelFromSessionID',input.modelSessionID);





    transaction=SimBiology.Transaction.create(model);%#ok<NASGU>


    figures=input.figures;
    states=[];
    observables=[];
    for i=1:numel(figures)
        if~isempty(figures(i).states)
            states=smartConcat(states,[figures(i).states.sessionID]);
        end

        if~isempty(figures(i).observables)
            observables=smartConcat(observables,[figures(i).observables.sessionID]);
        end
    end



    allObservables=model.Observables;
    allObservablesActive=get(allObservables,{'Active'});
    set(allObservables,'Active',false);


    observables=unique(observables);
    obsNeeded=[];
    for i=1:numel(observables)
        obs=sbioselect(model.Observables,'SessionID',observables(i));
        [states,obsNeeded]=getStatesForObservable(states,obsNeeded,obs);
        set(obs,'Active',true);
    end



    set(obsNeeded,'Active',true);


    states=unique(states);
    objs=cell(1,numel(states));
    for i=1:numel(states)
        objs{i}=sbioselect(model,'SessionID',states(i));
    end
    objs=[objs{:}];


    cs=getconfigset(model,'default');
    logAllStates=~cs.RuntimeOptions.StatesToLogSet;
    statesLogged=cs.RuntimeOptions.StatesToLog;
    cs.RuntimeOptions.StatesToLog=objs;


    statesToLog=cs.RuntimeOptions.StatesToLog;
    allSessionIDs=get(statesToLog,{'SessionID'});
    allSessionIDs=[allSessionIDs{:}];
    scopeCleanup=onCleanup(@()cleanupScope(input,model,cs,logAllStates,statesLogged,allObservables,allObservablesActive));


    variants=cell(1,numel(input.variants));
    for i=1:numel(input.variants)
        variants{i}=sbioselect(model,'Type','variant','SessionID',input.variants(i));
    end
    variants=[variants{:}];


    unitConversion=cs.CompileOptions.UnitConversion;
    xlabel='';
    if unitConversion
        xlabel=sprintf('Time (%s)',cs.TimeUnits);
    end


    for i=1:numel(figures)
        handle=figures(i).handle;
        states=[];
        colors={};
        names={};
        use={};
        units={};

        if~isempty(figures(i).states)
            states=[figures(i).states.sessionID];
            colors={figures(i).states.color};
            names={figures(i).states.name};
            use={figures(i).states.use};
            units=unique({figures(i).states.units});
        end

        [~,~,indices]=intersect(states,allSessionIDs,'stable');

        for j=1:numel(colors)
            colors{j}=SimBiology.internal.plotting.sbioplot.SBioPlotObject.convertHexToRGB(colors{j});%#ok<AGROW>
        end

        info.indices=indices;
        info.states=states;
        info.colors=colors;
        info.names=names;
        info.use=use;
        info.ylabel='';
        info.xlabel=xlabel;

        if numel(units)==1
            info.ylabel=units{1};
        end

        set(handle,'UserData',info);
    end

    SimBiology.internal.setLoggerCallback(@(state,time,data)runLogger(state,time,data,input));


    runCode(model,cs,variants,figures);

end

function runCode(model,cs,variants,figures)%#ok<INUSL>


    logfile=[SimBiology.web.internal.desktopTempname(),'.xml'];
    matlab.internal.diagnostic.log.open(logfile);
    fileCleanup=onCleanup(@()deleteFile(logfile));
    runErrored=false;

    try
        evalc('data = sbiosimulate(model, cs, variants);');


        plotObservables(model,data,figures);
    catch ex
        runErrored=true;


        simbioErrors=sbiolasterror;


        if~strcmp(ex.identifier,'SimBiology:StackedError')&&(isempty(simbioErrors)||~any(strcmp(ex.identifier,{simbioErrors.MessageID})))
            errorMessage=SimBiology.web.internal.errortranslator(ex);

            msgStruct=struct('component',[],...
            'source','lasterr',...
            'message',errorMessage,...
            'messageID',ex.identifier,...
            'isError',true,...
            'force',true);
            SimBiology.web.eventhandler('message',msgStruct);
        end
    end

    handleMessagesAfterRun(logfile);


    evt.type='plotRunCompleted';
    evt.runErrored=runErrored;
    message.publish('/SimBiology/modelSimulation',evt);

end

function plotObservables(model,data,figures)

    for i=1:numel(figures)
        handle=figures(i).handle;
        ax=findobj(handle,'Type','axes');
        observables=figures(i).observables;
        hold(ax,'on');

        for j=1:numel(observables)
            obj=sbioselect(model,'Type','observable','SessionID',observables(j).sessionID);
            values=selectbyname(data,obj.Name);
            [time,ydata]=getdata(values);
            color=SimBiology.internal.plotting.sbioplot.SBioPlotObject.convertHexToRGB(observables(j).color);
            plot(ax,time,ydata,'Color',color,'DisplayName',observables(j).name,'UserData',observables(j).sessionID,'Visible',observables(j).use,'LineWidth',1.5);
        end

        hold(ax,'off');
    end

end

function handleMessagesAfterRun(logfile)

    if exist(logfile,'file')

        matlab.internal.diagnostic.log.close(logfile);


        warningLog=matlab.internal.diagnostic.log.load(logfile);


        simbioWarnings=sbiolastwarning;


        template=struct('component',[],'source',-1,'message','','messageID','','isError',false,'force',true);
        msgStruct=repmat(template,1,numel(warningLog));
        count=1;

        for i=1:numel(warningLog)

            identifier=warningLog(i).identifier;
            message=warningLog(i).message;

            if~isempty(message)&&~warningLog(i).wasDisabled
                if strcmp(identifier,'MATLAB:Completion:NoEntryPoints')

                elseif~isempty(simbioWarnings)&&any(strcmp(identifier,{simbioWarnings.MessageID}))

                else
                    msgStruct(count).message=message;
                    msgStruct(count).messageID=identifier;
                    count=count+1;
                end
            end
        end

        if count>1
            SimBiology.web.eventhandler('message',msgStruct(1:count-1));
        end
    end

end

function keepCalling=runLogger(state,time,data,input)

    keepCalling=true;
    time=time';
    data=data';

    if isempty(data)&&~strcmp(state,'begin')
        return;
    end

    for i=1:numel(input.figures)
        handle=input.figures(i).handle;
        info=get(handle,'UserData');
        indices=info.indices;

        if strcmp(state,'begin')
            ax=findobj(handle,'Type','axes');
            lines=ax.Children;
            ylabel(ax,info.ylabel);
            xlabel(ax,info.xlabel);

            if~isempty(lines)
                delete(lines);
            end
        elseif strcmp(state,'iter')

            if rem(length(time),100)==0
                dataToPlot=data(:,indices);
                plotData(handle,time,dataToPlot,info);
            end
        elseif any(strcmp(state,{'end','interrupt'}))
            dataToPlot=data(:,indices);
            plotData(handle,time,dataToPlot,info);
        elseif strcmp(state,'error')
            dataToPlot=data(:,indices);
            plotData(handle,time,dataToPlot,info);
        end
    end

end

function plotData(fig,time1,data1,info)

    time(:)=time1;
    data(:,:)=data1;

    ax=findobj(fig,'Type','axes');
    lines=ax.Children;
    nextplot=get(ax,'NextPlot');

    if isempty(lines)
        set(ax,'NextPlot','add');
        for i=1:size(data,2)
            plot(ax,time,data(:,i),'Color',info.colors{i},'DisplayName',info.names{i},'UserData',info.states(i),'Visible',info.use{i},'LineWidth',1.5);
        end
        set(ax,'NextPlot',nextplot);
    else
        for i=1:length(info.states)
            hLine=findobj(lines,'UserData',info.states(i));
            set(hLine,'XData',time,'YData',data(:,i));
        end
    end

    drawnow limitrate;

end

function cleanupScope(input,model,cs,logAllStates,statesLogged,allObservables,allObservablesActive)





    transaction=SimBiology.Transaction.create(model);%#ok<NASGU>


    SimBiology.internal.setLoggerCallback([]);


    for i=1:numel(input.figures)
        set(input.figures(i).handle,'UserData',[]);
    end


    if logAllStates
        cs.RunTimeOptions.StatesToLog='all';
    else
        cs.RunTimeOptions.StatesToLog=statesLogged;
    end

    set(allObservables,{'Active'},allObservablesActive);

end

function showLine(input)

    fig=input.handle;
    ax=findobj(fig,'Type','axes');
    hLine=findobj(ax,'Type','line','UserData',input.sessionID);
    if~isempty(hLine)
        set(hLine,'Visible',input.value);
    end

end

function configureColor(input)

    fig=input.handle;
    ax=findobj(fig,'Type','axes');
    hLine=findobj(ax,'Type','line','UserData',input.sessionID);
    if~isempty(hLine)
        value=SimBiology.internal.plotting.sbioplot.SBioPlotObject.convertHexToRGB(input.value);
        set(hLine,'Color',value);
    end

end

function removeLine(input)

    fig=input.handle;
    ax=findobj(fig,'Type','axes');

    for i=1:numel(input.sessionID)
        hLine=findobj(ax,'Type','line','UserData',input.sessionID(i));
        if~isempty(hLine)
            delete(hLine);
        end
    end

    for i=1:numel(input.itemsToUpdate)
        next=input.itemsToUpdate(i);
        use=next.use;
        color=SimBiology.internal.plotting.sbioplot.SBioPlotObject.convertHexToRGB(next.color);
        hLine=findobj(ax,'Type','line','UserData',next.sessionID);
        if~isempty(hLine)
            set(hLine,'Visible',use,'Color',color);
        end
    end

end

function out=moveStatesToPlot(input)

    out.sessionID=[];
    out.figure=input.newHandle;

    if isempty(input.rows)
        return;
    end

    newFigure=input.newHandle;
    newAxes=findobj(newFigure,'Type','axes');

    oldFigure=input.rows(1).handle;
    oldAxes=findobj(oldFigure,'Type','axes');

    for i=1:numel(input.rows)
        next=input.rows(i);
        hLine=findobj(oldAxes,'Type','line','UserData',next.sessionID);
        if~isempty(hLine)
            out.sessionID=smartConcat(out.sessionID,next.sessionID);
            copyobj(hLine(1),newAxes);
            delete(hLine);
        end

        hLine=findobj(newAxes,'Type','line','UserData',next.sessionID);
        color=SimBiology.internal.plotting.sbioplot.SBioPlotObject.convertHexToRGB(next.legendColor);
        if~isempty(hLine)
            set(hLine,'Color',color);
        end
    end

end

function exportPlots(input)


    newFig=figure('Visible','off');
    numAxes=numel(input);

    for i=1:numel(input)
        newAxes=subplot(numAxes,1,i);

        originalFig=input(i).handle;
        originalAxes=findobj(originalFig,'Type','axes');


        lines=originalAxes.Children;
        copyobj(lines,newAxes);


        settings.Visible='on';
        settings.Box='on';
        settings.xgrid='on';
        settings.ygrid='on';
        settings.NextPlot='replacechildren';
        settings.TickLabelInterpreter='none';
        settings.XScale=originalAxes.XScale;
        settings.YScale=originalAxes.YScale;
        settings.XLim=originalAxes.XLim;
        settings.YLim=originalAxes.YLim;
        set(newAxes,settings);


        x=get(originalAxes,'XLabel');
        y=get(originalAxes,'YLabel');
        xlabel(newAxes,x.String,'Interpreter','none');
        ylabel(newAxes,y.String,'Interpreter','none');
        title(newAxes,input(i).name,'Interpreter','none');


        hleg=legend(newAxes,flipud(lines));
        set(hleg,'Interpreter','none');
    end

    set(newFig,'Visible','on');

end

function updateScale(input)

    handle=input.handle;
    scale=input.value;
    ax=findobj(handle,'Type','axes');
    updateAxesScale(ax,scale);

end

function updateAxesScale(ax,scale)

    switch(scale)
    case 'plot'
        set(ax,'XScale','linear','YScale','linear');
    case 'semilogx'
        set(ax,'XScale','log','YScale','linear');
    case 'semilogy'
        set(ax,'XScale','linear','YScale','log');
    case 'loglog'
        set(ax,'XScale','log','YScale','log');
    end

end

function[states,obsNeeded]=getStatesForObservable(states,obsNeeded,obs)

    tokens=parseexpression(obs);
    for j=1:numel(tokens)
        next=resolveobject(obs,tokens{j});


        if~isempty(next)&&~isa(next,'SimBiology.Observable')
            states=smartConcat(states,next.SessionID);
        end



        if isa(next,'SimBiology.Observable')
            obsNeeded=smartConcat(obsNeeded,next);
            [states,obsNeeded]=getStatesForObservable(states,obsNeeded,next);
        end
    end

end

function out=smartConcat(var1,var2)


    if size(var1,1)==1
        var1=var1';
    end

    if size(var2,1)==1
        var2=var2';
    end

    out=vertcat(var1,var2);

end

function deleteFile(name)

    oldWarnState=warning('off','MATLAB:DELETE:Permission');
    cleanup=onCleanup(@()warning(oldWarnState));

    if exist(name,'file')
        oldState=recycle;
        recycle('off');
        delete(name)
        recycle(oldState);
    end
end
