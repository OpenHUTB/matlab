%#codegen
function y=hdleml_sum_tree(u,outtp_ex)






    coder.allowpcode('plain')
    eml_prefer_const(outtp_ex);

    inputLen=length(u);
    outLen=ceil(inputLen/2);
    numOps=floor(inputLen/2);

    y=hdleml_define_len(outtp_ex,outLen);


    for ii=1:numOps
        y(ii)=hdleml_add(u(ii*2-1),u(ii*2),outtp_ex);
    end


    inputLenOdd=(mod(inputLen,2)==1);
    if inputLenOdd
        y(end)=u(end);
    end


