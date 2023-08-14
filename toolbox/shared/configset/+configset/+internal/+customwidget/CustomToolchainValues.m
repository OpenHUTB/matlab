function out=CustomToolchainValues(cs,~,direction,widgetVals)




    cs=cs.getConfigSet;

    if direction==0

        [modelSpecificTable,~]=configset.internal.customwidget.CustomToolchainTable(cs);



        out={modelSpecificTable.Data,modelSpecificTable.Data};

    elseif direction==1
        vals=widgetVals{2};


        out=cell(1,numel(vals));
        v=1;
        for r=1:size(vals,1)
            for c=1:size(vals,2)
                out{v}=vals{r,c};
                v=v+1;
            end
        end
    end
end



