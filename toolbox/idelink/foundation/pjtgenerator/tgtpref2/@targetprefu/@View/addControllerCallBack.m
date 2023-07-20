function widStruct=addControllerCallBack(hView,widStruct,methodName,varargin)




    widStruct.ObjectMethod='callController';
    if~ischar(methodName)||~ischar(widStruct.Tag)
        assert(false,hView.mController.getAssertionMessage());
    end

    widStruct.Source=hView;
    widStruct.MethodArgs={'%dialog',methodName,widStruct.Tag,'','',''};

    switch(length(varargin))
    case 0,
    case 1,widStruct.MethodArgs{4}=varargin{1};
    case 2,widStruct.MethodArgs{4}=varargin{1};
        widStruct.MethodArgs{5}=varargin{2};
    case 3,widStruct.MethodArgs{4}=varargin{1};
        widStruct.MethodArgs{5}=varargin{2};
        widStruct.MethodArgs{6}=varargin{3};
    end
    widStruct.ArgDataTypes={'handle','mxArray','mxArray','mxArray','mxArray','mxArray'};


