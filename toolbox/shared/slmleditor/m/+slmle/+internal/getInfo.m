function s=getInfo(input)






    try
        s=[];
        m=slmle.internal.slmlemgr.getInstance;

        if ischar(input)

            blkName=input;
            objectId=m.getObjectId(blkName);
            if isempty(objectId)
                return;
            end
            type=slmle.internal.checkMLFBType(objectId);
            if strcmp(type,'EMChart')
                blkH=get_param(blkName,'handle');
                chartId=sf('get',objectId,'state.chart');
                chartName=sfprivate('chart2name',chartId);
            elseif strcmp(type,'EMFunction')
                chartId=sf('get',objectId,'.chart');
                chartName=sfprivate('chart2name',chartId);
                instanceId=sf('get',chartId,'.instance');
                blkH=sf('get',instanceId,'.simulinkBlock');
            else
                return;
            end
        elseif ishandle(input)

            blkH=input;
            blkName=getfullname(blkH);
            objectId=m.getObjectId(blkName);
            if isempty(objectId)
                return;
            end
            type=slmle.internal.checkMLFBType(objectId);
            chartId=sf('get',objectId,'state.chart');
            chartName=sfprivate('chart2name',chartId);
        elseif isnumeric(input)

            objectId=input;
            type=slmle.internal.checkMLFBType(objectId);
            chartId=sf('get',objectId,'state.chart');
            chartName=sfprivate('chart2name',chartId);
            if strcmp(type,'EMChart')
                blkName=chartName;
                blkH=get_param(blkName,'handle');
            else
                fncName=sf('get',objectId,'.name');
                blkName=[chartName,'/',fncName];
                instanceId=sf('get',chartId,'.instance');
                blkH=sf('get',instanceId,'.simulinkBlock');
            end
        end


        try
            mdl=get_param(bdroot(chartName),'name');
            src=simulinkcoder.internal.util.getSource(mdl);
            studio=src.studio;
        catch
            studio=[];
        end


        s.name=blkName;
        s.type=type;
        s.objectId=objectId;
        s.blkH=blkH;
        s.chartId=chartId;
        s.chartName=chartName;
        s.studio=studio;

    catch ME
        s=[];
    end