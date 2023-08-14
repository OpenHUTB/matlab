function[studio,mdl]=getStudioHandleFromObjectId(objectId)



    studio=[];
    mdl='';

    try
        chartId=sf('get',objectId,'state.chart');
        chartName=sfprivate('chart2name',chartId);
        mdl=get_param(bdroot(chartName),'name');

        src=simulinkcoder.internal.util.getSource(mdl);
        studio=src.studio;
        if isempty(studio)
            st=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if~isempty(st)
                studio=st(1);
                mdlH=studio.App.blockDiagramHandle;
                mdl=get_param(mdlH,'Name');
            end
        end

    catch ME
        st=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
        if~isempty(st)
            studio=st(1);
            mdlH=studio.App.blockDiagramHandle;
            mdl=get_param(mdlH,'Name');
        end
    end

