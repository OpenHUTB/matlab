function props=getFactoryLineProperties(this,lineNum)







    propsCell{1}=getString(message('Spcuilib:scopes:MenuLinePropChannel',lineNum));
    propsCell{2}=this.ColorOrder(lineNum,:);
    propsCell{3}=this.LinePropertyDefaults.LineStyle;
    propsCell{4}=this.LinePropertyDefaults.LineWidth;
    propsCell{5}=this.LinePropertyDefaults.Marker;
    propsCell{6}=this.LinePropertyDefaults.MarkerSize;
    propsCell{7}=this.LinePropertyDefaults.MarkerEdgeColor;
    propsCell{8}=this.LinePropertyDefaults.MarkerFaceColor;
    propsCell{9}=this.LinePropertyDefaults.Visible;
    propNames=this.LinePropertyNames;
    props=cell2struct(propsCell,propNames,2);
end
