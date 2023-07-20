function[resp,delay]=response(h,transf)








    if isempty(transf)||(isa(h,'rfbbequiv.linear')&&h.AllPassFilter)
        transf=ones(1,2^ceil(log2(h.MaxLength)));
    elseif length(transf)==1
        transf(1:2^ceil(log2(h.MaxLength)))=transf(1);
    end


    fracbw=get(h,'FracBW');
    modeldelay=get(h,'ModelDelay');
    L=numel(transf);
    tw=rftukeywin(L,fracbw).*exp(2j*pi*(-modeldelay/L)*((1:L).'));


    ifft_input=fftshift(tw.*transf(:));
    resp=ifft(ifft_input);


    maxlen=get(h,'MaxLength');
    rlength=numel(resp);
    if rlength>maxlen
        resp=resp(1:maxlen);
    end


    imp_max=max(abs(resp));
    save_ind=find(abs(resp)==imp_max);
    if isempty(save_ind)
        delay=0;
    else
        delay=save_ind(1)-1;
    end
    resp=resp(:);


    function w=rftukeywin(n,r)


        if nargin<2||isempty(r),
            r=0.500;
        end

        w=[];
        trivialwin=0;

        if~(isnumeric(n)&&isfinite(n)),
            error(message('rfblks:rfbbequiv:rfbbequiv:rftukeywin:invalidorder_inf'));
        end


        if n<0,
            error(message('rfblks:rfbbequiv:rfbbequiv:rftukeywin:invalidorder_neg'));
        end



        if~(isempty(n)||n==floor(n)),
            n=round(n);
            warning(message('rfblks:rfbbequiv:rfbbequiv:rftukeywin:invalidorder_round'));
        end


        if isempty(n)||n==0,
            w=zeros(0,1);
            trivialwin=1;
        elseif n==1,
            w=1;
            trivialwin=1;
        end

        if trivialwin,return,end;

        if r<=0,
            w=ones(n,1);
        elseif r>=1,
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