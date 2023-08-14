function[initial_seed,T]=initialize_noise_private(repeatability,auto_seed,user_seed,sample_time)%#codegen




    coder.allowpcode('plain');

    if sample_time(1)>0
        T=sample_time(1);
    else

        T=1;
    end


    switch int32(repeatability)
    case 1
        initial_seed=randi(2^32-1);
    case 2
        initial_seed=auto_seed;
    otherwise
        initial_seed=user_seed;
    end

end