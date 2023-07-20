function sfunddg_cb(dlgH,source,buttonTag)






































    dlgH.setEnabled(buttonTag,false);

    try
        doEditFile(dlgH,buttonTag);
    catch anError
        disp(anError.message);
    end

    closeProgressBar(dlgH,buttonTag);


    dlgH.setEnabled(buttonTag,~source.isHierarchySimulating);


    function doEditFile(dlgH,buttonTag)


        sfun=dlgH.getWidgetValue('FunctionName');

        createProgressBar(dlgH,buttonTag,sfun);

        do_return=sfunddg_cb_edit(sfun);

        if~do_return






            closeProgressBar(dlgH,buttonTag);

            ansBrowse=DAStudio.message('Simulink:dialog:SfunBrowse');
            ansOpenEd=DAStudio.message('Simulink:dialog:SfunOpenEditor');
            ansCancel=DAStudio.message('Simulink:dialog:SfunCancel');

            buttonName=questdlg(...
            DAStudio.message('Simulink:dialog:SfunCannotFindFile'),...
            DAStudio.message('Simulink:dialog:SfunDlgTitle'),...
            ansBrowse,ansOpenEd,ansCancel,ansCancel);

            switch buttonName
            case ansBrowse
                [filename,pathname]=uigetfile(...
                {'*.c;*.cpp;*.F;*.f;*.for;*.for;*.f77;*.f90;*.adb;*.ada;*.ads;*.m',...
                DAStudio.message('Simulink:dialog:SfunAllSourceFiles');...
                '*.*',...
                DAStudio.message('Simulink:dialog:SfunAllFiles')},...
                DAStudio.message('Simulink:dialog:SfunBrowserTitle'));

                if isequal(filename,0)||isequal(pathname,0)

                else
                    edit([pathname,filename]);
                end

            case ansOpenEd


                edit('');

            otherwise


            end
        else
            closeProgressBar(dlgH,buttonTag);
        end



        function closeProgressBar(dlg,widgetTag)

            progressBarHandle=dlg.getUserData(widgetTag);
            if isa(progressBarHandle,'DAStudio.WaitBar')
                progressBarHandle.imCancel;
            else
                close(progressBarHandle);
            end

            dlg.setUserData(widgetTag,[]);



            function createProgressBar(dlg,widgetTag,fileName)

                progressMsg=DAStudio.message('Simulink:dialog:SfunSearch',fileName);
                progressBar=DAStudio.WaitBar;
                progressBar.setLabelText(progressMsg);
                progressBar.setCircularProgressBar(true);
                progressBar.show;
                dlg.setUserData(widgetTag,progressBar);


