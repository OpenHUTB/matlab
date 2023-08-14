function Feededge=feeding_edge(p,Edge_,FeedPoint,FeedType,Element)






    if nargin<=4
        Element=[];
    end
    if isrow(FeedPoint)
        FeedPoint=FeedPoint';
    end


    if numel(FeedPoint)>3
        FeedPoint=FeedPoint';
    end
    EdgesTotal=length(Edge_);

    numfeeds=size(FeedPoint,2);
    numFeedsPerElement=[];
    if iscell(FeedType)
        Feededge=zeros(2,numfeeds);
        for i=1:numel(FeedType)
            if~isempty(Element)&&(isa(Element{i},'linearArray')||isa(Element{i},'circularArray'))
                feedtype=repmat(FeedType{i},Element{i}.NumElements,1);
                FeedTypeCell{i,1}=feedtype;%#ok<AGROW>
                numfeedsTemp=size(Element{i}.FeedLocation,1);
                numFeedsPerElement=[numFeedsPerElement,numfeedsTemp];
            elseif~isempty(Element)&&isa(Element{i},'rectangularArray')
                feedtype=repmat(FeedType{i},prod(Element{i}.Size),1);
                FeedTypeCell{i,1}=feedtype;%#ok<AGROW>
                numfeedsTemp=size(Element{i}.FeedLocation,1);
                numFeedsPerElement=[numFeedsPerElement,numfeedsTemp];
            else
                FeedTypeCell{i,1}=FeedType{i};%#ok<AGROW>
                numfeedsTemp=size(Element{i}.FeedLocation,1);
                numFeedsPerElement=[numFeedsPerElement,numfeedsTemp];
            end
        end
        feedTypeCell=cell2mat(FeedTypeCell);
        [m,~]=size(feedTypeCell);
        for i=1:m
            feedType{i}=feedTypeCell(i,:);%#ok<AGROW>
        end
    else
        if strcmpi(FeedType,'singleedge')
            Feededge=zeros(1,numfeeds);
        elseif strcmpi(FeedType,'doubleedge')
            Feededge=zeros(2,numfeeds);
        end
        [feedType{1:numfeeds}]=deal(FeedType);

        numFeedsPerElement=ones(1,numfeeds);
    end

    numFeedsPerElCumSum=cumsum(numFeedsPerElement,2);
    for n=1:numfeeds
        Distance=zeros(3,EdgesTotal);
        for m=1:EdgesTotal
            Distance(:,m)=0.5*sum(p(:,Edge_(:,m)),2)-FeedPoint(:,n);
        end

        [val,INDEX]=sort(sum(Distance.*Distance));
        indxfeedtype=numFeedsPerElCumSum>=n;
        feedTypeTmp=feedType{find(indxfeedtype,1,'first')};
        if strcmpi(feedTypeTmp,'singleedge')
            if(val(2)-val(1))<eps
                val1=norm(p(:,Edge_(:,INDEX(1)))-FeedPoint(:,n));
                val2=norm(p(:,Edge_(:,INDEX(2)))-FeedPoint(:,n));
                if val1<val2
                    Feededge(1,n)=INDEX(1);
                else
                    Feededge(1,n)=INDEX(2);
                end
            else
                Feededge(1,n)=INDEX(1);
            end
        elseif strcmpi(feedTypeTmp,'doubleedge')
            Feededge(:,n)=INDEX(1:2);
        end
    end
end