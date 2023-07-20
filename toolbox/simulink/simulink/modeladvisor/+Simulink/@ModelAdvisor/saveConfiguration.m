function[success]=saveConfiguration(this,filename)






    try
        if~isa(this.ConfigUIRoot,'ModelAdvisor.ConfigUI')
            success=false;
            return;
        end

        inEditTimeView=false;
        if~isempty(this.Toolbar)&&(this.Toolbar.viewComboBoxWidget.getCurrentItem==1)
            inEditTimeView=true;



            modeladvisorprivate('modeladvisorutil2','SelectFilterView',DAStudio.message('ModelAdvisor:engine:FullView'));
            this.Toolbar.viewComboBoxWidget.selectItem(0);
        end


        if isa(this.ConfigUIWindow,'DAStudio.Explorer')
            this.ConfigUIWindow.setStatusMessage(DAStudio.message('Simulink:tools:MASavingConfiguration',filename));
        end


        this.ConfigUIRoot.Index=0;
        speedcache=this.ConfigUICellArray;
        for i=1:length(speedcache)
            speedcache{i}.Index=i;
        end


        if modeladvisorprivate('modeladvisorutil2','FeatureControl','CompressedMACEFormat')

            [rootObj,objList]=modeladvisorprivate('modeladvisorutil2','ConvertTreeToCellArray',this.ConfigUIRoot);
        else
            rootObj=this.ConfigUIRoot;
            objList=this.ConfigUICellArray;
        end


        configuration.ConfigUIRoot=rootObj;
        configuration.ConfigUICellArray=objList;
        configuration.SLVersionInfo=ver('Simulink');
        configuration.ReducedTree=true;


        if ischar(filename)
            filename=fliplr(filename);
            if~strncmpi(filename,'tam.',4)
                filename=['tam.',filename];
            end
            filename=fliplr(filename);
        end


        save(filename,'configuration');


        this.ConfigUIDirty=false;


        this.ConfigFilePath=filename;


        if isa(this.ConfigUIWindow,'DAStudio.Explorer')
            this.ConfigUIWindow.setStatusMessage('');
            modeladvisorprivate('modeladvisorutil2','UpdateConfigUIMenuToolbar',this.ConfigUIWindow);
            modeladvisorprivate('modeladvisorutil2','UpdateConfigUIWindowTitle',this);
        end

        if~isempty(this.Toolbar)&&(inEditTimeView)

            this.Toolbar.viewComboBoxWidget.selectItem(0);
        end

        clear configuration;
        clear objList;
        clear rootObj;
        success=true;

    catch E


        disp(E.message);
        rethrow(E);
    end
