function[ffmatrix,lutmatrix]=getDAPartMatrix(this)






    [~,~,ff,dr]=getDAFoldingFactors(this);
    fl=this.getfilterlengths;

    taps=fl.czero_len;
    lutwidths=min(12,taps):-1:2;
    ffmatrix=cell(length(ff),3);
    lutmatrix=cell(length(lutwidths),4);
    recordnum=1;
    baat=log2(dr);
    for n=ff
        ffmatrix(recordnum,:)={num2str(n),...
        num2str(baat(recordnum)),...
        ['2^',num2str(baat(recordnum))]};
        recordnum=recordnum+1;
    end

    recordnum=1;
    for lutw=lutwidths
        dalut=getDALUTforwidth(this,lutw);
        [lutsize,lutsizedisp]=getLUTSize(this,dalut,fl);
        totallutsize=sum(lutsize);
        lutmatrix(recordnum,:)={num2str(lutw),...
        num2str(totallutsize),...
        lutsizedisp,...
        convSerialPart2String(this,dalut)};
        recordnum=recordnum+1;
    end



