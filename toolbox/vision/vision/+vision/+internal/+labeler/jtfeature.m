function flag=jtfeature(featureName,varargin)







































    if nargin==1
        flag=vision.internal.jtfeature(featureName);
    else
        flag=vision.internal.jtfeature(featureName,varargin{:});
        s=settings;
        if varargin{1}==true
            s.vision.labeler.OpenWithAppContainer.PersonalValue=true;
        else
            s.vision.labeler.OpenWithAppContainer.PersonalValue=false;
        end
    end




























end
