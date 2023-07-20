function makemodel(this,filterobj,cosimModel,varargin)





    if~isa(filterobj,'dfilt.basefilter')
        error(message('HDLShared:hdlfilter:FeatureNotSupportedForsystemObj'));
    end
    if~hdlgetparameter('filter_registered_input')&&~hdlgetparameter('filter_registered_output')
        error(message('HDLShared:hdlfilter:GenCosimMdlNotSupportedForUnregFilter'));
    end

    if strcmpi(hdlgetparameter('target_language'),'verilog')&&...
        isArithDouble(filterobj)
        error(message('HDLShared:hdlfilter:GenCosimMdlNotforVerilogDoubles'));
    end

    [suppGenSLTb,gensltbmsg]=this.isGenSLTBsupported;
    if~suppGenSLTb
        error(message('HDLShared:hdlfilter:GenCosimModelNotSupported',gensltbmsg));
    end




    [suppwithComplex,cplxmsg]=this.SuppGenSLTBForComplex;
    if~suppwithComplex
        error(message('HDLShared:hdlfilter:GenCosimModelNotSupported',cplxmsg));
    end


    if hdlgetparameter('clockinputs')==2
        mclkmsg='Generation of cosimulation model is not supported with multiple clocks.';
        error(message('HDLShared:hdlfilter:GenCosimModelNotSupported',mclkmsg));
    end

    [suppProcInt,procintmsg]=this.SuppGenSLTBForProcInt;
    if~suppProcInt
        error(message('HDLShared:hdlfilter:GenCosimModelNotSupported',procintmsg));
    end

    fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:cosimmodelgen',...
    upper(cosimModel))));


    oldcastbeforesum=overrideCastbeforeSum(this,filterobj);
    inputdata=maketbstimulus(this,filterobj,varargin{:});
    [hTb,indata,outdata]=createHDLTestbench(this,filterobj,inputdata);

    overrideCastbeforeSum(this,filterobj,oldcastbeforesum);


    hTb.makecosimtb(indata,outdata,cosimModel,filterobj);
    fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:cosimmodeldone')));



    function success=isArithDouble(filterobj)

        if isa(filterobj,'dfilt.multistage')
            success=strcmpi(filterobj.Stage(1).Arithmetic,'double');
        else
            success=strcmpi(filterobj.Arithmetic,'double');
        end
