function exportToWorkspace(varNames,vidObjs)


















    for ii=1:length(varNames)
        newObject=copyObject(vidObjs(ii));
        assignin('base',varNames{ii},newObject);
    end

    function newObject=copyObject(oldObject)



        info=imaqhwinfo(oldObject);
        adaptorName=info.AdaptorName;
        deviceID=oldObject.DeviceID;
        format=oldObject.VideoFormat;


        newObject=videoinput(adaptorName,deviceID,format);



        oldProps=set(oldObject);

        propNames=fieldnames(oldProps);

        for curProp=propNames'


            if ismember(lower(curProp{1}),{'errorfcn','framesacquiredfcn','framesacquiredfcncount',...
                'startfcn','stopfcn','timerfcn','timerperiod','triggerfcn','userdata'})
                continue;
            end

            set(newObject,curProp{1},get(oldObject,curProp{1}));
        end

        copySourceProperties(oldObject,newObject);

        oldTriggerConfig=triggerconfig(oldObject);
        triggerconfig(newObject,oldTriggerConfig);

        function copySourceProperties(oldObject,newObject)



            oldSources=oldObject.Source;
            newSources=newObject.Source;

            for ii=1:length(oldSources)
                curOldSource=oldSources(ii);
                curNewSource=newSources(ii);

                oldProps=set(curOldSource);
                propNames=fieldnames(oldProps);

                set(curNewSource,propNames,get(curOldSource,propNames));
            end


