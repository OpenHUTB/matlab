function[ui2,uiy2]=predict_WF_ISS_log(TrainDataS2,TrainDataY2,opts,ui2,D,ns,lg,add)


























    for i=1:size(ui2,1)

        [TrainDataS,TrainDataY]=GenTrainData_New_ISS(TrainDataS2,TrainDataY2,D,ui2(i,:),ns);
        if lg
            TrainDataY=TrainDataY+add;
            TrainDataY=log(TrainDataY);
        end

        if size(TrainDataS,1)==1
            error('There is only one element of training data so the algorithm may have converged.');
        end

        ko=GaussianProcess.create(TrainDataS,TrainDataY);

        [BDACE2,MSE2]=ko.predict(ui2(i,:));

        uiy2(i,:)=LCB(BDACE2,MSE2,2);

    end
