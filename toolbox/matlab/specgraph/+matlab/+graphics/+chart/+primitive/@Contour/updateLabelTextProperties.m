function updateLabelTextProperties(hObj,propertyInputs)





















    labelTextProperties=hObj.LabelTextProperties;

    labelTextDefaults=matlab.graphics.chart.primitive.Contour.defaultLabelTextProperties();

    [labelTextProperties.Font,propertyInputs]...
    =updateFont(labelTextProperties.Font,propertyInputs,labelTextDefaults.Font);

    [labelTextProperties,propertyInputs]=updateColorData(...
    labelTextProperties,propertyInputs,labelTextDefaults);

    [labelTextProperties,propertyInputs]=updateBackgroundOrEdgeColor(...
    labelTextProperties,propertyInputs,'BackgroundColor',labelTextDefaults);

    [labelTextProperties,propertyInputs]=updateBackgroundOrEdgeColor(...
    labelTextProperties,propertyInputs,'EdgeColor',labelTextDefaults);

    [labelTextProperties.LineStyle,propertyInputs]=updateLineStyle(...
    labelTextProperties.LineStyle,propertyInputs,labelTextDefaults.LineStyle);

    labelTextProperties=updateRemainingProperties(...
    labelTextProperties,propertyInputs,labelTextDefaults);


    hObj.LabelTextProperties=labelTextProperties;
end


function[fontObj,propertyInputs]=updateFont(fontObj,propertyInputs,defaultFontObj)


    fontClassPropertyNames=properties(fontObj);
    for k=1:length(fontClassPropertyNames)
        name=fontClassPropertyNames{k};
        textClassPropertyName=['Font',name];
        if isfield(propertyInputs,textClassPropertyName)
            if strcmpi(propertyInputs.(textClassPropertyName),'default')
                fontObj.(name)=defaultFontObj.(name);
            else
                value=propertyInputs.(textClassPropertyName);
                switch textClassPropertyName
                case 'FontAngle'
                    value=validateEnumeratedStringProperty(textClassPropertyName,value,{'normal','italic'});

                case 'FontName'
                    validateattributes(value,{'char'},{'nonempty','row'},'',textClassPropertyName)

                case 'FontSize'
                    value=validatePositiveNumericProperty(textClassPropertyName,value);

                case 'FontWeight'
                    value=validateEnumeratedStringProperty(textClassPropertyName,value,{'normal','bold'});
                end
                fontObj.(name)=value;
            end
            propertyInputs=rmfield(propertyInputs,textClassPropertyName);
        end
    end
end


function[labelTextProperties,propertyInputs]=updateColorData(...
    labelTextProperties,propertyInputs,labelTextDefaults)




    if isfield(propertyInputs,'Color')
        value=propertyInputs.Color;
        if strcmpi(value,'default')
            labelTextProperties.ColorData=labelTextDefaults.ColorData;
            labelTextProperties.Visible='on';
        elseif matchesNone(value)
            labelTextProperties.ColorData=labelTextDefaults.ColorData;
            labelTextProperties.Visible='off';
        else
            labelTextProperties.ColorData=colorSpecToRGBA(value,'Color');
            labelTextProperties.Visible='on';
        end
        propertyInputs=rmfield(propertyInputs,'Color');
    end
end


function[labelTextProperties,propertyInputs]=updateBackgroundOrEdgeColor(...
    labelTextProperties,propertyInputs,propname,labelTextDefaults)



    if isfield(propertyInputs,propname)
        value=propertyInputs.(propname);
        if strcmpi(value,'default')||matchesNone(value)
            labelTextProperties.(propname)=labelTextDefaults.(propname);
        else
            labelTextProperties.(propname)=colorSpecToRGBA(value,propname);
        end
        propertyInputs=rmfield(propertyInputs,propname);
    end
end


function tf=matchesNone(str)

    tf=(~isempty(str)&&strncmpi(str,'none',length(str)));
end


function rgba=colorSpecToRGBA(colorSpec,name)


















    if ischar(colorSpec)

        validateattributes(colorSpec,{'char'},{'nonempty','row'},'',name)
        rgb=colorSpecStringToRGB(colorSpec,name);
    else


        validateattributes(colorSpec,{'numeric'},...
        {'real','>=',0,'<=',1,'size',[1,3]},'',name);
        rgb=double(colorSpec);
    end

    rgba=uint8(255*[rgb,1]');
end


function rgb=colorSpecStringToRGB(colorSpec,name)




    colorSpec=strtrim(colorSpec);


    index=strcmpi(colorSpec,{'k','b','bl'});
    if any(index)



        blackOrBlue=[0,0,0;0,0,1;0,0,1];
        rgb=blackOrBlue(index,:);
    else

        colorSpecStrings={...
        'red','green','blue','white','cyan','magenta','yellow','black'};
        rgbSpec=[1,0,0;0,1,0;0,0,1;1,1,1;0,1,1;1,0,1;1,1,0;0,0,0];




        colorString=validatestring(colorSpec,colorSpecStrings,'',name);
        index=strcmp(colorString,colorSpecStrings);
        rgb=rgbSpec(index,:);
    end
end


function[lineStyle,propertyInputs]...
    =updateLineStyle(lineStyle,propertyInputs,defaultLineStyle)

    if isfield(propertyInputs,'LineStyle')
        value=propertyInputs.LineStyle;
        if strcmpi(value,'default')
            lineStyle=defaultLineStyle;
        else
            lineStyle=translateLineStyle(value);
        end
        propertyInputs=rmfield(propertyInputs,'LineStyle');
    end
end


function lineStyle=translateLineStyle(lineStyle)


    textLineStyles={'-','--',':','-.','none'};
    worldTextLineStyles={'solid','dashed','dotted','dashdot','none'};
    lineStyle=validateEnumeratedStringProperty('LineStyle',lineStyle,textLineStyles);
    k=find(strcmp(lineStyle,textLineStyles));
    if~isempty(k)
        lineStyle=worldTextLineStyles{k(1)};
    end
end


function labelTextProperties=updateRemainingProperties(...
    labelTextProperties,propertyInputs,labelTextDefaults)


    remainingProperties={'FontSmoothing','Interpreter','LineWidth','Margin'};
    fieldsInput=remainingProperties(isfield(propertyInputs,remainingProperties));
    for k=1:length(fieldsInput)
        name=fieldsInput{k};
        value=propertyInputs.(name);
        if strcmpi(value,'default')
            labelTextProperties.(name)=labelTextDefaults.(name);
        else

            switch name
            case 'FontSmoothing'
                value=validateEnumeratedStringProperty(name,value,{'on','off'});

            case 'Interpreter'
                value=validateEnumeratedStringProperty(name,value,{'tex','latex','none'});

            case 'LineWidth'
                value=validatePositiveNumericProperty(name,value);

            case 'Margin'
                value=validatePositiveNumericProperty(name,value);

            end
            labelTextProperties.(name)=value;
        end
        propertyInputs=rmfield(propertyInputs,name);
    end
end


function value=validateEnumeratedStringProperty(name,value,acceptedValues)
    validateattributes(value,{'char'},{'nonempty','row'},'',name)
    value=validatestring(value,acceptedValues,'',name);
end


function value=validatePositiveNumericProperty(name,value)
    validateattributes(value,{'numeric'},{'real','positive','finite','scalar'},'',name)
    value=double(value);
end
