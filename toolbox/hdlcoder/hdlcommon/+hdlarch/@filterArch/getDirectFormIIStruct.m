function tfComp=getDirectFormIIStruct(hN,hInSignals,hOutSignals,...
    Numerator,...
    Denominator,...
    StateDataType,...
    a0EqualsOne,...
    NumProductDataType,...
    DenProductDataType,...
    NumAccumDataType,...
    DenAccumDataType,...
    rndMode,...
    satMode,...
    convMode,...
    constMultiplierOptimMode,...
    gainMode,...
    resetnone,...
    InitialStates,...
    ~,...
    ~,...
    nfpOptions)









    if nargin<21
        nfpOptions.Latency=int8(0);
        nfpOptions.MantMul=int8(0);
        nfpOptions.Denormals=int8(0);
    end


    s_nw_in=hInSignals(1);
    s_nw_out=hOutSignals(1);
    hOutType=s_nw_out.Type;




    if isempty(find(double(Numerator),1))

        s_output_cast=hN.addSignal(hOutType,'s_output_cast');
        tfComp=pirelab.getConstComp(hN,s_output_cast,0,...
        'constZero');
        s_nw_out.SimulinkRate=s_nw_in.SimulinkRate;
        s_output_cast.SimulinkRate=s_nw_in.SimulinkRate;
        pirelab.getWireComp(hN,s_output_cast,s_nw_out);
        return;
    end



    s_input_acc_cast=hN.addSignal(DenAccumDataType,'s_input_acc_cast');
    pirelab.getDTCComp(hN,s_nw_in,s_input_acc_cast,...
    rndMode,satMode,convMode,'input_acc_cast',...
    '',-1,nfpOptions);




    L_d=length(Denominator);




    exist_denom_accum=false;
    comp_count=0;
    for i=1:L_d-1
        if~(double(Denominator(i+1))==0)
            comp_count=comp_count+1;
            exist_denom_accum=true;




            name_str=['s_denom_acc_cast',num2str(i)];
            s_denom_acc_cast(comp_count)=...
            hN.addSignal(DenAccumDataType,name_str);%#ok<AGROW>

            name_str=['s_denom_acc_out',num2str(i)];
            s_denom_acc_out(comp_count)=...
            hN.addSignal(DenAccumDataType,name_str);%#ok<AGROW>



            name_str=['denom_acc',num2str(i)];
            if(comp_count==1)
                pirelab.getAddComp(hN,[s_input_acc_cast...
                ,s_denom_acc_cast(comp_count)],...
                s_denom_acc_out(comp_count),...
                rndMode,satMode,name_str,...
                s_denom_acc_out(comp_count).Type,...
                '+-','',-1,nfpOptions);
            else
                pirelab.getAddComp(hN,[s_denom_acc_out(comp_count-1)...
                ,s_denom_acc_cast(comp_count)],...
                s_denom_acc_out(comp_count),...
                rndMode,satMode,name_str,...
                s_denom_acc_out(comp_count).Type,...
                '+-','',-1,nfpOptions);
            end
        end
    end




    if exist_denom_accum
        s_scaling_comp_in=s_denom_acc_out(length(s_denom_acc_out));
    else
        s_scaling_comp_in=s_input_acc_cast;
    end


    s_denom_scale_by_a0=hN.addSignal(DenAccumDataType,'s_denom_scale_by_a0');
    name_str='denom_scale_by_a0';
    if((strcmp(a0EqualsOne,'on'))||(double(Denominator(1))==1))
        pirelab.getWireComp(hN,s_scaling_comp_in,s_denom_scale_by_a0,...
        name_str);
    elseif(double(Denominator(1))==-1)
        pirelab.getUnaryMinusComp(hN,s_scaling_comp_in,s_denom_scale_by_a0,...
        satMode,name_str);
    else
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
    end




    s_state_cast=hN.addSignal(StateDataType,'s_state_cast');
    pirelab.getDTCComp(hN,s_denom_scale_by_a0,s_state_cast,...
    rndMode,satMode,convMode,...
    'state_cast','',-1,nfpOptions);




    s_state_out=hdlhandles(L_d-1,1);
    for i=1:L_d-1
        name_str=['s_state_out',num2str(i)];
        s_state_out(i)=hN.addSignal(StateDataType,name_str);
        if(i==1)
            pirelab.getUnitDelayComp...
            (hN,s_state_cast,s_state_out(i),name_str,...
            InitialStates(i),resetnone);
        else
            pirelab.getUnitDelayComp...
            (hN,s_state_out(i-1),s_state_out(i),name_str,...
            InitialStates(i),resetnone);
        end
    end




    comp_count=0;
    for i=1:L_d-1
        if~(double(Denominator(i+1))==0)
            comp_count=comp_count+1;



            name_str=['s_denom_gain',num2str(i)];
            s_denom_gain(comp_count)=hN.addSignal(DenProductDataType,name_str);%#ok<AGROW>



            name_str=['denom_gain',num2str(i)];
            if(double(Denominator(i+1))==1)
                pirelab.getDTCComp(hN,s_state_out(i),s_denom_gain(comp_count),...
                rndMode,satMode,convMode,name_str,'',-1,nfpOptions);
            else
                pirelab.getGainComp(hN,s_state_out(i),...
                s_denom_gain(comp_count),...
                Denominator(i+1),...
                gainMode,...
                constMultiplierOptimMode,...
                rndMode,satMode,name_str,...
                int8(0),'',[],false,nfpOptions);
            end



            name_str=['denom_acc_cast',num2str(i)];
            pirelab.getDTCComp(hN,s_denom_gain(comp_count),...
            s_denom_acc_cast(comp_count),...
            rndMode,satMode,convMode,name_str,...
            '',-1,nfpOptions);
        end
    end




    if~(double(Numerator(1))==0)
        s_nume_gain_b0=hN.addSignal(NumProductDataType,'s_nume_gain_b0');
        if(double(Numerator(1))==1)
            pirelab.getDTCComp(hN,s_state_cast,s_nume_gain_b0,...
            rndMode,satMode,convMode,'nume_gain_b0',...
            '',-1,nfpOptions);
        else
            pirelab.getGainComp(hN,s_state_cast,...
            s_nume_gain_b0,...
            Numerator(1),...
            gainMode,constMultiplierOptimMode,...
            rndMode,satMode,'nume_gain_b0',...
            int8(0),'',[],false,nfpOptions);
        end
        s_nume_gain_b0_cast=...
        hN.addSignal(NumAccumDataType,'s_nume_gain_b0_cast');
        pirelab.getDTCComp(hN,s_nume_gain_b0,s_nume_gain_b0_cast,...
        rndMode,satMode,convMode,'nume_gain_b0_cast',...
        '',-1,nfpOptions);
    end





    L_n=length(Numerator);

    comp_count=0;
    for i=1:L_n-1
        if~(double(Numerator(i+1))==0)
            comp_count=comp_count+1;



            name_str=['s_nume_gain',num2str(i)];
            s_nume_gain(comp_count)=hN.addSignal(NumProductDataType,name_str);%#ok<AGROW>



            name_str=['nume_gain',num2str(i)];
            if(double(Numerator(i+1))==1)
                pirelab.getDTCComp(hN,s_state_out(i),s_nume_gain(comp_count),...
                rndMode,satMode,convMode,name_str,'',-1,nfpOptions);
            else
                pirelab.getGainComp(hN,s_state_out(i),...
                s_nume_gain(comp_count),...
                Numerator(i+1),...
                gainMode,constMultiplierOptimMode,...
                rndMode,satMode,name_str,...
                int8(0),'',[],false,nfpOptions);
            end



            name_str=['s_nume_acc_cast',num2str(i)];
            s_nume_acc_cast(comp_count)=...
            hN.addSignal(NumAccumDataType,name_str);%#ok<AGROW>
            name_str=['nume_acc_cast',num2str(i)];
            pirelab.getDTCComp(hN,s_nume_gain(comp_count),...
            s_nume_acc_cast(comp_count),...
            rndMode,satMode,convMode,name_str,...
            '',-1,nfpOptions);
        end
    end
    numb_of_non_zero_nume_gain_excluing_b0=comp_count;




    b0_is_zero=(double(Numerator(1))==0);

    if b0_is_zero
        numb_off_nume_accum=numb_of_non_zero_nume_gain_excluing_b0-1;
        if numb_off_nume_accum>0
            s_nume_acc_out=hdlhandles(numb_off_nume_accum,1);
            for i=1:numb_off_nume_accum
                if i==1
                    accum_input1=s_nume_acc_cast(i);
                else
                    accum_input1=s_nume_acc_out(i-1);
                end
                accum_input2=s_nume_acc_cast(i+1);
                name_str=['s_nume_acc_out',num2str(i)];
                s_nume_acc_out(i)=hN.addSignal(NumAccumDataType,name_str);
                name_str=['s_nume_acc',num2str(i)];
                pirelab.getAddComp(hN,...
                [accum_input1...
                ,accum_input2],...
                s_nume_acc_out(i),...
                rndMode,satMode,name_str,...
                [],'++','',-1,nfpOptions);
            end
        end
    else
        numb_off_nume_accum=numb_of_non_zero_nume_gain_excluing_b0;
        if numb_off_nume_accum>0
            s_nume_acc_out=hdlhandles(numb_off_nume_accum,1);
            for i=1:numb_off_nume_accum
                if i==1
                    accum_input1=s_nume_gain_b0_cast;
                else
                    accum_input1=s_nume_acc_out(i-1);
                end
                accum_input2=s_nume_acc_cast(i);
                name_str=['s_nume_acc_out',num2str(i)];
                s_nume_acc_out(i)=hN.addSignal(NumAccumDataType,name_str);
                name_str=['s_nume_acc',num2str(i)];
                pirelab.getAddComp(hN,...
                [accum_input1...
                ,accum_input2],...
                s_nume_acc_out(i),...
                rndMode,satMode,name_str,...
                [],'++','',-1,nfpOptions);
            end
        end
    end

    if numb_off_nume_accum>0
        exist_nume_accum=true;
    else
        exist_nume_accum=false;
    end





    s_output_cast=hN.addSignal(hOutType,'s_output_cast');
    if exist_nume_accum
        tfComp=pirelab.getDTCComp(hN,s_nume_acc_out(numb_off_nume_accum),...
        s_output_cast,rndMode,satMode,convMode,...
        'output_cast','',-1,nfpOptions);
    elseif~(double(Numerator(1))==0)
        tfComp=pirelab.getDTCComp(hN,s_nume_gain_b0_cast,...
        s_output_cast,rndMode,satMode,convMode,...
        'output_cast','',-1,nfpOptions);
    else
        tfComp=pirelab.getDTCComp(hN,s_nume_acc_cast(1),...
        s_output_cast,rndMode,satMode,convMode,...
        'output_cast','',-1,nfpOptions);
    end

    pirelab.getWireComp(hN,s_output_cast,s_nw_out);


end



