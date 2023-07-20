function spmatrix=getSerialPartMatrix(this)






    [mults,FF,ini_lat,artype]=getSerialPartForFoldingFactor(this);







    ln=3;

    spmatrix=cell(ln,3);
    for n=1:ln;
        spmatrix(n,:)={num2str(FF(n)),...
        num2str(mults(n)),...
        num2str(ini_lat(n))};

    end


