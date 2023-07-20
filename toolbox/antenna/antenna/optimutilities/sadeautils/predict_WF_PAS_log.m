function[ui2,uiy2]=predict_WF_PAS_log(TrainDataS2,TrainDataY2,opts,ui2,D,ns,lg,add)

    [TrainDataS2,TrainDataY2]=GenTrainData_New(TrainDataS2,TrainDataY2,D,ui2,ns);

    if lg
        TrainDataY2=TrainDataY2+add;
        TrainDataY2=log(TrainDataY2);
    end

    if size(TrainDataS2,1)==1
        error('There is only one element of training data so the algorithm may have converged.');
    end

    ko=GaussianProcess.create(TrainDataS2,TrainDataY2);

    [BDACE2,MSE2]=ko.predict(ui2);

    uiy2=LCB(BDACE2,MSE2,2);




