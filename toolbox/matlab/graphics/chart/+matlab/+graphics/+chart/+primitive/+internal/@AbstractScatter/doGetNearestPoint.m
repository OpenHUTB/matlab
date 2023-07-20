function ind=doGetNearestPoint(hObj,position)







    if any(~strcmp({hObj.XJitter,hObj.YJitter,hObj.XJitter},'none'))
        data{1}=hObj.XYZJittered(:,1);
        data{2}=hObj.XYZJittered(:,2);
        data{3}=hObj.XYZJittered(:,3);
    else
        data={hObj.XDataCache,hObj.YDataCache};
        if~isempty(hObj.ZDataCache)
            data{3}=hObj.ZDataCache;
        end
    end

    sizes=hObj.SizeDataCache;
    if isscalar(sizes)
        if~isfinite(sizes)

            ind=1;
            return
        end
    else

        data{1}(~isfinite(sizes))=NaN;
    end


    sz=cellfun(@numel,data,'UniformOutput',true);
    if~all(sz==1|sz==max(sz))
        ind=1;
        return
    end




    utils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
    ind=utils.nearestPoint(hObj,position,true,data{:});

    if isempty(ind)
        ind=1;
    end
