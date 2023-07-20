function displayNames=getNamesForLayout(hObj)




    objects=hObj.PlotChildren_I;
    displayNames=strings(1,numel(objects));
    generateDisplayName=false(1,numel(objects));
    validObjects=true(size(displayNames));


    labelHints=struct();
    if isa(hObj.Axes,'matlab.graphics.axis.AbstractAxes')
        labelHints=hObj.Axes.HintConsumer.getChannelDisplayNamesStruct();
    end

    for i=1:numel(objects)
        obj=objects(i);



        obj.updateDisplayNameBasedOnLabelHints(labelHints);



        displayNames(i)=obj.getDisplayNameForInterpreter(hObj.Interpreter);



        generateDisplayName(i)=displayNames(i)==""&&obj.DisplayNameMode=="auto";
    end






    if any(generateDisplayName)
        displayNames=generateDisplayNames(objects,displayNames,generateDisplayName);
    end


    displayNames=displayNames(validObjects);


    displayNames=deblank(displayNames);

end

function displayNames=generateDisplayNames(objects,displayNames,generateDisplayName)

    nextInteger=1;
    for i=1:numel(objects)
        if generateDisplayName(i)

            nextName="data"+nextInteger;
            while ismember(nextName,displayNames)
                nextInteger=nextInteger+1;
                nextName="data"+nextInteger;
            end



            objects(i).setDisplayNameFromLegend(nextName);


            displayNames(i)=nextName;
            nextInteger=nextInteger+1;
        end
    end

end
