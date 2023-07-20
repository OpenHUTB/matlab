function restoreSubplotLayout...
    (SerializedSubplotLocations,SerializedSpanSubplotLocations,...
    SerializedSubplotTitle,deserializeArray,fig)





    import matlab.internal.editor.*;

    if~isempty(SerializedSubplotLocations)

        subplotSize=size(SerializedSubplotLocations);
        subplotGrid=repmat(matlab.graphics.GraphicsPlaceholder,subplotSize);
        for row=1:subplotSize(1)



            rowsFromBottom=subplotSize(1)-row+1;

            for col=1:subplotSize(2)
                ind=row+(col-1)*subplotSize(1);



                pos=col+(rowsFromBottom-1)*subplotSize(2);

                if SerializedSubplotLocations(ind)>0


                    locaAxes=deserializeArray(SerializedSubplotLocations(ind));

                    subplot(subplotSize(1),subplotSize(2),pos,locaAxes);
                    subplotGrid(row,col)=locaAxes;
                end
            end
        end
        setappdata(fig,'SubplotGrid',subplotGrid);
    end



    if~isempty(SerializedSpanSubplotLocations)
        subplotSpanSize=size(SerializedSpanSubplotLocations);
        subplotSpanGrid=repmat(matlab.graphics.GraphicsPlaceholder,subplotSpanSize);

        uniqueInd=unique(SerializedSpanSubplotLocations);
        uniqueInd=uniqueInd(uniqueInd>0);
        for i=1:size(uniqueInd)
            uInd=uniqueInd(i);
            [row,col]=find(SerializedSpanSubplotLocations==uInd);



            firstInd=row(1)+(col(1)-1)*subplotSpanSize(1);
            locaAxes=deserializeArray(SerializedSpanSubplotLocations(firstInd));




            rowsFromBottom=subplotSpanSize(1)-row+1;
            pos=col+(rowsFromBottom-1)*subplotSpanSize(2);

            subplot(subplotSpanSize(1),subplotSpanSize(2),pos,locaAxes);
            subplotSpanGrid(row,col)=locaAxes;
        end
        setappdata(fig,'SubplotSpanGrid',subplotSpanGrid);
    end

    if~isempty(SerializedSubplotTitle)
        t=copyobj(SerializedSubplotTitle,fig);
        setappdata(fig,'SubplotGridTitle',t);
    end
end