function fp=pm_which_(fn)





    if exist(fn,'var')==1

        fps=which(fn,'-all');

        if length(fps)>1
            fp=fps{2};
        else
            fp='';
        end
    else
        fp=which(fn);
    end
end
