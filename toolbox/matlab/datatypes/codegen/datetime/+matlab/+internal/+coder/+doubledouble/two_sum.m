function c=two_sum(a,b)%#codegen




    coder.allowpcode('plain');

    shi=a+b;
    bb=shi-a;
    slo=(a-(shi-bb))+(b-bb);
    slo(isnan(slo))=0.0;

    c=complex(shi,slo);
end
