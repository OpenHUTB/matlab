function size=getPreferredSize(hObj,varargin)




    updateState=varargin{1};


    matlab.graphics.illustration.internal.updateFontProperties(hObj,hObj.Axes);
    updateTitleProperties(hObj);


    size=doMethod(hObj,'getsize',updateState);

end
