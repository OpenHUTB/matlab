function[harmonicOrder,harmonicMagnitude,fundamentalFrequency,tInterval]=getSimscapeLoggingNodeHarmonics(loggingNode,valueIdx,tOfInterest,nPeriodOfInterest,offsetOfInterest,nHarmonics)



















    if~isa(loggingNode,'simscape.logging.Node')...
        ||~isa(loggingNode.series,'simscape.logging.Series')...
        ||loggingNode.series.points==0
        pm_error('physmod:ee:library:InvalidSimscapeLoggingNodeSeries','loggingNode');
    end


    tData=loggingNode.series.time;
    yData=loggingNode.series.values;


    if~exist('valueIdx','var')||isempty(valueIdx)
        valueIdx=1;
    else
        validateattributes(valueIdx,{'numeric'},{'real','integer'},mfilename,'valueIdx',2);
        if~isfloat(valueIdx)
            valueIdx=double(valueIdx);
        end
    end
    yData=yData(:,valueIdx);

    if~exist('tOfInterest','var')||isempty(tOfInterest)
        tOfInterest=tData(end);
    else
        validateattributes(tOfInterest,{'numeric'},{'real'},mfilename,'tOfInterest',3);
        if~isfloat(tOfInterest)
            tOfInterest=double(tOfInterest);
        end
    end

    if~exist('nPeriodOfInterest','var')||isempty(nPeriodOfInterest)
        nPeriodOfInterest=12;
    else
        validateattributes(nPeriodOfInterest,{'numeric'},{'real','integer'},mfilename,'nPeriodOfInterest',4);
        if~isfloat(nPeriodOfInterest)
            nPeriodOfInterest=double(nPeriodOfInterest);
        end
    end

    if~exist('offsetOfInterest','var')||isempty(offsetOfInterest)
        offsetOfInterest=0;
    else
        validateattributes(offsetOfInterest,{'numeric'},{'real'},mfilename,'offsetOfInterest',5);
        if~isfloat(offsetOfInterest)
            offsetOfInterest=double(offsetOfInterest);
        end
    end

    if~exist('nHarmonics','var')||isempty(nHarmonics)
        nHarmonics=30;
    else
        validateattributes(nHarmonics,{'numeric'},{'real','integer'},mfilename,'nHarmonics',6);
        if~isfloat(nHarmonics)
            nHarmonics=double(nHarmonics);
        end
    end

    [tData,yData,fundamentalFrequency,tInterval]=ee.internal.signal.getDataOfInterest(tData,yData,tOfInterest,nPeriodOfInterest,offsetOfInterest);


    tStep=unique(diff(tData));
    sampleTimeActual=mean(tStep);

    frequencyMax=2*nHarmonics*fundamentalFrequency;
    sampleTimeMin=1/frequencyMax;

    if sampleTimeActual>sampleTimeMin
        pm_error('physmod:ee:library:DecreaseStepSize');
    end


    [harmonicOrder,harmonicMagnitude]=ee.internal.signal.getSingleSidedAmplitudeSpectrum(yData,sampleTimeActual,fundamentalFrequency,nHarmonics);

end