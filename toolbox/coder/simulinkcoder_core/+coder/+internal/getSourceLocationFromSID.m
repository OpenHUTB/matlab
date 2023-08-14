function htmlStr=getSourceLocationFromSID(sid)



    htmlStr=sid;
    try
        [~,blockSID,~,~,~,~]=util_sid(sid);
        [block,ssid]=Simulink.ID.getFullName(blockSID);
        loc=[block,ssid];
        htmlStr=['<a href="matlab:coder.internal.code2model(''',blockSID,''')" class="code2model">',loc,'</a>'];

    catch me %#ok<NASGU>
    end

    function[blockH,blockSID,sfId,emlStart,emlEnd,chartId]=util_sid(sidList)



        blockH=-1;
        sfId=0;
        emlStart=0;
        emlEnd=0;
        chartId=0;
        blockSID=sidList;

        try







            thisObj=[];
            thisAux='';
            while isempty(thisObj)&&~isempty(sidList)
                [head,tail]=strtok(sidList,sprintf('\n'));
                try
                    [thisObj,thisAux]=Simulink.ID.getHandle(head);
                    if isempty(thisObj)
                        return;
                    end
                catch MEx %#ok<NASGU>
                    sidList=tail;
                end
            end
            blockSID=head;




            if isfloat(thisObj)&&numel(thisObj)==1
                handle=thisObj;
            elseif thisObj.isa('Stateflow.Object')
                handle=thisObj.Id;
            else
                handle=thisObj.Handle;
            end
            if~isempty(thisAux)
                [startStr,endStr]=strtok(thisAux,'-');
                emlStart=str2double(startStr);
                emlEnd=-str2double(endStr);
            end
        catch MEx %#ok<NASGU>
            return;
        end

        if floor(handle)~=handle
            blockH=handle;
            sfId=0;
            chartId=0;
        else
            if sf('get',handle,'.isa')==sf('get','default','chart.isa')
                chartId=handle;
                if sf('get',chartId,'.type')==2

                    states=sf('get',chartId,'.states');
                    sfId=states(1);
                    blockH=sf('get',sf('get',chartId,'chart.instances'),...
                    'instance.sfunctionBlock');
                else
                    sfId=handle;
                    blockH=sfprivate('chart2block',chartId);
                end
            else
                chartId=sfprivate('getChartOf',handle);
                instanceId=sf('get',chartId,'.instance');
                sfId=handle;
                blockH=sf('get',instanceId,'.sfunctionBlock');
            end
        end


