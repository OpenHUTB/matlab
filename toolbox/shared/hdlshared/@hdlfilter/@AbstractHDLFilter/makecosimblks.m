function makecosimblks(this,filterobj,varargin)






    if~isa(filterobj,'dfilt.basefilter')
        error(message('HDLShared:hdlfilter:FeatureNotSupportedForsystemObj'));
    end

    disp('### Starting generation of HDL Verifier cosimulation blocks.');

    oldcastbeforesum=overrideCastbeforeSum(this,filterobj);

    inputdata=maketbstimulus(this,filterobj);

    [hTb,indata,outdata]=createHDLTestbench(this,filterobj,inputdata);

    overrideCastbeforeSum(this,filterobj,oldcastbeforesum);

    hTb.makecosimblks(indata,outdata);
    disp('### Done generating cosimulation Blocks.');
