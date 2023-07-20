function frameObj=framerect(varargin)




    switch nargin
    case 0
        frameObj.Class='framerect';
        frameObj.ContentType=[];
        frameObj.fResizable=[];
        frameObj.MinWidth=[];
        frameObj.MaxLine=[];
        frameObj.MinLine=[];
        frameObj=class(frameObj,'framerect',hgbin);
        return
    case 1
        HGpatch=varargin{1};
    otherwise
        HGpatch=patch(varargin{:},'w');
    end

    set(HGpatch,'FaceColor','none',...
    'EdgeColor','none',...
    'PickableParts','all',...
    'ButtonDownFcn','doclick(gcbo)');

    frameObj.Class='framerect';
    frameObj.ContentType='';
    frameObj.fResizable=[0,0,0,0];
    frameObj.MinWidth=0.01;

    frameObj.MaxLine=[];
    frameObj.MinLine=[];

    binObj=hgbin(HGpatch);

    frameObj=class(frameObj,'framerect',binObj);
