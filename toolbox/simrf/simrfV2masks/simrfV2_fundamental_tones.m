function[tones,harmonics]=simrfV2_fundamental_tones(input_freqs,...
    freqs_of_interest)

















    input_freqs=prepare_freqs(input_freqs);
    freqs=prepare_freqs([input_freqs,freqs_of_interest(:)']);

    tones=[];
    harmonics=[];
    if isempty(freqs)
        tones=0;
        harmonics=1;
        return;
    elseif numel(freqs)==1
        tones=freqs(1);
        harmonics=7;
        return;
    end


    max_harmonics=[100,10,8,5];


    num_inputs=length(input_freqs);
    if num_inputs<15
        max_num_fundamentals=4;
    elseif num_inputs<25
        max_num_fundamentals=3;
    elseif num_inputs<300
        max_num_fundamentals=2;
    else
        max_num_fundamentals=1;
    end
    max_num_fundamentals=min(max_num_fundamentals,length(input_freqs));


    for num_fundamentals=1:max_num_fundamentals
        harms=max_harmonics(num_fundamentals);
        [current_tones,current_harmonics]=fundamental_tones_n(input_freqs...
        ,freqs,num_fundamentals,harms);

        if isempty(current_tones)
            continue
        end

        if isempty(harmonics)||...
            num_carriers(current_harmonics)<num_carriers(harmonics)
            harmonics=current_harmonics;
            tones=current_tones;
        end
    end


    if isempty(harmonics)





        if~isequal(input_freqs,freqs)
            [tones,harmonics]=simrfV2_fundamental_tones(freqs,freqs);
        else
            tones=freqs;
            harmonics=ones(size(freqs));
        end
    end





    switch numel(tones)
    case 1
        harmonics=max(7,harmonics);
    case 2
        harmonics=max([5,5],harmonics);
    case 3
        harmonics=max([3,3,3],harmonics);
    end

end

function n=num_carriers(harmonics)
    n=prod(2*harmonics+1);
end















function[tones,harmonics]=fundamental_tones_n(input_freqs,...
    freqs,num_fundamentals,max_harmonics)

    tones=[];
    harmonics=ones(1,num_fundamentals)*max_harmonics;

    if num_fundamentals==1
        tone=input_freqs(1);
        ratio=freqs/tone;

        if all(abs(round(ratio)-ratio)<1e-8)&&max(ratio)<=max_harmonics
            tones=tone;
            harmonics=max(round(ratio));
        else
            harmonics=[];
        end
        return;
    end

    all_harmonics=list_all_harmonics(num_fundamentals,max_harmonics);

    all_harmonics_weight=sum(abs(all_harmonics'));
    [~,order]=sort(all_harmonics_weight);

    all_harmonics=all_harmonics(order,:);

    possible_fundamentals=nchoosek(input_freqs,num_fundamentals);






    for i=1:size(possible_fundamentals,1)
        current_tones=possible_fundamentals(i,:)';

        covered_freqs=abs(all_harmonics*current_tones);



        covered=true;
        for j=1:length(freqs)
            f=freqs(j);
            threshold=1e-8*max(1,f);
            if all(abs(covered_freqs-f)>threshold)

                covered=false;
                break;
            end
        end
        if~covered
            continue;
        end;





        current_harmonics=zeros(size(harmonics));
        for j=1:length(freqs)
            f=freqs(j);
            threshold=1e-8*max(1,f);
            h=find(abs(covered_freqs-f)<threshold,1);
            current_harmonics=max(current_harmonics,abs(all_harmonics(h,:)));
        end

        if sum(harmonics)>sum(current_harmonics)
            harmonics=current_harmonics;
            tones=current_tones';
        end
    end

    if isempty(tones)
        harmonics=[];
    end
end

function f=prepare_freqs(freqs)
    f=unique(abs(freqs(:)'));
    if~isempty(f)&&f(1)==0
        f=f(2:end);
    end
end

function K=list_all_harmonics(ntones,max_harmonics)

    harmonics=ones(1,ntones)*max_harmonics;

    allfreqs=prod(2*harmonics+1);
    nfreqs=(allfreqs-1)/2+1;
    K=zeros(nfreqs,ntones);
    x=(nfreqs:allfreqs)'-1;
    for j=1:ntones

        y=2*harmonics(j)+1;
        n=floor(x/y);
        K(:,j)=x-n*y-harmonics(j);
        x=n;
    end
end