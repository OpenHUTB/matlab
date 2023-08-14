function sfCharts=block2linkchart(blkNames)









    if isempty(blkNames)
        sfCharts=[];
    elseif isa(blkNames,'Simulink.SubSystem')



        sfCharts=[];
        for i=1:length(blkNames)
            try
                sfBlkId=get_param(blkNames(i).Handle,'UserData');
                chartId=sf('get',sfBlkId,'instance.chart');

                if~isempty(chartId)
                    sfCharts=[sfCharts,rptgen_sf.id2handle(chartId)];%#ok<AGROW>
                elseif~isempty(sfBlkId)
                    sfCharts=[sfCharts,rptgen_sf.id2handle(sfBlkId)];%#ok<AGROW>
                end
            catch ME
                rptgen.displayMessage(ME.message,5);
            end
        end






    else


        blkNames=rptgen.safeGet(blkNames,'Object','get_param');

        okIdx=cellfun('isclass',blkNames,'Simulink.SubSystem');
        blkNames=blkNames(okIdx);
        blkNames=[blkNames{:}];
        sfCharts=rptgen_sf.block2linkchart(blkNames);
    end