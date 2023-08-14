



function fext=findFileExt(fullName)


    fext=[];



    theDir=dir([fullName,'.*']);
    if~isempty(theDir)
        for ii=1:length(theDir)
            if theDir(ii).isdir
                continue
            end
            [fpath,fname,fext]=fileparts(theDir(ii).name);%#ok
            if~isempty(fext)
                break
            end
        end
    end
