function[indata,outdata]=genVecDataforProc(this,filterobj,inputdata,arithisdouble)







    num_of_coeffs_in=1;
    for count_i=1:this.NumSections
        if this.SectionOrder(count_i)==1
            num_of_coeffs_in=num_of_coeffs_in+4;
        else
            num_of_coeffs_in=num_of_coeffs_in+6;
        end
    end

    numinputvectors=length(inputdata);
    eff_input_vectorlen=max(numinputvectors,num_of_coeffs_in);















    wr_addr_values=[];
    for count_i=1:this.NumSections
        if this.SectionOrder(count_i)==1
            wr_addr_values=[wr_addr_values,(8*(count_i-1)+[0:2,4])];
        else
            wr_addr_values=[wr_addr_values,(8*(count_i-1)+[0:3,[4:5]])];
        end
    end
    wr_addr_values=[wr_addr_values,7];

    if isempty(hdlgetparameter('tb_coeff_stimulus'))






        inputvector=[zeros(1,num_of_coeffs_in+1),inputdata];

        wrenbdata=[ones(1,num_of_coeffs_in),zeros(1,(numinputvectors+1))];

        wrdonedata=[zeros(1,num_of_coeffs_in),1,zeros(1,numinputvectors)];


        wraddrdata=[wr_addr_values,zeros(1,(numinputvectors+1))];

    else







        inputvector=[zeros(1,num_of_coeffs_in+1),inputdata,zeros(1,eff_input_vectorlen-numinputvectors),inputdata];

        wrenbdata=[ones(1,num_of_coeffs_in),zeros(1,(eff_input_vectorlen-num_of_coeffs_in)),ones(1,num_of_coeffs_in),zeros(1,(numinputvectors+1))];

        wrdonedata=[zeros(1,num_of_coeffs_in),1,zeros(1,(eff_input_vectorlen-1)),1,zeros(1,numinputvectors)];


        wraddrdata=[wr_addr_values,zeros(1,(eff_input_vectorlen-num_of_coeffs_in)),wr_addr_values,zeros(1,(numinputvectors+1))];

    end
    if~arithisdouble
        inputvector=fi(inputvector,true,filterobj.InputWordLength,filterobj.InputFracLength,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));

        wrenbdata=fi(wrenbdata,false,1,0,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));

        wrdonedata=fi(wrdonedata,false,1,0,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));

        addr_bits=ceil(log2(this.NumSections))+3;
        wraddrdata=fi(wraddrdata,false,addr_bits,0,...
        'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
    end


    coeffsset1=generate_coeffsset(this,filterobj,{this.ScaleValues,this.coefficients},arithisdouble);
    old_coeffAutoScale=[];
    old_OptimizeScaleValues=[];

    if isempty(hdlgetparameter('tb_coeff_stimulus'))

        if~arithisdouble
            inputdata=fi(inputdata,true,filterobj.InputWordLength,filterobj.InputFracLength,...
            'fimath',fimath('RoundMode','round','OverflowMode','saturate'));





            old_coeffAutoScale=filterobj.CoeffAutoScale;
            old_OptimizeScaleValues=filterobj.OptimizeScaleValues;
            filterobj.CoeffAutoScale=0;
            filterobj.OptimizeScaleValues=0;
        end

        outdata1=filter(filterobj,inputdata);
        outdata2=[];

        zero_vec=zeros(1,(numinputvectors+1));
        if~arithisdouble
            zero_vec=fi(zero_vec,filterobj.Signed,filterobj.CoeffWordLength,0,'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
            filterobj.CoeffAutoScale=old_coeffAutoScale;
            filterobj.OptimizeScaleValues=old_OptimizeScaleValues;
        end
        coeffdata=[coeffsset1,zero_vec];
    else




        input_coeff_stimulus=hdlgetparameter('tb_coeff_stimulus');
        if((numel(input_coeff_stimulus)==1)||(numel(input_coeff_stimulus)==2))
            tb_coeff_stimulus_value={this.ScaleValues,this.coefficients};
            flag_1=0;
            flag_2=0;
            for count_i=1:numel(input_coeff_stimulus)
                if(size(input_coeff_stimulus{count_i})==size(this.ScaleValues))
                    tb_coeff_stimulus_value{1}=input_coeff_stimulus{count_i};
                    flag_1=1;
                elseif(size(input_coeff_stimulus{count_i})==size(this.ScaleValues.'))
                    tb_coeff_stimulus_value{1}=input_coeff_stimulus{count_i}.';
                    flag_1=1;
                elseif(size(input_coeff_stimulus{count_i})==size(this.coefficients))
                    tb_coeff_stimulus_value{2}=input_coeff_stimulus{count_i};
                    flag_2=1;
                end
            end
            if((flag_1+flag_2)~=numel(input_coeff_stimulus))
                error(message('HDLShared:hdlfilter:wrongtbcoeffstim1',num2str(this.numSection+1),num2str(size(this.coefficients),'%d x %d')));
            elseif flag_2

                Old_1st_orders=floor((~any(this.coefficients(:,3),3)+~any(this.coefficients(:,6),3))/2);
                New_1st_orders=floor((~any(tb_coeff_stimulus_value{2}(:,3),3)+~any(tb_coeff_stimulus_value{2}(:,6),3))/2);
                if(sum(bitxor(Old_1st_orders,New_1st_orders)))
                    Sections=find(bitxor(Old_1st_orders,New_1st_orders).');
                    Msg=[num2str(Sections(1:end-1),'%d,'),num2str(Sections(end),'%d')];
                    error(message('HDLShared:hdlfilter:wrongtbcoeffstim2',Msg));
                end
            end
        else
            error(message('HDLShared:hdlfilter:wrongtbcoeffstim3'));
        end

        coeffsset2=generate_coeffsset(this,filterobj,tb_coeff_stimulus_value,arithisdouble);
        inputdata1=[inputdata,zeros(1,eff_input_vectorlen-numinputvectors)];

        if~arithisdouble
            indata1=fi(inputdata1,true,filterobj.InputWordLength,filterobj.InputFracLength,...
            'fimath',fimath('RoundMode','round','OverflowMode','saturate'));





            old_coeffAutoScale=filterobj.CoeffAutoScale;
            old_OptimizeScaleValues=filterobj.OptimizeScaleValues;
            filterobj.CoeffAutoScale=0;
            filterobj.OptimizeScaleValues=0;
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

        filterobj.ScaleValues=tb_coeff_stimulus_value{1};
        filterobj.sosMatrix=tb_coeff_stimulus_value{2};
        outdata2=filter(filterobj,indata2);

        zero_vec=zeros(1,(numinputvectors+1));
        zero_vec1=zeros(1,(eff_input_vectorlen-num_of_coeffs_in));
        if~arithisdouble
            zero_vec=fi(zero_vec,filterobj.Signed,filterobj.CoeffWordLength,0,'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
            zero_vec1=fi(zero_vec1,filterobj.Signed,filterobj.CoeffWordLength,0,'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
            filterobj.CoeffAutoScale=old_coeffAutoScale;
            filterobj.OptimizeScaleValues=old_OptimizeScaleValues;
        end
        coeffdata=[coeffsset1,zero_vec1,coeffsset2,zero_vec];
    end

    outdata=[zeros(1,num_of_coeffs_in+1),outdata1,outdata2];
    indata={inputvector,wrenbdata,wrdonedata,wraddrdata,coeffdata};


    function[coeffsset]=generate_coeffsset(this,filterobj,stimulus,arithisdouble)

        scaleValues=stimulus{1};
        sosMatrix=stimulus{2};
        coeffsset=[];
        for count_i=1:this.NumSections

            if~arithisdouble
                scale_value=fi(scaleValues(count_i),filterobj.Signed,filterobj.CoeffWordLength,filterobj.ScaleValueFracLength,'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
                new_value=fi(scaleValues(count_i),filterobj.Signed,filterobj.CoeffWordLength,0,'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
                new_value.hex=scale_value.hex;
                coeffsset=[coeffsset,new_value];
                clear new_value;
            else
                coeffsset=[coeffsset,scaleValues(count_i)];
            end

            if this.SectionOrder(count_i)==1
                if~arithisdouble
                    num_value=fi(sosMatrix(count_i,[1:2]),filterobj.Signed,filterobj.CoeffWordLength,filterobj.NumFracLength,'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
                    new_value=fi(sosMatrix(count_i,[1:2]),filterobj.Signed,filterobj.CoeffWordLength,0,'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
                    new_value.hex=num_value.hex;
                    coeffsset=[coeffsset,new_value];
                    clear new_value;
                    den_value=fi(sosMatrix(count_i,5),filterobj.Signed,filterobj.CoeffWordLength,filterobj.DenFracLength,'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
                    new_value=fi(sosMatrix(count_i,5),filterobj.Signed,filterobj.CoeffWordLength,0,'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
                    new_value.hex=den_value.hex;
                    coeffsset=[coeffsset,new_value];
                    clear new_value;
                else
                    coeffsset=[coeffsset,sosMatrix(count_i,[1:2])];
                    coeffsset=[coeffsset,sosMatrix(count_i,5)];
                end
            else
                if~arithisdouble
                    num_value=fi(sosMatrix(count_i,[1:3]),filterobj.Signed,filterobj.CoeffWordLength,filterobj.NumFracLength,'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
                    new_value=fi(sosMatrix(count_i,[1:3]),filterobj.Signed,filterobj.CoeffWordLength,0,'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
                    new_value.hex=num_value.hex;
                    coeffsset=[coeffsset,new_value];
                    clear new_value;
                    den_value=fi(sosMatrix(count_i,[5:6]),filterobj.Signed,filterobj.CoeffWordLength,filterobj.DenFracLength,'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
                    new_value=fi(sosMatrix(count_i,[5:6]),filterobj.Signed,filterobj.CoeffWordLength,0,'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
                    new_value.hex=den_value.hex;
                    coeffsset=[coeffsset,new_value];
                    clear new_value;
                else
                    coeffsset=[coeffsset,sosMatrix(count_i,[1:3])];
                    coeffsset=[coeffsset,sosMatrix(count_i,[5:6])];
                end
            end
        end
        if~arithisdouble
            scale_value=fi(scaleValues(this.NumSections+1),filterobj.Signed,filterobj.CoeffWordLength,filterobj.ScaleValueFracLength,'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
            new_value=fi(scaleValues(this.NumSections+1),filterobj.Signed,filterobj.CoeffWordLength,0,'fimath',fimath('RoundMode','round','OverflowMode','saturate'));
            new_value.hex=scale_value.hex;
            coeffsset=[coeffsset,new_value];
            clear new_value;
        else
            coeffsset=[coeffsset,scaleValues(this.NumSections+1)];
        end


