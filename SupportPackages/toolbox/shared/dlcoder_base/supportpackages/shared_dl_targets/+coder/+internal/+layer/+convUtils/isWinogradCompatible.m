function compatible=isWinogradCompatible(filterSize,stride,dilation)




%#codegen


    coder.allowpcode('plain')


    compatible=all(filterSize==[3,3])&&all(stride==[1,1])&&all(dilation==[1,1]);

end