function cosimWizard(varargin)


























    narginchk(0,3);

    h=CosimWizardPkg.CosimWizardDlg(varargin{:});
    DAStudio.Dialog(h);


