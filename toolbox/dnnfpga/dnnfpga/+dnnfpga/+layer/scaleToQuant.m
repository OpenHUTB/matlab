function output=scaleToQuant(param,input,exponent)




    type=fi([],1,param.WL,-exponent);
    output=zeros(size(input),'like',type);

    output(:)=input;

end

