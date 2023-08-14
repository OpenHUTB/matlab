function ind=doGetNearestPoint(hObj,position)







    data={hObj.XDataCache,hObj.YDataCache};
    if~isempty(hObj.ZDataCache)
        data{3}=hObj.ZDataCache;
    end


    sz=cellfun(@numel,data,'UniformOutput',true);
    if~all(sz==max(sz))
        ind=1;
        return
    end

    utils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
    if strcmp(hObj.LineStyle,'none')

        ind=utils.nearestPoint(hObj,position,true,data{:});

    else

        data{1}=createSegments(data{1});
        if numel(data)==2
            data{2}=createSegments(data{2},hObj.BaseValue);
        else
            data{2}=createSegments(data{2});
            data{3}=createSegments(data{3},hObj.BaseValue);
        end


        ind=utils.nearestSegment(hObj,position,true,data{:});



        ind=floor((ind-1)/3)+1;
    end

end


function segs=createSegments(data,basevalue)

    if nargin<2

        basevalue=data(:).';
    end


    segs=zeros(3,numel(data));
    segs(1,:)=basevalue;
    segs(2,:)=data(:).';
    segs(3,:)=NaN;
    segs=segs(:);
end
