function htmlOut=makeprofilerheader()




    s={};
    s{end+1}=matlab.internal.profileviewer.makeheadhtml;
    s{end+1}=['<title>',getString(message('MATLAB:profiler:ProfileSummaryName')),'</title>'];
    s{end+1}='</head>';
    htmlOut=[s{:}];
end