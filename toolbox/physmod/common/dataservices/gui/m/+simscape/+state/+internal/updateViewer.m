function updateViewer(name,file)











    if nargin==1
        file='defaultUpdate';
    end

    fileName=file;

    [~,~,ext]=fileparts(file);
    if isempty(ext)
        fileName=[file,'.xml'];
    end

    fullFile=which(fileName);

    if isempty(fullFile)
        fullFile=fullfile(matlabroot,'toolbox','physmod','common',...
        'dataservices','gui','m','+simscape','+state','+internal',...
        fileName);
    end

    fid=fopen(fullFile,'r');

    if(fid==-1)
        error('simscape:variableviewer:open:FileNotFound',...
        'File not found: %s',file);
    end

    c=onCleanup(@()fclose(fid));
    str=fread(fid,inf,'uint8=>char');
    com.mathworks.physmod.common.dataservices.gui.state.AppManager.updateViewer(name,str);

end