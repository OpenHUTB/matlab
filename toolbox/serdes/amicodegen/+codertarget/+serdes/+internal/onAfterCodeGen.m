function onAfterCodeGen(hCS,buildInfo)






    for i=1:length(buildInfo.Src.Files)
        if strcmpi(buildInfo.Src.Files(i).FileName,'rt_malloc_main.c')||...
            strcmpi(buildInfo.Src.Files(i).FileName,'rt_malloc_main.cpp')
            buildInfo.Src.Files(i)=[];
        end
    end

end
