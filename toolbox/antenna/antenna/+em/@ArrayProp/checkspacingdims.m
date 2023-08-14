function checkspacingdims(obj,spacing,numelements,errorstring)



    if~isscalar(spacing)
        if~isequal(numel(spacing),numelements-1)
            actualvalue=num2str(numel(spacing));
            expvalue=num2str(numelements-1);
            error(message('antenna:antennaerrors:InvalidEntries',...
            'Spacing',expvalue,actualvalue));



        end
    end
end