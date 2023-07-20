function v=checkFullPrecision(this)






    v=hdlvalidatestruct;

    if~strcmpi(this.InputSLType,'double')

        if this.needModifyforFullPrecision

            fpvalues=this.getFullPrecisionSettings;

            err=3;

            v(end+1)=hdlvalidatestruct(err,...
            message('HDLShared:filters:symfir:datapathNotFullPrecision',...
            fpvalues.tapsum(1),fpvalues.tapsum(2),...
            fpvalues.product(1),fpvalues.product(2),...
            fpvalues.accumulator(1),fpvalues.accumulator(2)));


            if hdlgetparameter('generatevalidationmodel')==1
                v(end+1)=hdlvalidatestruct(err,...
                message('HDLShared:filters:symfir:validationModelAssertionsLikely'));
            end

        end

    end



