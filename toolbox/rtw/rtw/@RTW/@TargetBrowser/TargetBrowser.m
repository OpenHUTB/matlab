function h=TargetBrowser(varargin)





    h=RTW.TargetBrowser;


    browseTLCFiles(h);

    if nargin>=2
        hParentDlg=varargin{1};
        hParentSrc=varargin{2};

        if~isempty(hParentSrc)
            hParentSrc=hParentSrc.getParent;
        end

        if isempty(hParentSrc)||~isa(hParentSrc,'Simulink.ConfigSet')||isempty(hParentDlg)
            DAStudio.error('RTW:configSet:invalidConfigSet');
            h=[];
            return;
        end


        set(h,'ParentDlg',hParentDlg);
        set(h,'ParentSrc',hParentSrc);
    end

