function signalSet(obj,arg)








    if~isempty(arg)
        if~isempty(arg)
            fields=fieldnames(arg);
            for i=1:length(fields)
                if~isempty(obj.findprop(fields{i}))
                    if~isempty(arg.(fields{i}))
                        obj.(fields{i})=arg.(fields{i});
                    end
                end
            end
        end
    end




