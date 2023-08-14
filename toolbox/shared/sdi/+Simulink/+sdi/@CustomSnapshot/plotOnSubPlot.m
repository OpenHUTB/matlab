function plotOnSubPlot(this,row,col,signal,turnOn)










    if isa(signal,'Simulink.sdi.Signal')
        signal=signal.ID;
    end
    if nargin<5
        turnOn=true;
    end


    try
        validateattributes(signal,{'numeric'},{'scalar','integer','positive'},'plotOnSubPlot','signal');
        validateattributes(row,{'numeric'},{'scalar','integer','>',0,'<=',8},'plotOnSubPlot','row');
        validateattributes(col,{'numeric'},{'scalar','integer','>',0,'<=',8},'plotOnSubPlot','col');
        validateattributes(turnOn,{'logical'},{'scalar'},'plotOnSubPlot','turnOn');

        if~Simulink.sdi.isValidSignalID(signal)
            error(message('SDI:sdi:InvalidSignalID'));
        end
    catch me
        me.throwAsCaller();
    end


    plotIdx=uint8((col-1)*8+row);


    curPlots=uint8.empty();
    if this.Signals.isKey(signal)
        curPlots=this.Signals(signal);
    end
    bIsPlotted=any(curPlots==plotIdx);


    if turnOn~=bIsPlotted
        if turnOn
            curPlots(end+1)=plotIdx;
        else
            curPlots(curPlots==plotIdx)=[];
        end

        if isempty(curPlots)
            this.Signals.remove(signal);
        else
            this.Signals(signal)=curPlots;
        end


        this.ComparisonSignalID=0;
    end

end
