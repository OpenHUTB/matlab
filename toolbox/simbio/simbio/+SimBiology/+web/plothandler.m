function out=plothandler(action,varargin)












    oldWarningState=warning(struct('identifier',{'MATLAB:Axes:NegativeLimitsInLogAxis',...
    'MATLAB:Axes:NegativeDataInLogAxis'},...
    'state',{'off','off'}));
    warningStateCleanup=onCleanup(@()warning(oldWarningState));
    [~,out]=evalc('evalPlothandler(action, varargin{:})');

end

function out=evalPlothandler(action,varargin)


    switch(action)
    case 'verifyPercentiles'
        inputs=varargin{1};
        errorMessage=SimBiology.internal.plotting.sbioplot.SBioPercentilePlot.verifyPercentiles(inputs.value);
        if isempty(errorMessage)
            out.isError=false;
            out.message='';
        else
            out.isError=true;
            out.message=errorMessage.getString;
        end
    case{'verifyTimepoints','verifyTimepointBinEdges'}
        inputs=varargin{1};
        errorMessage=SimBiology.internal.plotting.sbioplot.SBioPercentilePlot.verifyTimepoints(inputs.value);
        if isempty(errorMessage)
            out.isError=false;
            out.message='';
        else
            out.isError=true;
            out.message=errorMessage.getString;
        end
    case 'plotAfterRun'
        inputs=varargin{1};


        if iscell(inputs.plots)
            inputs.plots=[inputs.plots{:}];
        end
        for i=numel(inputs.plots):-1:1
            out(i)=delegateAction(action,inputs.plots(i),inputs.programInfo.newdata);
        end
    case{'generateFigure','recreateFigure','export','save','print'}

        inputs=[varargin{:}];
        for i=numel(varargin):-1:1
            out(i)=delegateAction(action,inputs(i));
        end
    otherwise
        out=delegateAction(action,varargin{:});
    end

end

function out=delegateAction(action,varargin)
    inputs=varargin{1};
    plothandler=SimBiology.web.internal.PlotHandler(inputs);

    try
        out=plothandler.(action)(varargin{:});
    catch ex
        out=createErrorOutputStruct(inputs,ex);
    end


    out.action=action;

    delete(plothandler);

end

function out=createErrorOutputStruct(inputs,ex)



    out=struct;
    out.figure=inputs.figure;
    out.axes=[];
    out.definition=[];
    out.warnings=[];
    out.errors=struct('id',ex.identifier,'message',SimBiology.web.internal.errortranslator(ex));
end
