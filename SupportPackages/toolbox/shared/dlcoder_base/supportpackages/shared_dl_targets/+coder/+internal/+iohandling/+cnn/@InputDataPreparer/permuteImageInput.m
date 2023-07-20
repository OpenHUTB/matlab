%#codegen











function inputT=permuteImageInput(input,targetLib)




    coder.inline('always');
    coder.allowpcode('plain');

    if strcmp(targetLib,'none')
        inputT=input;
    else
        if coder.isColumnMajor

            inputT=coder.internal.coderNetworkUtils.transposeHWDims(input);
        else


            inputT=permute(input,[4,3,1,2]);
        end
    end
end
