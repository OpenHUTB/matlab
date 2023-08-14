function[ui2,uiy2]=predict_WF_cons_log(TrainDataS2,TrainDataY2,opts,ui2,w,hasObj,lg,add)































    TrainDataY2=TrainDataY2+repmat(add,[size(TrainDataY2,1),1]);
    for i=1:size(TrainDataY2,2)
        if lg(i)==1
            TrainDataY2(:,i)=log(TrainDataY2(:,i));
        end
    end

    nc=size(TrainDataY2,2);
    for i=1:nc
        km(i)=GaussianProcess.create(TrainDataS2,TrainDataY2(:,i));
        [BDACE2(:,i),MSE2(:,i)]=km(i).predict(ui2);
    end

    if hasObj
        obj_p=LCB(BDACE2(:,1),MSE2(:,1),2);

        for j=1:length(obj_p)
            temp=0;
            for k=1:length(w)
                if add(k+1)==0
                    temp=temp+...
                    w(k)*max([BDACE2(j,k+1),0]);
                else
                    temp=temp+...
                    w(k)*max([BDACE2(j,k+1)-log(add(k+1)),0]);
                end
            end
            uiy2(j,:)=obj_p(j,:)+temp;
        end
    else
        for j=1:size(BDACE2,1)
            temp=0;
            for k=1:length(w)
                if add(k)==0
                    temp=temp+...
                    w(k)*max([BDACE2(j,k),0]);
                else
                    temp=temp+...
                    w(k)*max([BDACE2(j,k)-log(add(k)),0]);
                end
            end
            uiy2(j,:)=temp;
        end
    end

