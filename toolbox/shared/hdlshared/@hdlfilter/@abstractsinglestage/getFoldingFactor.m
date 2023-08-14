function ff=getFoldingFactor(this)








    if strcmpi(this.Implementation,'serial')
        if isFilterSOS(this)
            uff=this.getHDLParameter('userspecified_foldingfactor');
            mults=this.getHDLParameter('filter_nummultipliers');
            if(mults==-1)
                [~,ff]=this.getSerialPartForFoldingFactor('foldingfactor',uff);
            else
                [~,ff]=this.getSerialPartForFoldingFactor('multipliers',mults);
            end
        else
            [~,ff]=this.getSerialPartition('SerialPartition',this.getHDLParameter('filter_serialsegment_inputs'));
        end
    elseif strcmpi(this.Implementation,'distributedarithmetic')
        [~,~,~,ff]=this.getDALutPartition('DALUTPartition',this.getHDLParameter('filter_dalutpartition'),...
        'DARAdix',this.getHDLParameter('filter_daradix'));

    elseif strcmpi(this.Implementation,'parallel')
        ff=1;

    elseif strcmpi(this.Implementation,'serialcascade')
        ff=this.getHDLParameter('foldingfactor');

    else
        error(message('HDLShared:hdlfilter:unsuppImplementation'));
    end


    function isSOS=isFilterSOS(hf)
        isSOS=(isa(hf,'hdlfilter.df1sos')||...
        isa(hf,'hdlfilter.df1tsos')||...
        isa(hf,'hdlfilter.df2sos')||...
        isa(hf,'hdlfilter.df2tsos'));

