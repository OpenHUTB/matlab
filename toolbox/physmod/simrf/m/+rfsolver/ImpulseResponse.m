










function imp=ImpulseResponse(step,num_steps,carrier,...
    sampling_freqs,data,variableToShift)

    assert(size(sampling_freqs,2)==size(data,2));
    assert(length(num_steps)==size(data,1));
    assert(carrier>=min(sampling_freqs)&&carrier<=max(sampling_freqs));






    imp=zeros(size(data,1),max(num_steps));
    for i=1:size(data,1)
        n=num_steps(i);
        imp(i,1:n)=impulse(sampling_freqs,data(i,:),n,variableToShift(i));
    end

    if abs(carrier)<1e-9
        imp=real(imp);
    end


    if length(sampling_freqs)>1
        practice=sum(imp,2);
        theory=interp1(sampling_freqs,data.',carrier).';
        diff=norm(practice-theory)/max(norm(practice),1e-6);
    end









    assert(size(imp,1)==size(data,1),'number of variables does not match');
end




function imp=impulse(sampling_freqs,data,num_steps,shift)





    if num_steps<size(data,2)/2&&num_steps>0
        fft_length=2^(ceil(log2(num_steps)));
        downsampling=round(size(data,2)/fft_length);
        data=data(1:downsampling:end);
        sampling_freqs=sampling_freqs(1:downsampling:end);
    end





    nfreqs=size(data,2);
    if nfreqs>30
        w=rftukeywin(nfreqs,0.2)';
        midpoint=sum(data.*(1-w))./sum(1-w);
        data=data.*w+midpoint*(1-w);
    end



    if((logical(shift))&&(length(sampling_freqs)>1))
        data=data.*exp(-1j*2*pi*...
        ((sampling_freqs/(sampling_freqs(2)-sampling_freqs(1)))*...
        (floor(num_steps/2)/size(data,2))));
    end

    imp=ifft(ifftshift(data,2),[],2);







    if num_steps>0&&num_steps<size(imp,2)
        tail=sum(imp(:,num_steps+1:end),2);
        imp=imp(:,1:num_steps);
        imp(:,1)=imp(:,1)+tail;
    end




    if(double(shift)==2)
        imp=imp.*(rfhann(size(imp,2)).');
    end

end



function w=rfhann(L)
    if isempty(L)||L==0
        w=zeros(0,1);
    elseif L==1
        w=1;
    else
        w=0.5*(1-cos(2*pi*(0:L-1)'/(L-1)));
    end
end




function w=rftukeywin(n,r)


    if nargin<2||isempty(r)
        r=0.500;
    end

    w=[];
    trivialwin=0;

    if~(isnumeric(n)&&isfinite(n))
        error(message('rfblks:rfbbequiv:rfbbequiv:rftukeywin:invalidorder_inf'));
    end


    if n<0
        error(message('rfblks:rfbbequiv:rfbbequiv:rftukeywin:invalidorder_neg'));
    end



    if~(isempty(n)||n==floor(n))
        n=round(n);
        warning(message('rfblks:rfbbequiv:rfbbequiv:rftukeywin:invalidorder_round'));
    end


    if isempty(n)||n==0
        w=zeros(0,1);
        trivialwin=1;
    elseif n==1
        w=1;
        trivialwin=1;
    end

    if trivialwin,return,end

    if r<=0
        w=ones(n,1);
    elseif r>=1
        if~rem(n,2)
            half=n/2;
        else
            half=(n+1)/2;
        end

        x=(0:half-1)'/(n-1);
        w=0.5-0.5*cos(2*pi*x);

        if~rem(n,2)
            w=[w;w(end:-1:1)];
        else
            w=[w;w(end-1:-1:1)];
        end
    else
        t=linspace(0,1,n)';

        per=r/2;
        tl=floor(per*(n-1))+1;
        th=n-tl+1;

        w=[((1+cos(pi/per*(t(1:tl)-per)))/2);ones(th-tl-1,1);...
        ((1+cos(pi/per*(t(th:end)-1+per)))/2)];
    end

end