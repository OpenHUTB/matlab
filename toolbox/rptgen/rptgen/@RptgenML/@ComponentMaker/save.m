function save(componentmaker,fName)







    if nargin<2||isempty(fName)
        componentmaker.makeClassDir;
        fName=fullfile(componentmaker.ClassDir,'_componentmaker.mat');
    elseif strcmpi(fName,'-saveas')||...
        (islogical(fName)&&fName)

        if~isempty(componentmaker.ClassDir)&&exist(componentmaker.ClassDir,'dir')
            fName=fullfile(componentmaker.ClassDir,'_componentmaker.mat');
        else
            fName=fullfile(pwd,'componentmaker.mat');
        end


        [dlgFile,dlgPath]=uiputfile({
        '*.mat',getString(message('rptgen:RptgenML_ComponentMaker:matFilesLabel'))
        '*.*',getString(message('rptgen:RptgenML_ComponentMaker:allFilesLabel'))
        },getString(message('rptgen:RptgenML_ComponentMaker:saveMakerAsLabel')),...
        fName);

        if isequal(dlgFile,0)||isequal(dlgPath,0)
            return;
        else
            fName=fullfile(dlgPath,dlgFile);
        end

    end

    save(fName,'componentmaker');

