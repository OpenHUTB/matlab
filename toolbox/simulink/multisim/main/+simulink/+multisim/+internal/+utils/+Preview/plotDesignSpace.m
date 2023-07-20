function plotDesignSpace(designPoints,fig)




    transposedDesignPoints=simulink.multisim.internal.utils.Preview.transposeDesignPoints(designPoints);
    parameterTypes=[designPoints(1).ParameterSamples.ParameterType];
    parameterCount=length(parameterTypes);

    for y=1:parameterCount
        for x=1:y
            subplotNum=(y-1)*parameterCount+x;
            ax=subplot(parameterCount,parameterCount,subplotNum,'Parent',fig);

            drawPlot(ax,x,y,transposedDesignPoints);
            addLabels(ax,x,y,parameterCount,parameterTypes);

            set(ax,'tag',num2str(subplotNum));
        end
    end
end

function drawPlot(ax,x,y,transposedDesignPoints)




    x_pts=transposedDesignPoints{x};
    y_pts=transposedDesignPoints{y};

    if x==y
        histogram(ax,x_pts);
    else
        scatter(ax,x_pts,y_pts,30,'green','filled');
    end
end

function addLabels(ax,x,y,parameterCount,parameterTypes)




    if x==1
        ylabel(ax,parameterTypes(y).Container.Label,"Interpreter","none");
    end
    if y==parameterCount
        xlabel(ax,parameterTypes(x).Container.Label,"Interpreter","none")
    end
end