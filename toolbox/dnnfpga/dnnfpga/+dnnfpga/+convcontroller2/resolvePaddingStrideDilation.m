function out=resolvePaddingStrideDilation(rx,ix,padding,stride,stridePhase,dilation)
%#codegen


    coder.allowpcode('plain');

    out=rx*stride+ix*dilation-padding+stridePhase;
end
