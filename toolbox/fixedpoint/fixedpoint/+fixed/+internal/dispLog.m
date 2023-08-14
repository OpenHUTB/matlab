function str=dispLog(log)




    assert(fixed.internal.logIsSane(log));
    logicalStr={'false','true'};

    s={};
    s{end+1}=sprintf('mexFileName: ''%s''\n',log.mexFileName);
    s{end+1}=sprintf('  ''%s''\n',log.timestamp);
    s{end+1}=sprintf('  ''%s''\n',log.buildDir);


    for i=1:length(log.functions)
        f=log.functions(i);
        s{end+1}=sprintf('        ''%s'' (%d)\n',f.fcnName,f.fcnId);
        s{end+1}=sprintf('            SimMin     SimMax     OverflowWraps Saturations IsAlwaysInteger MxInfoLocationIDs Locations\n');
        for j=1:length(f.loggedLocations)
            st=f.loggedLocations(j);
            s{end+1}=sprintf('        %10.4g %10.4g %13d %11d %15s       [%s ]',...
            st.SimMin,st.SimMax,st.OverflowWraps,st.Saturations,...
            logicalStr{1+double(st.IsAlwaysInteger)},...
            sprintf(' %d',st.MxInfoLocationIDs));
            s{end+1}=sprintf(' <%d, %d>',[[st.Locations.TextStart];[st.Locations.TextLength]]);
            s{end+1}=sprintf('\n');
        end
    end
    str=[s{:}];
end
