function postEvent(viewerOrController,requestName,varargin)



    initialValues=struct(varargin{:});
    model=viewerOrController.View.getViewModel();
    event=dependencies.internal.viewer.(requestName)(model,initialValues);
    event.destroy();
end
