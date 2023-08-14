
































function chipsout=FddLoopableFiltering(chipsin,h,nchips,osr,varargin)


    if(nargin>4)
        extend=varargin{1};
    else
        extend='head';
    end


    if(~any(strcmpi(extend,{'head','tail'})))
        error('umts:error','Method of extending the input for loopability (%s) must be either ''head'' or ''tail''.',extend);
    end


    if(length(h)<osr)
        error('umts:error','Input filter impulse response length (%s) must be greater than or equal to the oversampling ratio (%s).',num2str(length(h)),num2str(osr));
    end


    if(size(chipsin,1)<nchips)

        chipstofilter=chipsin;
    else

        if(strcmpi(extend,'head'))

            chipstofilter=[chipsin;chipsin(1:nchips,:)];
        else

            chipstofilter=[chipsin((end-nchips+1):end,:);chipsin];
        end
    end


    Lx=size(chipstofilter,1);
    ants=size(chipstofilter,2);
    Lh=length(h);
    Ly=ceil((Lx-1)*osr+Lh);


    chipsout=zeros(Ly,ants);
    for i=1:size(chipstofilter,2)
        chipsout(:,i)=upfirdn(chipstofilter(:,i),h,osr,1);
    end


    if(size(chipsin,1)>=nchips)
        chipsout(1:(nchips*osr),:)=[];
        chipsout=chipsout(1:(size(chipsin,1)*osr),:);
    end

end