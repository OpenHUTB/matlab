function[clkUp,nstates,outputoffsets,inprate,outprate,clkenbrates]=compute_tc_params(this,up,down,offset,offsetScale,outputoffsets)

















    nstages=length(this.Stage);
    clkUp=vector_lcm(up);
    factors=clkUp./up;
    scaledDown=down.*factors;
    offsetScale=offsetScale.*factors;


    GCD=vector_gcd([scaledDown]);
    scaledDown=scaledDown./GCD;










    nstates=vector_lcm(scaledDown);
    clkenbrates=scaledDown(1:nstages);

    if this.isInterpolating
        foldfact=this.getFoldingFactor;
        outprate=foldfact(end)*clkenbrates(end);
        sampletimes=getSampleTimes(this);
        ratesonwires=sampletimes*outprate;

        inprate=ratesonwires(1);


        outprate=outprate/inprate;
    else


        inprate=scaledDown(1)*up(1);
        outprate=scaledDown(end)*up(end);
    end







    for i=1:length(offset)
        if offsetScale(i)==0

        else
            if offset(i)~=0
                offset(i)=offset(i)*offsetScale(i)-(offsetScale(i)-1);
            else
                offset(i)=nstates-(offsetScale(i)-1);
            end
        end
    end

    for i=1:length(down)
        if scaledDown(i)==1

            if nstates>1
                tmp=offset(i):scaledDown(i):(nstates-1);
                if offset(i)==1
                    tmp=[tmp,0];
                end
                outputoffsets{end+1}=tmp;
            else
                outputoffsets{end+1}=1;
            end
        else
            outputoffsets{end+1}=offset(i):scaledDown(i):(nstates-1);
        end
    end


    function result=vector_lcm(invec)

        result=invec(1);
        for i=2:length(invec)
            result=lcm(result,floor(invec(i)));
        end


        function result=vector_gcd(invec)

            result=invec(1);
            for i=2:length(invec)
                result=gcd(result,invec(i));
            end