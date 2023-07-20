function out=SampleTimeProperty(cs,~,direction,widgetVals)


    if direction==0
        paramVal=cs.getProp('SampleTimeProperty');
        if isempty(paramVal)
            widgetVal='';
        else
            widgetVal=slprivate('convertSampleTimeInfo',paramVal);
        end
        out={widgetVal};
    elseif direction==1
        widgetVal=widgetVals{1};
        paramVal=slprivate('convertSampleTimeInfo',widgetVal);
        out=paramVal;
    end

