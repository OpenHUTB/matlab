

function out=saGenWMatrix(PrecodingMatrixIndex)



    w=[0.5+0.5i,0.5-0.5i,-0.5+0.5i,-0.5-0.5i];
    w1=1/sqrt(2);
    w2=w(PrecodingMatrixIndex+1);
    out=[w1,w2;w1,-w2];
end