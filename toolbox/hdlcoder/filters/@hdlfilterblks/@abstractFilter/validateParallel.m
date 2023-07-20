function v=validateParallel(this,hC)






    v=hdlvalidatestruct;

    try
        hF=this.createHDLFilterObj(hC);
    catch me
        v=hdlvalidatestruct(1,me.message,me.identifier);
        return
    end


    s=this.applyFilterImplParams(hF,hC);
    oldPV=s.pcache;

    hF.setimplementation;

    fParams=this.filterImplParamNames;

    cfilePvalue=[];
    for n=1:length(fParams)
        if strmatch('serialpartition',lower(fParams{n}))%#ok<MATCH2> % this implparam belonged to this block
            cfilePvalue=this.getImplParams(fParams{n});
        end
    end

    if strcmpi(hF.implementation,'parallel')
        isSysObj=isa(hC,'hdlcoder.sysobj_comp');
        if~isSysObj
            bfp=hC.SimulinkHandle;
            block=get_param(bfp,'Object');
            if~isempty(block.HDLData)
                if(strcmpi(block.HDLData.archSelection,'Partly Serial')&&all(size(cfilePvalue)==0))
                    if isa(hF,'hdlfilter.df1sos')||isa(hF,'hdlfilter.df2sos')
                        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:filters:validateParallel:partlyserialbutparallelbiquad'));
                    else
                        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:filters:validateParallel:partlyserialbutparallel'));
                    end
                end
                if strcmpi(block.HDLData.archSelection,'Distributed Arithmetic (DA)')
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:filters:validateParallel:dabutparallel'));
                end
            end
        end



        v=[v,s.hdlvalmsgs];


        v=[v,hF.checkhdl];
    end

    this.unApplyParams(oldPV);


