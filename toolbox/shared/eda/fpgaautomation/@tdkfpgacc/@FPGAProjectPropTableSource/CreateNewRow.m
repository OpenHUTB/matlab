function h=CreateNewRow(this,currRowH)



    if nargin==1
        h=tdkfpgacc.FPGAProjectPropRowSource;
    else
        h=tdkfpgacc.FPGAProjectPropRowSource(currRowH);
    end
end
