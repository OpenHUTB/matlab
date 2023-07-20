function[hdlbody,hdlsignals,rdEnb,dutenb]=hdlTimingControllerComp(this,...
    tbenb_dly,clkenb,snkDone,srcDone)


    dutenb=tbenb_dly;

    if isempty(this.inportSrc)
        hdlbody=[];
        hdlsignals=[];
        rdEnb=[];
    else

        bdt=hdlgetparameter('base_data_type');
        inlen=length(this.InportSrc);

        assert(this.clkrate>0,sprintf('this.clkrate is negative: %d',this.clkrate));

        if(this.isCEasDataValid)
            inputdatainterval=hdlgetparameter('inputdatainterval');
            assert(inputdatainterval>=0,'input data interval can''t be negative.');
            if(inputdatainterval==0)
                inputdatainterval=this.clkrate;
            elseif(inputdatainterval>0&&inputdatainterval<this.clkrate)
                error(message('HDLShared:hdlshared:insufficientinputdatainterval',this.clkrate));
            end
        else
            inputdatainterval=this.clkrate;
        end

        if(inputdatainterval>1)

            hdladdclockenablesignal(tbenb_dly);
            hdlsetcurrentclockenable(tbenb_dly);
            [hdlbody,hdlsignals,hdlsignalidx]=this.hdlslowclkgenerator(inputdatainterval);
            if(this.isCEasDataValid())
                dutenb=hdlsignalidx(1);
            else
                dutenb=tbenb_dly;
            end
            hdlsetcurrentclockenable(clkenb);


            rdEnbVector=cell(inlen,1);
            clkEnbVector=cell(inlen,1);

            for i=1:inlen
                rdEnbVector{i}=this.InportSrc(i).dataRdEnb;
                clkEnbVector{i}=this.InportSrc(i).ClockEnable;
            end

            rdEnbVector=unique(rdEnbVector);
            clkEnbVector=unique(clkEnbVector);


            for i=1:length(rdEnbVector)
                [~,rdEnb(i)]=hdlnewsignal(rdEnbVector{i},'block',-1,0,0,bdt,'boolean');%#ok
                if(this.clkrate<=1)
                    hdlregsignal(rdEnb(i));
                end
                hdlsignals=[hdlsignals,makehdlsignaldecl(rdEnb(i))];%#ok
                hdlbody=[hdlbody,this.hdlrdenb(rdEnb(i),hdlsignalfindname(clkEnbVector{i}),snkDone,srcDone)];%#ok
            end
        else
            [~,rdEnb]=hdlnewsignal('rdEnb','block',-1,0,0,bdt,'boolean');
            hdlregsignal(rdEnb);
            hdlsignals=makehdlsignaldecl(rdEnb);
            for i=1:inlen
                this.InportSrc(i).dataRdEnb='rdEnb';
            end
            hdlbody=this.hdlrdenb(rdEnb,tbenb_dly,snkDone,srcDone);
        end
    end
