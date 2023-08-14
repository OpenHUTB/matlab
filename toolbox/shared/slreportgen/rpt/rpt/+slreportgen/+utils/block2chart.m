function sfCharts=block2chart(blkNames)










    if isempty(blkNames)
        sfCharts=[];
    elseif isa(blkNames,'Simulink.SubSystem')



        sfCharts=[];
        for i=1:length(blkNames)
            try
                foundChart=sf('Private','block2chart',blkNames(i).Handle);
                if~isempty(foundChart)
                    sfCharts=[sfCharts,idToHandle(slroot,foundChart)];%#ok
                end
            catch ME %#ok<NASGU>

            end
        end






    else




        blkNames=mlreportgen.utils.safeGet(blkNames,'Object','get_param');

        okIdx=cellfun('isclass',blkNames,'Simulink.SubSystem');
        blkNames=blkNames(okIdx);
        blkNames=[blkNames{:}];
        sfCharts=slreportgen.utils.block2chart(blkNames);
    end

end


