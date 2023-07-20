function v=checkFullPrecision(this)






    v=hdlvalidatestruct;

    if~strcmpi(this.InputSLType,'double')

        if this.needModifyforFullPrecision

            fpvalues=this.getFullPrecisionSettings;

            err=3;

            v(end+1)=hdlvalidatestruct(err,...
            message('HDLShared:filters:fir:datapathNotFullPrecision',...
            fpvalues.product(1),fpvalues.product(2),...
            fpvalues.accumulator(1),fpvalues.accumulator(2)));


            if hdlgetparameter('generatevalidationmodel')==1
                v(end+1)=hdlvalidatestruct(err,...
                message('HDLShared:filters:fir:validationModelAssertionsLikely'));
            end

        end

    end


