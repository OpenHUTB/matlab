function[TraindataS1,TrainDataY1]=filtsame(TraindataS,TraindataY)














    [N,C]=size(TraindataS);
    com=[TraindataS,TraindataY];

    a=1;
    an=N;

    while a<=an
        repeat=[];
        for i=(a+1):an
            if sum(abs(com(i,:)-com(a,:)))<0.001


                repeat=[repeat,i];
            end
        end
        com(repeat,:)=[];
        an=an-length(repeat);
        a=a+1;
    end

    TraindataS1=com(:,1:C);
    TrainDataY1=com(:,(C+1):end);

