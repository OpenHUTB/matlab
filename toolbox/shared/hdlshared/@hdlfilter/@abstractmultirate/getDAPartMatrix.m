function[ffmatrix,lutmatrix]=getDAPartMatrix(this)






    [~,~,ff,dr]=getDAFoldingFactors(this);
    fl=this.getfilterlengths;

    ffmatrix=cell(length(ff),3);
    recordnum=1;
    baat=log2(dr);
    for n=ff
        ffmatrix(recordnum,:)={num2str(n),...
        num2str(baat(recordnum)),...
        ['2^',num2str(baat(recordnum))]};
        recordnum=recordnum+1;
    end

    phases=size(fl.effective_polycoeffs,1);
    ncoeffs=zeros(1,phases);
    for ii=1:phases
        ncoeffs(ii)=length(find(fl.effective_polycoeffs(ii,:)));
    end

    minmlutwidth=min(2,max(ncoeffs));
    lutwidths=min(12,max(ncoeffs)):-1:minmlutwidth;
    lutmatrix=cell(length(lutwidths),4);
    recordnum=1;
    for lutw=lutwidths
        dalut=getDALUTforwidth(this,lutw);
        [lutsize,lutsizedisp]=getLUTSize(this,dalut,fl);

        lutmatrix(recordnum,:)={num2str(lutw),...
        num2str(lutsize),...
        lutsizedisp,...
        convDALutPart2String(this,dalut)};
        recordnum=recordnum+1;
    end



