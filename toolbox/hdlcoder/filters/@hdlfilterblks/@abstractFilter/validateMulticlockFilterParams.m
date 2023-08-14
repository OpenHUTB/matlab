function v=validateMulticlockFilterParams(this,fparams,hC)




    v=hdlvalidatestruct;

    if hdlgetparameter('clockinputs')==2

        hF=this.createHDLFilterObj(hC);
        s=this.applyFilterImplParams(hF,hC);
        hF.setimplementation;
        this.unApplyParams(s.pcache);

        param='DALUTPartition';
        if any(strncmpi(param,fparams,numel(param)))
            paramVal=this.getImplParams(param);
            if~isempty(paramVal)&&(numel(paramVal)>1||paramVal~=-1)
                v=[v,hdlvalidatestruct(1,message('hdlcoder:filters:validateMultiClock:DALUTPartition'))];
            end
        end
        param='SerialPartition';
        if any(strncmpi(param,fparams,numel(param)))
            paramVal=this.getImplParams(param);
            if~isempty(paramVal)&&(numel(paramVal)>1||paramVal~=-1)
                v=[v,hdlvalidatestruct(1,message('hdlcoder:filters:validateMultiClock:SerialPartition'))];
            end
        end
        if strncmpi(hF.Implementation,'serial',6)
            v=[v,hdlvalidatestruct(1,message('hdlcoder:filters:validateMultiClock:SerialArchitecture'))];
        end
    end
