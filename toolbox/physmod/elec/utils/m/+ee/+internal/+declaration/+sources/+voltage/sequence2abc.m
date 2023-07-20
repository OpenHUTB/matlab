function[abc_harmonic_orders,abc_harmonic_ratios,a_harmonic_shifts,b_harmonic_shifts,c_harmonic_shifts]=sequence2abc(harmonic_orders,harmonic_ratios,harmonic_shifts,harmonic_sequences)%#codegen




    coder.allowpcode('plain');


    nHarmonics=length(harmonic_orders);





    abc_harmonic_orders=zeros(nHarmonics,1);
    abc_harmonic_ratios=zeros(nHarmonics,1);
    a_harmonic_shifts=zeros(nHarmonics,1);
    b_harmonic_shifts=zeros(nHarmonics,1);
    c_harmonic_shifts=zeros(nHarmonics,1);


    if isrow(harmonic_orders)
        harmonic_orders_tmp=harmonic_orders;
    else
        harmonic_orders_tmp=harmonic_orders';
    end
    if isrow(harmonic_ratios)
        harmonic_ratios_tmp=harmonic_ratios;
    else
        harmonic_ratios_tmp=harmonic_ratios';
    end
    if isrow(harmonic_shifts)
        harmonic_shifts_tmp=harmonic_shifts;
    else
        harmonic_shifts_tmp=harmonic_shifts';
    end
    if isrow(harmonic_sequences)
        harmonic_sequences_tmp=harmonic_sequences;
    else
        harmonic_sequences_tmp=harmonic_sequences';
    end

    if any(harmonic_sequences_tmp<0)||any(harmonic_sequences_tmp>2)
        pm_error('physmod:ee:library:RelatedMaskParameters',getString(message('physmod:ee:library:comments:utils:declaration:sources:sequence2abc:error_HarmonicSequenceVectorMustBe01Or2')))
    end

    isZeroSequence=(harmonic_sequences_tmp==0);
    isPosSequence=(harmonic_sequences_tmp==1);
    isNegSequence=(harmonic_sequences_tmp==2);

    abc_harmonic_orders(1:nHarmonics)=harmonic_orders_tmp;
    abc_harmonic_ratios(1:nHarmonics)=harmonic_ratios_tmp;
    a_harmonic_shifts(1:nHarmonics)=harmonic_shifts_tmp;
    b_harmonic_shifts(1:nHarmonics)=harmonic_shifts_tmp.*isZeroSequence...
    +(harmonic_shifts_tmp+4*pi/3).*isPosSequence...
    +(harmonic_shifts_tmp+2*pi/3).*isNegSequence;
    c_harmonic_shifts(1:nHarmonics)=harmonic_shifts_tmp.*isZeroSequence...
    +(harmonic_shifts_tmp+2*pi/3).*isPosSequence...
    +(harmonic_shifts_tmp+4*pi/3).*isNegSequence;

end