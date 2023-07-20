function out=resizeEOP(in,size1,inName,size1Name)





    if size(in,1)==size1

        out=in;
    elseif size(in,1)==1

        out=repmat(in,size1,1);
    else
        error(message('spacecraft:validation:resizeEOP',inName,size1Name));
    end
end