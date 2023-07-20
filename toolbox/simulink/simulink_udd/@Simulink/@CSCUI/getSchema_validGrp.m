function validGrp=getSchema_validGrp(hUI)








    validResult.Type='textbrowser';
    validResult.Tag='tValidBrowser';
    validResult.Text='';

    if isempty(hUI.InvalidList)||...
        (isempty(hUI.InvalidList{1})&&...
        isempty(hUI.InvalidList{2}))



        validResult.Text=['<PRE>',...
        DAStudio.message('Simulink:dialog:CSCUIValidationSucceeded'),...
        '</PRE>'];

    else
        for i=1:size(hUI.InvalidList{1},2)
            invalidDefn=hUI.InvalidList{1}(:,i);
            validResult.Text=sprintf(...
            [validResult.Text,'\n',...
            'Invalid CustomStorageClass: "',...
            invalidDefn{1},'"\n',...
            invalidDefn{2},'\n']);
        end

        for i=1:size(hUI.InvalidList{2},2)
            invalidDefn=hUI.InvalidList{2}(:,i);
            validResult.Text=sprintf(...
            [validResult.Text,'\n',...
            'Invalid MemorySection: "',...
            invalidDefn{1},'"\n',...
            invalidDefn{2},'\n']);
        end

        validResult.Text=sprintf(...
        ['<PRE>',...
        '<font color="darkred">',...
        validResult.Text,...
        '</font>',...
        '</PRE>']);
    end






    validGrp.Name=DAStudio.message('Simulink:dialog:CSCUIValidationResult');
    validGrp.Type='group';
    validGrp.Tag='tValidGroup';
    validGrp.LayoutGrid=[1,1];

    validResult.RowSpan=[1,1];
    validResult.ColSpan=[1,1];

    validGrp.Items={validResult};





