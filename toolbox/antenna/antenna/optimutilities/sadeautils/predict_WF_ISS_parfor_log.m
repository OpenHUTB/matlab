function[ui2,uiy2]=predict_WF_ISS_parfor_log(TrainDataS2,TrainDataY2,~,ui2,D,ns,~,lg,add)





























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
    parfor i=1:size(ui2,1)

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
