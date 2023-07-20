function inputdatainterval=getInputDataInterval(this)



    inputdatainterval=this.clkrate;
    if this.isCEasDataValid
        idi=hdlgetparameter('inputdatainterval');
        if idi>0
            inputdatainterval=idi;
            if idi<this.clkrate
                errMsg=message('HDLShared:hdlshared:insufficientinputdatainterval',...
                this.clkrate);
                this.addCheckToDriver([],'error',errMsg);
                error(errMsg);
            end
        end
    end
end
