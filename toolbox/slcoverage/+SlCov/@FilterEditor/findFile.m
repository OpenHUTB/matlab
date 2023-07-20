function[foundFileName,fullFileName]=findFile(fileName,modelName)



    if nargin<2
        modelName='';
    end
    fileName=char(fileName);
    foundFileName='';
    fullFileName='';
    if~isempty(fileName)
        [~,~,ext]=fileparts(fileName);
        if~isempty(ext)
            if~strcmpi(ext,'.cvf')
                foundFileName=message('Slvnv:simcoverage:ioerrors:BadExtensionRead','.cvf');
                return;
            end
        end
        fileName=cvi.ReportUtils.appendFileExtAndPath(fileName,'.cvf');
        if~isfile(fileName)
            if~isempty(which((fileName)))
                fullFileName=which(fileName);
            else
                [cvfpath,fileName]=fileparts(fileName);


                if(isempty(cvfpath)||isequal(cvfpath,pwd))&&...
                    ~isempty(modelName)&&~isequal(modelName,0)


                    mdldir=fileparts(get_param(modelName,'FileName'));
                    fileName=cvi.ReportUtils.appendFileExtAndPath(fullfile(mdldir,fileName),'.cvf');
                    if~isfile(fileName)
                        return;
                    end
                    fullFileName=fileName;
                else
                    return;
                end
            end
        else


            d=dir(fileName);
            fullFileName=fullfile(d.folder,d.name);
        end
        cvi.ReportUtils.getFilePartsWithReadChecks(fileName,'.cvf');
        foundFileName=fileName;
    end
end
