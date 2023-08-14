function dialogCB(this,action,hDlg)




    switch lower(action)
    case 'selectfile'
        [modelFilename,filePath]=uigetfile({'*.slx','Simulink model (*.slx)';...
        '*.mdl','Simulink model (*.mdl)'},...
        DAStudio.message('polyspace:gui:pslink:fileSelectorTitle'),'MultiSelect','off');

        if~isempty(modelFilename)&&~isequal(modelFilename,0)
            selectedFile=fullfile(filePath,modelFilename);

            this.selectedFile=selectedFile;
            hDlg.refresh();
        end

    otherwise


    end