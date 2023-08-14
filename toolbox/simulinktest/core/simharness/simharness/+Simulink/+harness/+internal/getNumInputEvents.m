function numInputEvents=getNumInputEvents(chartH)
    chartId=sfprivate('block2chart',chartH);
    events=sf('EventsOf',chartId);
    inputEvents=sf('find',events,'.scope','INPUT_EVENT');
    numInputEvents=numel(inputEvents);
end