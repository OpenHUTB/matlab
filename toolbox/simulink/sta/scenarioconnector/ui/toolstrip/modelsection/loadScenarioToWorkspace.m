function loadScenarioToWorkspace(fileName,varName,varargin)







    [~,~,theExt]=fileparts(fileName);



    if strcmpi(theExt,'.mat')||strcmpi(theExt,'.mlx')



        fileReader=iofile.STAMatFile(fileName);
        varOut=fileReader.loadAVariable(varName);
        assignin('base',varName,varOut.(varName));

    else




        fileReader=iofile.ExcelFile(fileName);
        if nargin==3
            fileReader.loadAVariable(varName,varargin{1});
        else
            fileReader.loadAVariable(varName);
        end
    end