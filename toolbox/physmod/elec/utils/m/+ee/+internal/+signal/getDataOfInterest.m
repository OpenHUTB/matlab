function[tDataOfInterest,yDataOfInterest,fundamentalFrequency,tInterval]=getDataOfInterest(tData,yData,tOfInterest,nPeriodOfInterest,thresholdOfInterest)







    if~issorted(tData)
        pm_error('physmod:simscape:compiler:patterns:checks:AscendingVec','tData');
    end


    if~all(size(tData)==size(yData))
        pm_error('physmod:simscape:compiler:patterns:checks:LengthEqualLength','tData','yData');
    end


    if exist('tOfInterest','var')&&(tOfInterest<tData(1)||tOfInterest>tData(end))
        pm_error('physmod:ee:library:SimlogTimeOutsideRange','tOfInterest','loggingNode');
    end


    tStep=unique(diff(tData));
    tSample=mean(tStep);
    if any(abs(diff(tStep))>1e6*eps(tSample))
        pm_error('physmod:ee:library:SimlogTimeFixedStepSize');
    end


    if size(tData,1)>size(tData,2)
        inputDataTransposed=false;
    else
        tData=tData';
        yData=yData';
        inputDataTransposed=true;
    end


    yOffset=[yData(2:length(yData));yData(end)];


    if~exist('thresholdOfInterest','var')
        thresholdOfInterest=0;
    end

    idx_zc=find((yData>=thresholdOfInterest&yOffset<thresholdOfInterest)...
    |(yData<thresholdOfInterest&yOffset>=thresholdOfInterest));

    if isempty(idx_zc)
        pm_error('physmod:ee:library:SimlogNoZeroCrossing','loggingNode');
    end


    if any(idx_zc>=length(tData))
        idx_zc=idx_zc(idx_zc<length(tData));
    end


    t_zc=[tData(idx_zc),tData(idx_zc+1)];
    y_zc=[yData(idx_zc),yData(idx_zc+1)];


    xGains=y_zc(:,2)-y_zc(:,1);
    yGains=t_zc(:,2)-t_zc(:,1);
    Gradients=yGains./xGains;
    Constants=t_zc(:,1)-Gradients.*y_zc(:,1);
    T_zc=Gradients.*thresholdOfInterest.*ones(size(Gradients))+Constants;

    f_zc=1./(2*diff(T_zc));
    T_zc=T_zc(2:end);


    median_F_zc=median(f_zc);
    f_idx=f_zc>(0.9*median_F_zc)&f_zc<(1.1*median_F_zc);
    T_zc=T_zc(f_idx);


    if~exist('tOfInterest','var')

        nPeriodOfInterest=12;
        t_end_idx=length(T_zc);
        if t_end_idx<2*nPeriodOfInterest+1
            pm_error('physmod:ee:library:SimlogInsufficientValues','loggingNode');
        end
        t_start_idx=t_end_idx-2*nPeriodOfInterest;
    else
        t_end_idx=find(T_zc>=tOfInterest,1);
        if isempty(t_end_idx)
            t_end_idx=length(T_zc);
        end

        if~exist('nPeriodOfInterest','var')
            nPeriodOfInterest=12;


            if t_end_idx<2*nPeriodOfInterest+1
                pm_error('physmod:ee:library:SimlogInsufficientValues','loggingNode');
            end
            t_start_idx=t_end_idx-2*nPeriodOfInterest;
        else
            if t_end_idx<2*nPeriodOfInterest+1
                pm_error('physmod:ee:library:SimlogInsufficientValues','loggingNode');
            end
            t_start_idx=t_end_idx-2*nPeriodOfInterest;
        end
    end

    t_start=T_zc(t_start_idx);
    t_end=T_zc(t_end_idx);
    tInterval=[t_start,t_end];

    fundamentalFrequency=nPeriodOfInterest/(t_end-t_start);

    absTol=tSample/1e3;
    idx_start=find(tData>t_start+absTol,1,'first');
    idx_end=find(tData<=t_end,1,'last');

    idx=idx_start:idx_end;
    tDataOfInterest=tData(idx);
    yDataOfInterest=yData(idx);


    if inputDataTransposed
        tDataOfInterest=tDataOfInterest';
        yDataOfInterest=yDataOfInterest';
    end

end

