function sfCharts=block2chart(blkNames)









    if isempty(blkNames)
        sfCharts=[];
    elseif isa(blkNames,'Simulink.SubSystem')



        sfCharts=[];
        for i=1:length(blkNames)
            try
                foundChart=sf('Private','block2chart',blkNames(i).Handle);
                if~isempty(foundChart)
                    sfCharts=[sfCharts,rptgen_sf.id2handle(foundChart)];%#ok
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
        sfCharts=rptgen_sf.block2chart(blkNames);
    end