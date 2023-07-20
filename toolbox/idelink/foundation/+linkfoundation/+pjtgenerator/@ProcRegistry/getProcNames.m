function names=getProcNames(reg)




    names=[];

    thisPlatform=computer();


    for t=1:length(reg.pitTypeEnum)

        eval(['pitArray = reg.pit_',reg.pitTypeEnum{t},';']);

        for i=1:length(pitArray)
            pit=pitArray(i).pit;
            for j=1:length(pit)
                if isfield(pit(j),'platform')&&~isempty(pit(j).platform)
                    if(~isempty(strmatch('ALL',pit(j).platform))||~isempty(strmatch(thisPlatform,pit(j).platform)))
                        names{end+1}=pit(j).procName;%#ok<AGROW>
                    end
                else

                    names{end+1}=pit(j).procName;%#ok<AGROW>
                end
            end
        end
    end

end
