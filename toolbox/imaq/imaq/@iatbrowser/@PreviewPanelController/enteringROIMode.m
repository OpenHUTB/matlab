function enteringROIMode(this)






    if~isempty(this.startAcquisitionBtnListener)
        delete(this.startAcquisitionBtnListener);
        this.startAcquisitionBtnListener=[];
    end

end