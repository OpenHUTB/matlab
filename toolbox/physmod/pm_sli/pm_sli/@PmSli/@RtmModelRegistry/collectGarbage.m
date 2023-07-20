function collectGarbage(this)






    j=1;
    while j<=length(this.modelInfo)

        if~ishandle(this.modelInfo(j).model)
            this.modelInfo(j)=[];
        else
            j=j+1;
        end

    end


