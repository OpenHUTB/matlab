function this=HDLTestbench(slConnection)





    this=slhdlcoder.HDLTestbench;

    if nargin==1
        this.ModelConnection=slConnection;
    end


    this.initParamsCommon;

    if(targetcodegen.alteradspbadriver.getDSPBAPotentialMismatch)
        mismatchNote=', may be caused by the mismatch from Altera DSP Builder-Advanced Blockset blocks in the design';
    else
        mismatchNote='';
    end
    this.additionalSimFailureMsg=mismatchNote;
