function[indata,outdata]=genVecDataforProc(this,filterobj,inputdata,arithisdouble)







    fl=this.getfilterlengths;
    firlen=fl.firlen;
    coeff_len=fl.coeff_len;
    numinputvectors=length(inputdata);
    eff_input_vectorlen=max(numinputvectors,coeff_len);
    if isempty(hdlgetparameter('tb_coeff_stimulus'))






        inputvector=[zeros(1,coeff_len+1),inputdata];

        wrenbdata=[ones(1,coeff_len),zeros(1,(numinputvectors+1))];

        wrdonedata=[zeros(1,coeff_len),1,zeros(1,numinputvectors)];


        wraddrdata=[0:coeff_len-1,zeros(1,(numinputvectors+1))];

    else







        inputvector=[zeros(1,coeff_len+1),inputdata,zeros(1,eff_input_vectorlen-numinputvectors),inputdata];

        wrenbdata=[ones(1,coeff_len),zeros(1,(eff_input_vectorlen-coeff_len)),ones(1,coeff_len),zeros(1,(numinputvectors+1))];

        wrdonedata=[zeros(1,coeff_len),1,zeros(1,(eff_input_vectorlen-1)),1,zeros(1,numinputvectors)];


        wraddrdata=[0:coeff_len-1,zeros(1,(eff_input_vectorlen-coeff_len)),0:coeff_len-1,zeros(1,(numinputvectors+1))];

    end
    if~arithisdouble
        inputvector=fi(inputvector,true,filterobj.InputWordLength,filterobj.InputFracLength,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));

        wrenbdata=fi(wrenbdata,false,1,0,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));

        wrdonedata=fi(wrdonedata,false,1,0,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));

        addr_bits=ceil(log2(coeff_len));
        wraddrdata=fi(wraddrdata,false,addr_bits,0,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
    end


    coeffsset1=this.coefficients(1:coeff_len);
    if isempty(hdlgetparameter('tb_coeff_stimulus'))

        if~arithisdouble
            inputdata=fi(inputdata,true,filterobj.InputWordLength,filterobj.InputFracLength,...
            'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
        end
        outdata1=filter(filterobj,inputdata);
        outdata2=[];

        coeffdata=[coeffsset1,zeros(1,(numinputvectors+1))];
    else


        coeffsset2=hdlgetparameter('tb_coeff_stimulus');
        if coeff_len~=length(coeffsset2)
            error(message('HDLShared:hdlfilter:wrongtbcoeffstim',num2str(coeff_len)));
        end
        inputdata1=[inputdata,zeros(1,eff_input_vectorlen-numinputvectors)];

        if~arithisdouble
            indata1=fi(inputdata1,true,filterobj.InputWordLength,filterobj.InputFracLength,...
            'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
        else
            indata1=inputdata1;
        end
        filterobj.persistentmemory=true;
        outdata1=filter(filterobj,indata1);
        if~arithisdouble
            indata2=fi(inputdata,true,filterobj.InputWordLength,filterobj.InputFracLength,...
            'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
            filterobj.CoeffAutoScale=0;
            specifyall(filterobj);
        else
            indata2=inputdata;
        end

        filterobj.numerator=[hdlgetparameter('tb_coeff_stimulus'),zeros(1,(firlen-coeff_len))];
        coeffsset2=filterobj.numerator(1:coeff_len);
        outdata2=filter(filterobj,indata2);

        coeffdata=[coeffsset1,zeros(1,eff_input_vectorlen-coeff_len),coeffsset2,zeros(1,(numinputvectors+1))];
    end
    if~arithisdouble
        coeffdata=fi(coeffdata,filterobj.Signed,filterobj.CoeffWordLength,filterobj.NumFracLength,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
    end
    outdata=[zeros(1,coeff_len+1),outdata1,outdata2];
    indata={inputvector,wrenbdata,wrdonedata,wraddrdata,coeffdata};


    if strcmpi(this.Implementation,'serial')||strcmpi(this.Implementation,'serialcascade')
        fast_loading=1;
        if(fast_loading)
            N_clk=hdlgetparameter('foldingfactor');





            if~strcmpi(hdlgetparameter('filter_storage_type'),'Registers')
                Loading_cycles=ceil((coeff_len+3)/N_clk);
            else
                Loading_cycles=ceil((coeff_len+2)/N_clk);
            end


            outdata=[zeros(1,Loading_cycles),outdata1,outdata2];
            inputvector_fast_load=[inputvector(1:(Loading_cycles)),inputvector((coeff_len+2):end)];

            wrenbdata_filler=wrenbdata(coeff_len+1);
            wraddrdata_filler=wraddrdata(coeff_len+1);
            coeffdata_filler=coeffdata(coeff_len+1);
            wrdonedata_filler=wrdonedata(coeff_len-1);

            if isempty(hdlgetparameter('tb_coeff_stimulus'))
                wrenbdata_fast_load=[wrenbdata(1:coeff_len),repmat(wrenbdata_filler,[1,((Loading_cycles+numinputvectors)*N_clk-coeff_len)])];
                wraddrdata_fast_load=[wraddrdata(1:coeff_len),repmat(wraddrdata_filler,[1,((Loading_cycles+numinputvectors)*N_clk-coeff_len)])];
                coeffdata_fast_load=[coeffdata(1:coeff_len),repmat(coeffdata_filler,[1,((Loading_cycles+numinputvectors)*N_clk-coeff_len)])];
                wrdonedata_fast_load=[wrdonedata(1:(coeff_len+1)),repmat(wrenbdata_filler,[1,((Loading_cycles+numinputvectors)*N_clk-coeff_len-1)])];
            else
                wrenbdata_fast_load=[wrenbdata(1:coeff_len),repmat(wrenbdata_filler,[1,(numinputvectors*N_clk-coeff_len)]),wrenbdata(numinputvectors+1:numinputvectors+coeff_len),repmat(wrenbdata_filler,[1,((Loading_cycles+numinputvectors)*N_clk-coeff_len)])];
                wraddrdata_fast_load=[wraddrdata(1:coeff_len),repmat(wraddrdata_filler,[1,(numinputvectors*N_clk-coeff_len)]),wraddrdata(numinputvectors+1:numinputvectors+coeff_len),repmat(wraddrdata_filler,[1,((Loading_cycles+numinputvectors)*N_clk-coeff_len)])];
                coeffdata_fast_load=[coeffdata(1:coeff_len),repmat(coeffdata_filler,[1,(numinputvectors*N_clk-coeff_len)]),coeffdata(numinputvectors+1:numinputvectors+coeff_len),repmat(coeffdata_filler,[1,((Loading_cycles+numinputvectors)*N_clk-coeff_len)])];
                wrdonedata_fast_load=[wrdonedata(1:(coeff_len+1)),repmat(wrdonedata_filler,[1,(numinputvectors*N_clk-coeff_len-1)]),wrdonedata(numinputvectors+1:numinputvectors+coeff_len+1),repmat(coeffdata_filler,[1,((Loading_cycles+numinputvectors)*N_clk-coeff_len-1)])];
            end
            indata={inputvector_fast_load,wrenbdata_fast_load,wrdonedata_fast_load,wraddrdata_fast_load,coeffdata_fast_load};
        end
    end
