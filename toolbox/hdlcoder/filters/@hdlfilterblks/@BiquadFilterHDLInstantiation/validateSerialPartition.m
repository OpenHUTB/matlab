function v=validateSerialPartition(this,hC)





    v=hdlvalidatestruct;

    hF=this.createHDLFilterObj(hC);

    if isa(hF,'hdlfilter.df1tsos')||isa(hF,'hdlfilter.df2tsos')
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:biquad:validate:serialnotsupported'));
        return;
    end

    isSysObj=isa(hC,'hdlcoder.sysobj_comp');
    if~isSysObj
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
        if strcmp(block.FilterSource,'Input port(s)')
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:filters:biquad:validate:coeffviainputports'));
        end
    end

    this.applySerialPartition(hF);


    v(end+1)=checkSerialAttributes(hF);
    if any([v.Status])
        return;
    end


    v(end+1)=this.checkFullPrecision(hF);


    v(end+1)=getserialinfo(hF);


    s=this.applyFilterImplParams(hF,hC);
    hF.setimplementation;
    v1=hF.checkhdl;
    v1.Message=strrep(v1.Message,'\n',' ');
    v=[v,v1];
    this.unApplyParams(s.pcache);

    if hdlgetparameter('generateValidationModel')


        v(end+1)=hdlvalidatestruct(3,message('HDLShared:filters:validate:validationModelAssertions'));
    end


    function v=getserialinfo(hF)

        spmatrix=getSerialPartMatrix(hF);
        err=3;


        [start_tag,end_tag,start_title_tag,end_title_tag]=hdlgetHtmlonlyTags;
        errmsg=[start_tag...
        ,start_title_tag,'Serial Partition Implementation Information',end_title_tag...
        ,dispSerialPartitionHTML(hF,spmatrix)...
        ,end_tag];
        v=hdlvalidatestruct(err,message('hdlcoder:filters:biquad:validate:serialInfoMsg',errmsg));
