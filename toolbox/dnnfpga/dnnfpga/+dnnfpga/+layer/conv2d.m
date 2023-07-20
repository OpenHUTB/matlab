function output=conv2d(X,Y,xfi)




%#codegen
    coder.inline('always');

    YSz=size(Y);
    Y(:)=rot90(Y,2);

    X=setfimath(X,xfi.fimath);




    stride=int32([1,1]);
    paddingSize=int32([0,0,0,0]);
    dilation=int32([1,1]);

    output=coder.nullcopy(zeros(iComputeOutputSize(X,Y,paddingSize,stride,dilation),'like',xfi));

    coder.gpu.kernel();
    for channel=1:size(output,3)
        for col=1:size(output,2)
            for row=1:size(output,1)

                out_pixel=cast(0,'like',output);




                for r=1:YSz(1)
                    for c=1:YSz(2)
                        for ch=1:size(X,3)
                            x_row=row+r-1;
                            x_col=col+c-1;
                            if x_row>0&&x_col>0&&x_row<=size(X,1)&&x_col<=size(X,2)
                                input_pixel=X(x_row,x_col,ch);
                                out_pixel(:)=out_pixel+input_pixel*Y(r,c,ch,channel);
                            end
                        end
                    end
                end

                output(row,col,channel)=out_pixel;
            end
        end
    end
    X=removefimath(X);
    output=removefimath(output);
end

function outputSz=iComputeOutputSize(X,W,paddingSize,strideHW,dilationHW)
    inputSz=int32(size(X));
    inputHW=int32(inputSz(1:2));
    filterSz=int32(size(W));
    filterHW=filterSz(1:2);
    filterHW=dilationHW.*(filterHW-1)+1;
    top=1;bottom=2;left=3;right=4;
    paddingHW=[paddingSize(top)+paddingSize(bottom),paddingSize(left)+paddingSize(right)];
    outputHW=floor(single(inputHW+paddingHW-filterHW)./single(strideHW))+1;
    outputSz=[outputHW,size(W,4),size(X,4)];
end

