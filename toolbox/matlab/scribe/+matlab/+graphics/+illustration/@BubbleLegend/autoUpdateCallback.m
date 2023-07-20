function autoUpdateCallback(e,bubbleLegend)





    hObj=bubbleLegend;
    if isempty(hObj)||~isvalid(hObj)
        return
    end


    ch=e.LegendableObjects';


    ch=removeNestedObjects(hObj,ch);


    ch=processGroups(ch);










    if~isequal(hObj.PlotChildren_I,ch)&&...
        (~isempty(hObj.PlotChildren_I)||~isempty(ch))

        for i=numel(ch):-1:1
            if~isa(ch(i),'matlab.graphics.chart.primitive.BubbleChart')
                ch(i)=[];
            else


                bubbleChartObject=ch(i);
                listenerAlreadyExists=false;
                for j=1:numel(hObj.AxesListenerList)

                    if isequal(bubbleChartObject,hObj.AxesListenerList(j).Source{1})
                        listenerAlreadyExists=true;
                    end
                end
                if~listenerAlreadyExists
                    hObj.AxesListenerList(end+1)=event.listener(bubbleChartObject,'LegendEntryDirty',@(h,e)hObj.MarkDirty('all'));
                    ch(i).markLegendEntryClean();
                end
            end
        end

        hObj.PlotChildren=ch;
        hObj.PlotChildrenMode='auto';
    end

end


function ch=removeNestedObjects(hObj,ch)



    ax=hObj.Axes;

    par=get(ch,'Parent');
    if iscell(par)
        par=[par{:}]';
    end
    ch=ch(par==ax);
end

function ch=processGroups(ch)


    ch=flipud(ch);
    ch=matlab.graphics.illustration.internal.expandLegendChildren(ch);
    ch=flipud(ch);
end
