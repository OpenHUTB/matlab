function range=determine_range(ax,cdatamapping)







    if strcmp(cdatamapping,'scaled')












        range=ax.ColorSpace.CLim_I;


    elseif strncmp(cdatamapping,'direct',6)
        mapsize=max(1,size(colormap(ax),1));
        if strcmp(cdatamapping,'direct0based')
            range=[0,mapsize];
        else
            range=[1,mapsize+1];
        end
    else
        range=[0,1];
    end
