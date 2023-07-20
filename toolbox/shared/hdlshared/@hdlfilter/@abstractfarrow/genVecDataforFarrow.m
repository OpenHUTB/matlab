function[indata,outdata]=genVecDataforFarrow(this,filterobj,indata,arithisdouble)




    len=length(indata);
    tbfdstim=hdlgetparameter('tb_fracdelay_stimulus');


    if~isempty(tbfdstim)&&strcmpi(class(tbfdstim),'double')
        inputveclength=length(indata);
        fdveclength=length(tbfdstim);
        if inputveclength~=fdveclength
            error(message('HDLShared:hdlfilter:stimlengthsmismatch',num2str(fdveclength),num2str(inputveclength)));
        end
    end
    fdall=hdlgetallfromsltype(this.FDSLtype);
    if~isempty(tbfdstim)
        if~isnumeric(tbfdstim)
            switch lower(tbfdstim)
            case 'randsweep'
                fd=rand(1,len);
            case 'rampsweep'
                step=1/(len+1);
                fd=step:step:1-step;
            end
            speed=ceil(0.1*len);

            fds=fd(1:speed:end);
            fdv=[];
            for n=1:length(fds)-1
                fdv=[fdv,fds(n)*ones(1,speed)];
            end
            fdvalue=[fdv,fds(end)*ones(1,len-length(fdv))];
        else
            fdvalue=tbfdstim;
        end
    else
        fdvalue=filterobj.Fracdelay;
    end

    if arithisdouble
        fddata=fdvalue;
    else



        fddata=fi(fdvalue,fdall.signed,fdall.size,fdall.bp,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
    end

    if~isempty(tbfdstim)

        [fdunique,fdfreq]=finduniquefdvalues(fddata);



        Hd=copy(filterobj);
        Hd.states=zeros(Hd.nstates,1);
        if~arithisdouble
            Hd.FilterInternals='specifyprecision';
            Hd.FDAutoScale=false;
        end
        Hd.PersistentMemory=true;
        strtidx=1;
        outdata=[];
        for n=1:length(fdfreq)
            Hd.FracDelay=fdunique(n);
            outdata=[outdata,filter(Hd,indata(strtidx:(strtidx+fdfreq(n)-1)))];
            strtidx=fdfreq(n)+strtidx;
        end


    else

        filterobj_copy=copy(filterobj);
        outdata=hdlgetfilterdata(filterobj_copy,indata);

    end

    indata={indata,fddata};


    function[fdunique,fdfreq]=finduniquefdvalues(fddata)

        len=length(fddata);
        uniq=fddata(1);
        fdunique=[];
        fdix=1;
        fdfreq=[];
        for n=2:len+1
            if n~=len+1
                if fddata(n)~=uniq
                    fdfreq=[fdfreq,n-fdix];%#ok<*AGROW>
                    fdunique=[fdunique,uniq];
                    fdix=n;
                    uniq=fddata(n);
                end
            else
                if fdix==len
                    fdunique=[fdunique,uniq];
                    fdfreq=[fdfreq,1];
                else

                    fdunique=[fdunique,uniq];
                    fdfreq=[fdfreq,n-fdix];
                end
            end
        end
