function[points1a,points2]=mysmith(varargin)



    narginchk(0,5)
    switch nargin
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
    case 3
        [div1,div2,resolution]=deal(varargin{:});
        style='Solid';
        thresholdfactor=.4;
...
...
...
...
...
...
...
    end

    div2=flip(div2);
    points1a=[];
    div1=sort(div1,'descend');
    div1(end+1)=0;
    div1factor=2^resolution;

    spanpoints=65;

    fullspan{1,length(div1)}=linspace(0,div1(end-1),spanpoints);
    for idx=(length(div1)-1):-1:2
        fullspan{idx}=logspace(log10(div1(idx)),log10(div1(idx-1)),spanpoints);



    end
    fullspan{1}=cell(1,7);
    for ridx=0:6
        fullspan{1}{ridx+1}=logspace(log10(div1(1)*2^ridx),log10(div1(1)*2^(ridx+1)),2^(7-ridx)+1);
    end
    fullspan{1}=[fullspan{1}{:},Inf];
    points2=[];
    for idx=0:(length(div1)-1)

        span=cell(1,length(div1));
        if isempty(div2)
            for spanidx=(length(div1)-idx):-1:1
                span{spanidx}=fullspan{spanidx+idx}(1:2^(spanidx-1):end);
            end
        else
            for spanidx=length(div1):-1:1
                span{spanidx}=fullspan{spanidx}(1:end);
            end
        end
        span=[span{end:-1:1}];

        if idx==0
            subdiv1=div1(1)*div1factor./(0:div1factor);
        else
            subdiv1=linspace(div1(idx),div1(idx+1),div1factor+1);
            subdiv1(subdiv1==0)=[];
            points2=[points2,-mymap(div1(idx)+1i*span),NaN...
            ,-mymap(div1(idx)-1i*span),NaN...
            ,-mymap(span+div1(idx)*1i),NaN...
            ,-mymap(span-div1(idx)*1i),NaN];
        end

        colormat=repmat((idx==(length(div1)-1)),1,div1factor);
        for coloridx=1:resolution
            colormat=colormat+~mod(1:div1factor,2^coloridx);
        end

        for subidx=2:length(subdiv1)


            colorfactor=colormat(subidx-1);
            grayscale=1-[1,1,1]*(colorfactor+1-(idx==(length(div1)-1)))/(resolution+1);
            threshold=1-(grayscale<=thresholdfactor);

            if threshold(1)
                continue
            end

            if strcmp(style,'Solid')
                plotcolor=threshold;
            else
                plotcolor=grayscale;
            end

            if isempty(div2)
                extrafactor=min(idx,colorfactor);
                extra=cell(1,extrafactor);
                for subspanidx=0:extrafactor
                    if subspanidx
                        extra{subspanidx}=fullspan{idx-subspanidx+1};
                    end
                end
                extra=[extra{:}];
                points1=[span,extra];
            else
                points1=span;
                layer=points1<=div2(end-idx);
                points1=points1(layer);
            end
            points1a=[points1a,-mymap(subdiv1(subidx)+1i*points1),NaN...
            ,-mymap(subdiv1(subidx)-1i*points1),NaN...
            ,-mymap(points1+subdiv1(subidx)*1i),NaN...
            ,-mymap(points1-subdiv1(subidx)*1i),NaN];
        end
    end
end

function mappoints=mymap(points)


    mappoints=(1-points)./(1+points);

    if isnan(mappoints(end))
        mappoints(isnan(mappoints))=complex(-1,0);
    end

end