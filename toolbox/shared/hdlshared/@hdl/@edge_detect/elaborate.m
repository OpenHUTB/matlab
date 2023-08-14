function elaborate(this)





    hN=this.hN;


    switch lower(this.edge_type)
    case 'rising'
        edge_type_text='Rising';
    case 'falling'
        edge_type_text='Falling';
    case 'both'
        edge_type_text='Either';
    end

    comment=[edge_type_text,' Edge Detection on signal ',this.input.Name];

    if~hdlsignalisboolean(this.input)

        pirelab.getCompareToValueComp(hN,this.input,this.in_notzero,'~=',0);
    end
...
...
...
...
...
...
...
...
...
...
...
...
    pirelab.getUnitDelayComp(hN,this.in_notzero,this.in_notzero_delayed,this.processName);


    if~isempty(this.notin_idx)

        pirelab.getBitwiseOpComp(hN,this.notin_idx,this.notout_idx,'NOT');
    end


    bComp=pirelab.getBitwiseOpComp(hN,[this.opin1,this.opin2],this.output,this.op);
    bComp.addComment(comment);


