function histWidgets=createHistogramWidgets(histogramMatFileName,histogramIdx,numberOfFields)







    idx=1;

    histogramIcon=fullfile(matlabroot,'toolbox','fixedpoint','fixedpoint','+fixed','+internal','plothist.png');

    if isequal(filesep,'\')

        histogramMatFileName=regexprep(histogramMatFileName,{'\\','%'},...
        {'\\\\','%%'});
        histogramIcon=regexprep(histogramIcon,{'\\','%'},{'\\\\','%%'});


        histogramMatFileName=regexprep(histogramMatFileName,'^\\\\\\\\','\\\\');
        histogramIcon=regexprep(histogramIcon,'^\\\\\\\\','\\\\');
    end

    histWidgets=['<div style="text-align: center;"><a href="matlab:fixed.internal.launchNTX('...
    ,'''',histogramMatFileName,'''',',',mat2str([histogramIdx,idx])...
    ,');"><img src="file:///',histogramIcon...
    ,'" alt="Plot"></a></div>'];

    for idx=2:numberOfFields

        histWidgets=[histWidgets,'<br />','<div style="text-align: center;"><a href="matlab:fixed.internal.launchNTX('...
        ,'''',histogramMatFileName,'''',',',mat2str([histogramIdx,idx])...
        ,');"><img src="file:///',histogramIcon...
        ,'" alt="Plot"></a></div>'];%#ok<AGROW>
    end

end
