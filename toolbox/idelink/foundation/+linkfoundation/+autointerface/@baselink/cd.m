function resp=cd(h,dirname)




















    narginchk(1,2);
    h=h(1);

    if nargin==1,


        resp=h.mIdeModule.GetCurrDirectory;

    elseif nargin==2,
        if~ischar(dirname)
            DAStudio.error('ERRORHANDLER:autointerface:InvalidNonCharDirName');
        end


        h.mIdeModule.SetCurrDirectory(dirname);


        if(nargout==1)
            resp=h.mIdeModule.GetCurrDirectory;
        end
    end


