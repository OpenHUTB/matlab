function deleteAllRuns(this,varargin)









    this.safeTransaction(@helperDeleteAllRuns,this,varargin{:});
end

function helperDeleteAllRuns(this,varargin)
    Simulink.sdi.internal.flushStreamingBackend();
    if~isempty(varargin)
        appName=varargin{1};
    else
        appName='';
    end
    signalIDsToClear=this.getAllCheckedSignals(appName,false);


    if~isempty(varargin)&&(strcmpi(varargin{1},'SDIComparison')||strcmpi(varargin{1},'STMComparison'))
        this.DiffRunResult=Simulink.sdi.DiffRunResult(0,this);
    end

    if length(varargin)>1


        this.sigRepository.deleteAllRuns(varargin{1});
    else
        this.sigRepository.deleteAllRuns(varargin{:});
    end

    this.updateFlag=int32(0);
    this.engineViewsData=[];

    this.runNumByRunID=Simulink.sdi.Map(int32(0),int32(0));

    if~isempty(signalIDsToClear)

        if~(length(signalIDsToClear)==1&&signalIDsToClear==0)
            Simulink.sdi.clearSignalsFromCanvas(signalIDsToClear);
        end
    end

    if nargin>2
        if~strcmpi(varargin{2},'suppressNotification')
            notify(this,'clearSDIEvent',...
            Simulink.sdi.internal.SDIEvent('clearSDIEvent',varargin{1}));
        end
    else
        notify(this,'clearSDIEvent',...
        Simulink.sdi.internal.SDIEvent('clearSDIEvent',varargin{:}));
    end
end
