function updateLineProperties(this)






    defaultLineProperties=this.LinePropertyDefaults;
    defaultColorOrder=this.ColorOrder;
    cachedProps=this.LinePropertiesCache;
    numCachedLines=length(cachedProps);
    if strcmpi(this.PlotType,'stem')
        defaultLineProperties.Marker='.';
    else
        defaultLineProperties.Marker=get(0,'DefaultLineMarker');
    end
    lineNumberForColor=0;
    hLines=this.Lines;
    nLines=length(hLines);
    for lineNum=1:nLines

        props=defaultLineProperties;


        lineNumberForColor=lineNumberForColor+1;
        props.Color=defaultColorOrder(rem(lineNumberForColor-1,size(defaultColorOrder,1))+1,:);


        if(lineNum<=numCachedLines)&&~isempty(cachedProps{lineNum})
            if isfield(cachedProps{lineNum},'Color')&&isempty(cachedProps{lineNum}.Color)
                cachedProps{lineNum}.Color=props.Color;
            end
            props=dsp.scopes.SpectrumPlotter.mergeStructs(props,cachedProps{lineNum});
        end
        setLineProperties(this,lineNum,props)
    end
end
