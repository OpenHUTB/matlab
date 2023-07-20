function html=processRequest(request,params)









    try
        pathparts=parsePathParts(request);
        cmd=join(pathparts,'.');
        args=mapToStruct(params);
        html=feval(['slreq.connector.',cmd{1}],args);

    catch ex
        msgText=strrep(ex.message,newline,'<br/>');
        html=oslc.dngStyle(sprintf('<font color="red">%s</font>',msgText));
    end
end

function parts=parsePathParts(wholepath)
    parts=split(wholepath,'/');
    if~isempty(parts)
        parts(1)=[];
    end


    supportedCommands={'baseUrl','configmgr','links','context','navigate'};
    for i=1:length(parts)
        if~any(strcmp(supportedCommands,parts{i}))
            error('"%s" is not supported',parts{i});
        end
    end
end

function parameters=mapToStruct(params)
    if params.Count==0
        parameters=[];
    else
        allKeys=keys(params);
        allValues=values(params);
        for i=1:length(allKeys)
            parameters.(allKeys{i})=allValues{i};
        end
    end
end


