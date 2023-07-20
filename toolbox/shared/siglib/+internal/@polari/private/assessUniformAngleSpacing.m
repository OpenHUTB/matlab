function dnew=assessUniformAngleSpacing(d)











    if isempty(d)
        dnew=[];
    else
        for i=numel(d):-1:1
            d_i=d(i);
            [angSpacing,angGaps]=findNonuniformAngleDifferences(d_i.ang*pi/180);

            d_i.angSpacing=angSpacing*180/pi;
            d_i.angGaps=angGaps;




            d_i.angGapAtEnd=any(angGaps==numel(d_i.ang));


            dnew(i,1)=d_i;
        end
    end
