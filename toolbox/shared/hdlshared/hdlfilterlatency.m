function latency=hdlfilterlatency(filterobj)







    factor=max(prod(getratechangefactors(filterobj)));

    latency=0;
    if hdlgetparameter('filter_registered_input')==1
        if isinterpolator(filterobj)&&~isserialized(filterobj)
            latency=latency+factor;
        else
            latency=latency+1;
        end
    else
        if isserialized(filterobj)
            latency=latency+1;
        end
    end

    if hdlgetparameter('filter_registered_output')==1
        if isdecimator(filterobj)
            if hdlgetparameter('clockinputs')==2
                latency=latency+factor;
            else
                latency=latency+1;
            end
        else
            latency=latency+1;
        end
    else
        if isserialized(filterobj)
            latency=latency+1;
        end
    end
    if isserialized(filterobj)&&hdlgetparameter('filter_registered_input')==0&&...
        hdlgetparameter('filter_registered_output')==0
        latency=latency-1;
    end

    latency=latency+hdlgetparameter('filter_excess_latency');



    function result=isinterpolator(filterobj)

        if isa(filterobj,'dsp.internal.mfilt.cicinterp')||isa(filterobj,'dsp.internal.mfilt.firinterp')...
            ||isa(filterobj,'dsp.internal.mfilt.holdinterp')||isa(filterobj,'dsp.internal.mfilt.linearinterp')
            result=true;
        elseif isa(filterobj,'mfilt.cascade')
            rcf=getratechangefactors(filterobj);
            result=any(rcf(:,1)~=1)&&all(rcf(:,2)==1);
        else
            result=false;
        end



        function result=isdecimator(filterobj)


            if isa(filterobj,'mfilt.cicdecim')||...
                isa(filterobj,'mfilt.firtdecim')||...
                isa(filterobj,'mfilt.firdecim')
                result=true;
            elseif isa(filterobj,'mfilt.cascade')
                rcf=getratechangefactors(filterobj);
                result=any(rcf(:,2)~=1)&&all(rcf(:,1)==1);
            else
                result=false;
            end



            function result=isserialized(filterobj)

                if isa(filterobj,'dfilt.dffir')||...
                    isa(filterobj,'dfilt.dfsymfir')||...
                    isa(filterobj,'dfilt.dfasymfir')||...
                    isa(filterobj,'dsp.internal.mfilt.firinterp')
                    serializable=true;
                else
                    serializable=false;
                end
                ssi=hdlgetparameter('filter_serialsegment_inputs');
                reuseacc=hdlgetparameter('filter_reuseaccum');
                if isscalar(ssi)
                    if ssi==-1&&~reuseacc
                        serial=false;
                    else
                        serial=true;
                    end
                else
                    if isequal(ones(1,length(ssi)),ssi)
                        serial=false;
                    else
                        serial=true;
                    end
                end
                if serializable&&serial
                    result=true;
                else
                    result=false;
                end