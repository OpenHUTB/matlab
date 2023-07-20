function close(varargin)


    if nargin>0
        topModel=varargin{1};
    else
        topModel='';
    end

    dlgs=coder.internal.buildstatus.getBuildStatusDialog();
    if isempty(topModel)

        for k=1:length(dlgs)
            dlgs(k).cleanup;
        end
    else

        if~isempty(dlgs)&&ismember(topModel,{dlgs.modelName})
            theDlg=dlgs(ismember({dlgs.modelName},topModel));
            theDlg.cleanup;
        end
    end

end