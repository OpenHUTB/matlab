function blkH=getBlockHandleFromObjectId(objectId)


    try
        type=slmle.internal.checkMLFBType(objectId);
        if(strcmp(type,'EMChart'))
            root=sfroot;
            h=root.idToHandle(objectId);


            if isempty(h)
                h=idToHandle(sfroot,getChartOf(objectId));
            end
            sid=Simulink.ID.getSID(h);
            blkH=Simulink.ID.getHandle(sid);
        else

            chartId=sf('get',objectId,'.chart');
            instanceId=sf('get',chartId,'.instance');
            blkH=sf('get',instanceId,'.simulinkBlock');
        end

    catch ME
        blkH=[];
    end



    function chartId=getChartOf(objectId)

        CHART_ISA=sf('get','default','chart.isa');
        STATE_ISA=sf('get','default','state.isa');
        TRANSITION_ISA=sf('get','default','transition.isa');
        JUNCTION_ISA=sf('get','default','junction.isa');
        PORT_ISA=sf('get','default','port.isa');
        EVENT_ISA=sf('get','default','event.isa');
        DATA_ISA=sf('get','default','data.isa');

        objectIsA=sf('get',objectId,'.isa');
        switch objectIsA
        case CHART_ISA
            chartId=objectId;
        case{STATE_ISA,TRANSITION_ISA,JUNCTION_ISA,PORT_ISA}
            chartId=sf('get',objectId,'.chart');
        case DATA_ISA
            parentId=sf('ParentOf',objectId);
            chartId=getChartOf(parentId);
        case EVENT_ISA
            parentId=sf('ParentOf',objectId);
            chartId=getChartOf(parentId);
        otherwise
            chartId=0;
        end
