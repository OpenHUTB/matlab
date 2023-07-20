function[hTb,indata,outdata]=createHDLTestbench(this,filterspec,inputdata)







    fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:inputstimulusgen')));


    if isa(filterspec,'dfilt.basefilter')
        filterobj=filterspec;
        filterspecisdfilt=1;
        filterspecissysobj=0;
    elseif isa(filterspec,'dsp.BiquadFilter')
        filterspec=clone(filterspec);
        filterobj=[];
        filterspecisdfilt=0;
        filterspecissysobj=1;
    else

        filterspec=clone(filterspec);
        filterobj=createDfilt(this);
        filterspecisdfilt=0;
        filterspecissysobj=0;
    end

    if strcmpi(class(filterobj),'dfilt.cascade')||strcmpi(class(filterobj),'mfilt.cascade')
        arithisdouble=strcmpi(filterobj.Stage(1).Arithmetic,'double');
        if~arithisdouble
            iwl=filterobj.Stage(1).InputWordLength;
            ifl=filterobj.Stage(1).InputFracLength;
        end
    elseif filterspecissysobj
        ntype=hdlgetparameter('filter_input_datatype');
        arithisdouble=isfloat(ntype);
        if~arithisdouble
            iwl=ntype.WordLength;
            ifl=ntype.FractionLength;
        end
    else
        arithisdouble=strcmpi(filterobj.Arithmetic,'double');
        if~arithisdouble
            iwl=filterobj.InputWordLength;
            ifl=filterobj.InputFracLength;
        end
    end
    lenin=length(inputdata);
    if arithisdouble&&~all(isfinite(inputdata))
        error(message('HDLShared:hdlfilter:nonefiniteindata'));
    end
    fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:inputstimulusdone',...
    lenin)));


    if arithisdouble
        indata=inputdata;
    else



        indata=fi(inputdata,true,iwl,ifl,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
    end


    hTb=filterhdlcoder.HDLTestbench(this);

    try
        infostr=filterobj.info;
    catch me %#ok<NASGU>
        infostr='';
    end

    try
        specobj=filterobj.getfdesign;
    catch me %#ok<NASGU>
        specobj='';
    end
    if~isempty(specobj)
        specstr=tostring(specobj);

        hTb.CommentInfo=sprintf('Filter Specifications: %s %s',specstr,infostr);
    else
        hTb.CommentInfo=infostr;
    end





    [~,initlatency]=latency(this);
    hTb.initialLatency=initlatency;
    hTb.phaseVector=1;
    [iprate,oprate]=gettbclkrate(this);
    hTb.clkrate=iprate;
    hTb.latency=oprate*iprate;
    try
        L=1;
        if ismultirate(filterobj)

            if isprop(filterobj,'InterpolationFactor')
                L=filterobj.InterpolationFactor;
            end
        elseif isa(filterobj,'mfilt.cascade')

            tmp=filterobj.get_ratechangefactors;
            L=tmp(1);
        else

        end


        filterlength=ceil(filterobj.impzlength/L);
        if lenin<filterlength
            warning(message('HDLShared:hdlfilter:notenoughinput',lenin,filterlength));
        end
    catch me %#ok<NASGU>
    end
    coeffs_internal=strcmpi(hdlgetparameter('filter_coefficient_source'),'internal');

    indata={indata};



    if filterspecisdfilt
        if isa(filterobj,'dfilt.farrowfd')||isa(filterobj,'farrow.fd')||...
            isa(filterobj,'dfilt.farrowlinearfd')||isa(filterobj,'farrow.linearfd')
            [indata,outdata]=genVecDataforFarrow(this,filterobj,indata{:},arithisdouble);
        else
            if~isa(filterobj,'mfilt.firtdecim')
                filterobj_copy=copy(filterobj);

                filterobj_copy.reset;
                if coeffs_internal
                    if hdlgetparameter('RateChangePort')
                        [indata,outdata]=genVecDataforVarRate(this,filterobj_copy,inputdata,arithisdouble);
                    else

                        outdata=hdlgetfilterdata(filterobj_copy,indata{:});

                    end
                else
                    [indata,outdata]=genVecDataforProc(this,filterobj_copy,inputdata,arithisdouble);
                end
            else

                outdata=hdlgetfilterdata(filterobj,indata{:});

            end
        end
    else

        if~isa(filterobj,'mfilt.firtdecim')
            if coeffs_internal
                if hdlgetparameter('RateChangePort')
                    [indata,outdata]=genVecDataforVarRate(this,filterobj,inputdata,arithisdouble);
                else
                    filtersysobj=hdlgetparameter('filter_systemobject');
                    if~isempty(filtersysobj)
                        outdata=hdlgetfilterdata(filterobj,indata{:});
                    else


                        inputvector=indata{:};
                        if size(inputvector,2)>1

                            inputvector=inputvector';
                        end

                        outdata=step(filterspec,inputvector);
                    end
                end
            else
                [indata,outdata]=genVecDataforProc(this,filterobj,inputdata,arithisdouble);
            end
        else

            outdata=hdlgetfilterdata(filterobj,indata{:});

        end
    end
    if arithisdouble&&~all(isfinite(outdata))
        error(message('HDLShared:hdlfilter:nonefinitenumber'));
    end

end
