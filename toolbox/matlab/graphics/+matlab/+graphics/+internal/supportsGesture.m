function support=supportsGesture(obj,featureString)











    support=false;

    if isgraphics(obj,'axes')
        switch lower(featureString)
        case{'legend',...
            'colorbar',...
            'grid',...
            'xlabel',...
            'ylabel',...
            'xgrid',...
            'ygrid',...
            'zlabel',...
            'title',}
            support=true;
        end
    elseif isgraphics(obj,'polaraxes')
        switch lower(featureString)
        case{'legend',...
            'colorbar',...
            'grid',...
            'title'}
            support=true;
        end
    elseif isgraphics(obj,'geoaxes')
        switch lower(featureString)
        case{'legend',...
            'colorbar',...
            'grid',...
            'title'}
            support=true;
        end
    elseif isa(obj,'matlab.graphics.chart.Chart')
        support=obj.supportsGesture(featureString);
    end

end

