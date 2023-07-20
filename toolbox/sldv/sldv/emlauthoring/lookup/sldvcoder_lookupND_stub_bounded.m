%#codegen
function out=sldvcoder_lookupND_stub_bounded(u,table,n,output_ex)



    coder.allowpcode('plain');

    [mindata,maxdata]=sldvcoder_minmax_util(table,n);

    out=sldv.stub(cast(u,class(output_ex)));

    mindata=cast(mindata,class(output_ex));
    maxdata=cast(maxdata,class(output_ex));


    sldv.assume(out>=mindata&&out<=maxdata);
    sldv.condition(out>=mindata&&out<=maxdata);
end