function output=getPreferredSize(hObj,varargin)




    updateState=varargin{1};


    matlab.graphics.illustration.internal.updateFontProperties(hObj,hObj.Axes);
    updateTitleProperties(hObj);
    updateLimitLabelsProperties(hObj);


    output=getSize(hObj,updateState);

end

