function name=getfullname(archH,obj)








    try
        name='';
        path=Simulink.DistributedTarget.internal.allchildrensearch(archH,obj);
        assert(~isempty(path));


        for i=2:length(path)
            name=[name,'/',path{i}.Name];%#ok
        end
    catch err

        throwAsCaller(err);
    end

end


