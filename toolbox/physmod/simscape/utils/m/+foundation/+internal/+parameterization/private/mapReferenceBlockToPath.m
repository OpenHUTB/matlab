function localPath=mapReferenceBlockToPath(ReferenceBlock)





    ReferenceBlockNoLineReturns=replace(ReferenceBlock,newline,' ');



    fileparts=split(ReferenceBlockNoLineReturns,'/');



    N=length(fileparts);
    validFilePartNames=cell(N-1,1);
    for idx=2:N
        thisString=fileparts{idx};

        thisStringNoSpaces=replace(thisString,' ','_');

        thisStringNoAmpersand=replace(thisStringNoSpaces,'&','and');

        validFilePartNames{idx-1}=matlab.lang.makeValidName(thisStringNoAmpersand);
    end


    localPath=fullfile(validFilePartNames{:});

end