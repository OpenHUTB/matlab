function p=showProgressbar()

    p=DAStudio.WaitBar;
    p.setWindowTitle('');
    p.setLabelText(DAStudio.message('configset:util:GetModelHierarchy'));
    p.setCircularProgressBar(true);
    p.show();
