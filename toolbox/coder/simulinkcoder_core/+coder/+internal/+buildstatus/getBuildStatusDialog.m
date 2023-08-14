function ret=getBuildStatusDialog(varargin)





    mlock;
    persistent buildStatusDlg;

    if nargin>0
        topMdlName=varargin{1};
    else
        topMdlName='';
    end

    idx=false(1,length(buildStatusDlg));
    for k=1:length(buildStatusDlg)
        aDlg=buildStatusDlg(k);
        if isa(aDlg,'coder.internal.buildstatus.BuildStatusDialog')&&...
            isvalid(aDlg)&&isvalid(aDlg.Dialog)&&...
            aDlg.Dialog.isWindowValid
            idx(k)=true;
        end
    end
    buildStatusDlg=buildStatusDlg(idx);

    if nargin==1
        if~isempty(buildStatusDlg)&&ismember(topMdlName,{buildStatusDlg.modelName})
            ret=buildStatusDlg(ismember({buildStatusDlg.modelName},topMdlName));
        else
            ret=coder.internal.buildstatus.BuildStatusDialog.empty;
        end
    elseif nargin>1

        ret=coder.internal.buildstatus.BuildStatusDialog(varargin{:});
        if isempty(buildStatusDlg)
            buildStatusDlg=ret;
        else
            buildStatusDlg(end+1)=ret;
        end
    else
        ret=buildStatusDlg;
    end

end