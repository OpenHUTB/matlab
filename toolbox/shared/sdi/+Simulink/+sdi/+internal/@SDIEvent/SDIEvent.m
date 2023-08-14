classdef SDIEvent<event.EventData





    properties
        runID;
        signalID;
        runName;
        app;
        appStr;
        type;
        value;
        modelName;
        enumstr;
        oldRunID;
        comparisonSigID;
        oldDiffSigID;
        oldTolSigID;
        oldTolLowerSigID;
        oldTolUpperSigID;
        oldDiffTolLowerSigID;
        oldDiffTolUpperSigID;
        oldCompMinusBaseSigID;
        oldPassSigID;
        oldFailureRegionSigID;
        dbIDs;
        deletedRunIDs;
        signalsIDInfo;
        replot;
        useProgressTracker;
    end

    methods
        function data=SDIEvent(eventType,varargin)
            switch eventType
            case 'runNameChangeEvent'
                data.runID=varargin{1};
                data.runName=varargin{2};
                data.type='runNameChangeEvent';
            case 'treeRunPropertyEvent'
                data.runID=varargin{1};
                data.value=varargin{2};
                data.type='treeRunPropertyChangeEvent';
                data.enumstr=varargin{3};
            case 'signalDeleteEvent'
                data.runID=varargin{1};
                data.signalID=varargin{2};
                if nargin>3
                    data.app=varargin{3};
                end
                data.type='signalDeleteEvent';
            case 'runDeleteEvent'
                data.runID=varargin{1};
                data.app=varargin{2};
                data.type='runDeleteEvent';
            case 'clearSDIEvent'
                data.type='clearSDIEvent';
                if~isempty(varargin)
                    data.app=varargin{1};
                end
            case 'runAddedEvent'
                data.runID=varargin{1};
                if nargin>2
                    data.modelName=varargin{2};
                end
                data.type='runAddedEvent';
            case 'compareRunsEvent'
                arg=varargin{1};
                data.runID=arg;
                if length(arg)>5
                    if~isempty(arg{5})&&isnumeric(arg{5})
                        data.signalID=int32(arg{5});
                    else
                        data.signalID=0;
                    end
                    if~isempty(arg{6})&&isnumeric(arg{6})
                        data.oldRunID=int32(arg{6});
                    else
                        data.oldRunID=0;
                    end
                    if length(arg)>6&&~isempty(arg{7})&&isnumeric(arg{7})
                        data.comparisonSigID=int32(arg{7});
                    else
                        data.comparisonSigID=0;
                    end
                else
                    data.signalID=0;
                    if~isempty(arg{5})&&isnumeric(arg{5})
                        data.oldRunID=int32(arg{5});
                    else
                        data.oldRunID=0;
                    end
                    data.comparisonSigID=0;
                end
                data.type='compareRunsEvent';
            case 'GUICloseEvent'
                data.type='GUICloseEvent';
            case 'propertyChangeEvent'
                data.signalID=varargin{1};
                data.type=varargin{2};
                data.value=varargin{3};
            case 'treeSignalPropertyEvent'
                data.signalID=varargin{1};
                data.value=varargin{2};
                data.enumstr=varargin{3};
            case 'transactionBegin'
                data.type='transactionBegin';
            case 'transactionEnd'
                data.type='transactionEnd';
            case 'signalsInsertedEvent'
                data.runID=varargin{1};
                data.type='signalsInsertedEvent';
                data.useProgressTracker=false;
                if numel(varargin)>1
                    data.useProgressTracker=varargin{2};
                end
            case 'recompareSignalsEvent'
                data.comparisonSigID=varargin{1};
                data.oldDiffSigID=varargin{2};
                data.oldTolSigID=varargin{3};
                data.oldTolLowerSigID=varargin{4};
                data.oldTolUpperSigID=varargin{5};
                data.oldDiffTolLowerSigID=varargin{6};
                data.oldDiffTolUpperSigID=varargin{7};
                data.oldCompMinusBaseSigID=varargin{8};
                data.oldPassSigID=varargin{9};
                data.oldFailureRegionSigID=varargin{10};
                data.type='recompareSignalsEvent';
            case 'runsAndSignalsDeleteEvent'





                data.dbIDs=varargin{1};
                data.appStr=varargin{2};
                data.deletedRunIDs=varargin{3};




                data.signalsIDInfo=varargin{4};
            case 'preDeleteEvent'
                data.type=varargin{1};
                if strcmp(data.type,'signal')
                    data.signalID=varargin{2};
                else
                    data.runID=varargin{2};
                end
            case 'runMetaDataUpdated'
                data.modelName=varargin{1};
            case 'loadSaveEvent'
                data.replot=true;
                data.app='sdi';
                if nargin>0
                    data.replot=varargin{1};
                end
                if nargin>1
                    data.app=varargin{2};
                end
            end
        end
    end
end
