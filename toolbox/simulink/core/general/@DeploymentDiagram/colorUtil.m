function ret=colorUtil(varargin)








    ret=[];
    switch varargin{1}

    case 'openColorDlg'
        assert(nargin==3);
        this=varargin{2};
        explorer=varargin{3};

        explorer.setallactions('off');

        C=GLUE2.Util.invokeColorPicker(this.Color,DAStudio.message('Simulink:taskEditor:ColorPickerTitle'));
        if~isempty(C)
            this.Color=C(1:3);
        end


        explorer.updateactions('off',explorer.lastSelectedNodeActions);
    case{'getIconPath','getRefreshIconPath','getSyn2GrTaskIconPath',...
        'getProfileReportIconPath'}
        assert(nargin==1);
        if strcmp(varargin{1},'getIconPath')
            ret=slprivate('getResourceFilePath','color_picker.png');
        elseif strcmp(varargin{1},'getRefreshIconPath')
            ret=slprivate('getResourceFilePath','refresh.png');
        elseif strcmp(varargin{1},'getProfileReportIconPath')
            ret=slprivate('getResourceFilePath','ProfileReport.png');
        else
            ret=slprivate('getResourceFilePath','convertAutoTask.png');
        end

    case 'openColorDlgWithoutExplorer'
        assert(nargin==2);
        this=varargin{2};

        C=GLUE2.Util.invokeColorPicker(this.Color,DAStudio.message('Simulink:taskEditor:ColorPickerTitle'));
        if~isempty(C)
            this.Color=C(1:3);
        end

    otherwise
        assert(false,'should not get here');
    end
