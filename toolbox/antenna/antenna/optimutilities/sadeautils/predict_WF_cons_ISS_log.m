function[ui2,uiy2]=predict_WF_cons_ISS_log(TrainDataS2,TrainDataY2,opts,ui2,D,ns,w,hasObj,lg,add)





























    for i=1:size(ui2,1)

        [TrainDataS,TrainDataY]=GenTrainData_New_ISS(TrainDataS2,TrainDataY2,D,ui2(i,:),ns);

        if size(TrainDataS,1)==1
            error('There is only one element of training data so the algorithm may have converged.');
        end


        TrainDataY=TrainDataY+repmat(add,[size(TrainDataY,1),1]);
        for j=1:size(TrainDataY,2)
            if lg(j)==1
                TrainDataY(:,j)=log(TrainDataY(:,j));
            end
        end

        for j=1:size(TrainDataY,2)
            ko(j)=GaussianProcess.create(TrainDataS,TrainDataY(:,j));
            [BDACE2(j),MSE2(j)]=ko(j).predict(ui2(i,:));
        end
        if hasObj
            obj_p=LCB(BDACE2(1),MSE2(1),2);

            temp=0;
            for k=1:length(w)
                temp=temp+...
                w(k)*max([BDACE2(k+1),0]);
            end
            uiy2(i,:)=obj_p+temp;
        else
            temp=0;
            for k=1:length(w)
                temp=temp+...
                w(k)*max([BDACE2(k+1),0]);
            end
            uiy2(i,:)=temp;
        end
    end
