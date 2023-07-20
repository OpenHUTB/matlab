function out=valid(this)






    out=false;
    allcvd=this.getAll('Mixed');
    for idx=1:length(allcvd)
        if~valid(allcvd{idx})
            return
        end
    end
    out=true;



