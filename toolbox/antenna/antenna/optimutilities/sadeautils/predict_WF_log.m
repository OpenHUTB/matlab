function[ui2,uiy2]=predict_WF_log(TrainDataS2,TrainDataY2,opts,ui2,lg,add)


























    if lg
        TrainDataY2=TrainDataY2+add;
        TrainDataY2=log(TrainDataY2);
    end

    ko=GaussianProcess.create(TrainDataS2,TrainDataY2);

    [BDACE2,MSE2]=ko.predict(ui2);

    uiy2=LCB(BDACE2,MSE2,2);




