function h=plotSeries(series,timeWindow,units,names)






    seriesUnits=cellfun(@(x)(x.unit),series,'UniformOutput',false);


    if isempty(units)
        units=findUniqueCommensurateUnits(seriesUnits);
    end




    commensurateMatrix=pm_commensurate(units,seriesUnits);



    if~any(commensurateMatrix)
        h={};
        return;
    end

    numSeries=numel(series);
    numNames=numel(names);


    if(numSeries>1)
        for idx=numNames+1:numSeries
            names{idx}=['Series ',num2str(idx)];
        end
    else
        if isempty(names)
            names{1}='';
        end
    end





    h=cell(1,numel(units));



    for idx=1:numel(units)


        seriesToPlotIndex=commensurateMatrix(idx,:);

        seriesToPlot=series(seriesToPlotIndex);
        seriesNames=names(seriesToPlotIndex);

        h{idx}=localPlotSeries(seriesToPlot,timeWindow,units{idx},...
        seriesNames);
    end

end



function h=localPlotSeries(series,timeWindow,unit,names)



    if isempty(series)
        h=[];
        return;
    end




    pivotDimension=series{1}.dimension;

    h=figure;
    getColor(0);
    legendEntries=names;

    xAxisLimit=[inf,-inf];


    for idx=1:numel(series)



        dim=series{idx}.dimension;
        if~isequal(dim,pivotDimension)
            continue;
        end


        time=series{idx}.time;


        if time(1)<xAxisLimit(1)
            xAxisLimit(1)=time(1);
        end
        if time(end)>xAxisLimit(2)
            xAxisLimit(2)=time(end);
        end


        values=series{idx}.values(unit);


        color=getColor;



        for i=1:dim(1)
            for j=1:dim(2)
                index=sub2ind(dim,i,j);
                subplot(dim(1),dim(2),index);
                hold on;
                valuesForThisDimension=values(1:end,index);
                plot(time,valuesForThisDimension(:),'Color',color);
            end
        end

        hold on;
        grid on;

    end


    dim=pivotDimension;
    for i=1:dim(1)
        for j=1:dim(2)
            subplot(dim(1),dim(2),dim(1)*(j-1)+i);
            box on;
            grid on;
            hold off;
            xlabel('Time (s)');
            ylabel(unit);
            if~isempty(timeWindow)
                set(gca,'XLim',timeWindow);
            else
                set(gca,'XLim',xAxisLimit);
            end
            isCellEmpty=@(x)(any(cellfun(@isempty,x)));
            if~isCellEmpty(legendEntries)
                legend(legendEntries);
            end
            title(sprintf('Dimension (%d,%d)',i,j),'Interpreter','none');
        end
    end

end
