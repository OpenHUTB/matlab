function new_ds=copyDataSpace(ds)


    if isa(ds,'matlab.graphics.axis.dataspace.CartesianDataSpace')
        new_ds=copyCartesianDataSpace(ds);
    else
        new_ds=makeCopy(ds);
    end


    function new_ds=copyCartesianDataSpace(ds)

        new_ds=matlab.graphics.axis.dataspace.CartesianDataSpace;

        for copyprops_I={'XDataLim','YDataLim','ZDataLim','XLim','YLim','ZLim','XDir','YDir','ZDir','XScale','YScale','ZScale'}
            new_ds.(copyprops_I{:})=ds.([copyprops_I{:},'_I']);
        end



        for copyprops_WithInfs={'XLim','YLim','ZLim'}
            new_ds.([copyprops_WithInfs{:},'WithInfs'])=ds.(copyprops_WithInfs{:});
        end

        for copyprops={'AllowStretchExtents','AllowOptimizedTransform','PreferDataSpaceManualProps','XLimMode','YLimMode','ZLimMode'}
            new_ds.(copyprops{:})=ds.(copyprops{:});
        end
