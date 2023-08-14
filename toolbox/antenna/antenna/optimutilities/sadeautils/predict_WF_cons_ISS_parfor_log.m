function[ui2,uiy2]=predict_WF_cons_ISS_parfor_log(TrainDataS2,TrainDataY2,~,ui2,D,ns,~,w,hasObj,lg,add)






























    pool=gcp('nocreate');
    if isempty(pool)
        pool=parpool();
        rootdir=matlabroot;
        if ispc
            appenddir1='\toolbox\antenna\antenna\optimutilities\sadea';
            appenddir2='\toolbox\antenna\antenna\optimutilities\sadeautils';
        else
            appenddir1='/toolbox/antenna/antenna/optimutilities/sadea';
            appenddir2='/toolbox/antenna/antenna/optimutilities/sadeautils';
        end
        utilsdir1=[rootdir,appenddir1];
        utilsdir2=[rootdir,appenddir2];
        addAttachedFiles(pool,{utilsdir1,utilsdir2});
    end
    nw=length(w);
    nc=size(TrainDataY2,2);
    parfor i=1:size(ui2,1)

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

        BDACE2=[];
        MSE2=[];
        for j=1:nc
            ko=GaussianProcess.create(TrainDataS,TrainDataY(:,j));
            [BDACE2(j),MSE2(j)]=ko.predict(ui2(i,:));
        end

        if hasObj
            obj_p=LCB(BDACE2(1),MSE2(1),2);
            temp=0;
            for k=1:nw
                temp=temp+...
                w(k)*max([BDACE2(k+1),0]);
            end

            uiy2(i,:)=obj_p+temp;
        else
            temp=0;
            for k=1:nw
                temp=temp+...
                w(k)*max([BDACE2(k),0]);
            end

            uiy2(i,:)=temp;
        end
    end

