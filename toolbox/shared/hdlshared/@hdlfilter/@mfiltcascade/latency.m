function[latency,initlatency]=latency(this)






    factor=max(prod(this.ratechangefactors));

    latency=0;
    if this.getHDLParameter('filter_registered_input')==1
        if isinterpolator(this)
            latency=latency+factor;
        else
            latency=latency+1;
        end
    end
    if this.getHDLParameter('filter_registered_output')==1
        if isdecimator(this)
            if this.getHDLParameter('clockinputs')==2
                latency=latency+factor;
            else
                latency=latency+1;
            end
        else
            latency=latency+1;
        end
    end

    latency=latency+this.getHDLParameter('filter_excess_latency');
    initlatency=latency*this.getHDLParameter('foldingfactor');

    if strcmpi(this.Implementation,'localmultirate')&&strcmpi(getCascadeType(this),'interpolating')
        clkreqs=analyzeImplementation(this);
        [~,~,~,inprate,outprate,clkenbrates]=this.designTimingController(clkreqs);
        actualoprate=outprate*inprate;
        latstages=getStageLatencies(this,clkenbrates);
        initlatency=sum(latstages)*actualoprate;


        initlatency=initlatency-1;
    end



    function result=isinterpolator(this)

        rcf=this.ratechangefactors;
        result=any(rcf(:,1)~=1)&&all(rcf(:,2)==1);



        function result=isdecimator(this)

            rcf=this.ratechangefactors;
            result=any(rcf(:,2)~=1)&&all(rcf(:,1)==1);

            function latstages=getStageLatencies(this,clkenbrates)
                ff=this.getFoldingFactor;
                sampletimes=getSampleTimes(this);
                isparallel=(this.getFoldingFactor==1);
                for n=1:length(this.Stage)
                    if isparallel(n)
                        if sampletimes(n)==sampletimes(n+1)
                            latstages(n)=sampletimes(n+1);
                        else
                            latstages(n)=sampletimes(n);
                        end
                    else
                        [~,initlat]=this.Stage(n).latency;


                        if sampletimes(n)==sampletimes(n+1)
                            if strcmpi(this.Stage(n).Implementation,'serial')

                                if n<length(this.Stage)
                                    initlat=ff(n)+2;
                                else


                                    initlat=2*ff(n)+2;
                                end
                            end
                            initlat=initlat-1;
                            latstages(n)=ceil((initlat)/ff(n))*sampletimes(n+1);
                        else




                            if strcmpi(this.Stage(n).Implementation,'serial')
                                initlat=initlat-2;

                                initlat=initlat+1;
                            elseif strcmpi(this.Stage(n).Implementation,'distributedarithmetic')
                                if clkenbrates(n)>1
                                    initlat=initlat-1;
                                end
                            end

                            latstages(n)=ceil((initlat+1)/ff(n))*sampletimes(n+1);






                        end
                    end




                end

