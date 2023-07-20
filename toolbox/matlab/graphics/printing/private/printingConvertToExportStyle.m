function newStyle=printingConvertToExportStyle(pt)



























    newStyle=localInitializeStyle;

    if isfield(pt,'AxesFreezeTicks')&&pt.AxesFreezeTicks
        newStyle.LockAxesTicks='on';
    end

    if isfield(pt,'AxesFreezeLimits')&&pt.AxesFreezeLimits
        newStyle.LockAxes='on';
    end


    if pt.VersionNumber==1
        return;
    end


















    if isfield(pt,'LineWidthType')&&isfield(pt,'LineWidth')&&...
        isfield(pt,'LineMinWidth')

        newStyle.FixedLineWidth=pt.LineWidth;
        newStyle.LineWidthMin=pt.LineMinWidth;

        switch(pt.LineWidthType)
        case 'screen'
            newStyle.LineMode='screen';
        case 'scale'
            newStyle.LineMode='scaled';
            newStyle.ScaledLineWidth=pt.LineWidth;
        case 'fixed'
            newStyle.LineMode='fixed';
        end
    end

    if isfield(pt,'LineStyle')
        if~isempty(pt.LineStyle)
            newStyle.LineStyleMap='bw';
        end
    end
















    if isfield(pt,'FontSizeType')&&isfield(pt,'FontSize')

        switch(pt.FontSizeType)
        case 'scale'
            newStyle.FontMode='scaled';
            newStyle.ScaledFontSize=pt.FontSize;
        case 'fixed'
            newStyle.FontMode='fixed';
            newStyle.FixedFontSize=pt.FontSize;
        end
    end
    prop={'FontName','FontWeight','FontAngle'};
    newStyle=localMapToExport(pt,newStyle,prop);

end



function newStyle=localInitializeStyle


    newStyle=[];


    newStyle.LockAxesTicks='off';
    newStyle.LockAxes='off';


    newStyle.FixedLineWidth=0;
    newStyle.LineWidthMin=0;
    newStyle.LineMode='none';
    newStyle.ScaledLineWidth=0;
    newStyle.LineStyleMap='none';


    newStyle.FontMode='none';
    newStyle.ScaledFontSize='auto';
    newStyle.FixedFontSize=0;
    newStyle.FontName='auto';
    newStyle.FontWeight='auto';
    newStyle.FontAngle='auto';



    newStyle.ApplyLineWidthMin=true;



    newStyle.ApplyFontSizeMinToScale=false;
end



function newStyle=localMapToExport(input,newStyle,prop)


    for i=1:numel(prop)
        if isfield(input,prop{i})
            if~isempty(input.(prop{i}))
                newStyle.(prop{i})=input.(prop{i});
            end
        end
    end
end
