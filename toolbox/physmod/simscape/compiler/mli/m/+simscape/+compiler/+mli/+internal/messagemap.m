function[mapFileExists,messageMap]=messagemap(componentPath)



































    mapFileExists=false;
    messageMap=[];

    try
        [mapFileExists,tmpMessageMap]=lMessageMap(componentPath);
        if mapFileExists
            messageMap=tmpMessageMap;
        end
    catch
    end

end

function[mapFileExists,messageMap]=lMessageMap(componentPath)


    srcFile=builtin('_pm_which',componentPath);
    if~isempty(srcFile)

        mapFile=simscape.defaultMessageMapPath(srcFile);
        if exist(mapFile,'file')
            messageMap=simscape.MessageMap(mapFile);
            mapFileExists=true;
        else
            messageMap=simscape.MessageMap;
            mapFileExists=false;
            return;
        end


        baseClass=simscape.baseClass(componentPath);
        if~isempty(baseClass)

            [baseMapFileExists,baseMessageMap]=lMessageMap(baseClass);
            if baseMapFileExists
                baseMembers=baseMessageMap.members;
                for i=1:numel(baseMembers)
                    if~messageMap.hasMember(baseMembers{i})
                        messageMap.member(baseMembers{i},...
                        baseMessageMap.member(baseMembers{i}));
                    end
                end
                mapFileExists=true;
            else
                messageMap=simscape.MessageMap;
                mapFileExists=false;
            end
        end
    end
end
