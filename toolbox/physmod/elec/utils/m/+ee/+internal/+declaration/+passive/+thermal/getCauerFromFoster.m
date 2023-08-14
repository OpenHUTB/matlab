function[RthVecCauer,CthVecCauer]=getCauerFromFoster(RthVecFoster,CthVecFoster,numElements)%#codegen




















    coder.allowpcode('plain');


    RthVecCauer=zeros(numElements,1);
    CthVecCauer=zeros(numElements,1);



    [N_tf,D_tf]=ee.internal.declaration.passive.thermal.getEquivalentTfOf1stOrderFilterSum(...
    RthVecFoster,RthVecFoster.*CthVecFoster);


    tfDenCoeffs=N_tf(:)';
    tfDenCoeffs(1)=[];
    tfNumCoeffs=D_tf(:)';





    for idxElement=1:numElements
        maxCoeff=max([tfNumCoeffs,tfDenCoeffs]);

        tfNumCoeffs=tfNumCoeffs/maxCoeff;
        tfDenCoeffs=tfDenCoeffs/maxCoeff;

        if tfDenCoeffs(1)~=0
            CthVecCauer(idxElement)=tfNumCoeffs(1)/tfDenCoeffs(1);
        else
            ME=MException(...
            message('physmod:ee:utilities:getCauerFromFoster:DivideByZero',...
            mat2str(RthVecFoster),mat2str(CthVecFoster)));
            throw(ME)
        end

        tfDenCoeffs_new=tfDenCoeffs*tfDenCoeffs(1);
        tfNumCoeffs_new=tfNumCoeffs*tfDenCoeffs(1)-[tfDenCoeffs,0]*tfNumCoeffs(1);
        tfNumCoeffs_new(1)=[];

        if tfNumCoeffs_new(1)~=0
            RthVecCauer(idxElement)=tfDenCoeffs_new(1)/tfNumCoeffs_new(1);
        else
            ME=MException(...
            message('physmod:ee:utilities:getCauerFromFoster:DivideByZero',...
            mat2str(RthVecFoster),mat2str(CthVecFoster)));
            throw(ME)
        end

        tfDenCoeffs=tfDenCoeffs_new*tfNumCoeffs_new(1)-tfNumCoeffs_new*tfDenCoeffs_new(1);
        tfDenCoeffs(1)=[];
        tfNumCoeffs=tfNumCoeffs_new*tfNumCoeffs_new(1);
    end

end

