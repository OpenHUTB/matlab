function configureOceanOpticsDriver(varargin)











    silentMode=false;
    if nargin==1
        tmp=varargin{1};
        if islogical(tmp)
            silentMode=tmp;
        end
    end



    javaLibraryPathFileName=fullfile(prefdir,'javalibrarypath.txt');
    [omniDriverLocation,omniDriverFileName]=retrieveJavaPathFile(javaLibraryPathFileName);



    if isempty(omniDriverFileName)
        if(ispc)
            omniDriverLocation=fullfile('C:','Program Files','Ocean Optics','OmniDriver');
        elseif(ismac)
            omniDriverLocation='/Applications/OmniDriver-2.40';
        else
            omniDriverLocation=fullfile(getenv('HOME'),'OmniDriver');
        end



        omniDriverLocation=fullfile(omniDriverLocation,'OOI_HOME');
        omniDriverFileName=fullfile(omniDriverLocation,'OmniDriver.jar');
    end


    if~exist(omniDriverFileName,'file')&&~silentMode
        omniDriverLocation=uigetdir('',...
        message('instrument:configureoceanopticsdriver:selectDirectory').getString);

        if(omniDriverLocation==0)
            msg=[message('instrument:configureoceanopticsdriver:configurationCancelled').getString,' '...
            ,message('instrument:configureoceanopticsdriver:locateDriverFailed').getString,'.'];
            error(msg);
        end
        addpath(genpath(omniDriverLocation));
        omniDriverFileName=which('OmniDriver.jar');
        rmpath(genpath(omniDriverLocation));
        omniDriverLocation=strrep(omniDriverFileName,'OmniDriver.jar','');
    end

    if(~exist(omniDriverFileName,'file'))
        error(message('instrument:configureoceanopticsdriver:locateDriverFailed'));
    end




    javaClassPathFileName=fullfile(prefdir,'javaclasspath.txt');


    fileUpdated=updateJavaPathFile(javaClassPathFileName,omniDriverFileName);



    if fileUpdated
        fullJarPath=fullfile(omniDriverLocation,'OmniDriver.jar');
        javaaddpath(fullJarPath,'-end');
    end




    javaLibraryPathFileName=fullfile(prefdir,'javalibrarypath.txt');


    updateJavaPathFile(javaLibraryPathFileName,omniDriverLocation);

    if~silentMode
        msgbox(message('instrument:configureoceanopticsdriver:restartMATLAB').getString,...
        message('instrument:configureoceanopticsdriver:restartRequired').getString,'modal');
    end

end

function fileUpdated=updateJavaPathFile(fileName,updateString)




    fid=fopen(fileName,'a+');
    if isequal(fid,-1)
        error(message('instrument:configureoceanopticsdriver:errorUpdatingFile',fileName));
    end

    frewind(fid);


    fileContent=fscanf(fid,'%c');

    fileUpdated=false;

    if~contains(fileContent,updateString)

        fwrite(fid,sprintf('\n%s',updateString));
        fileUpdated=true;
    end


    fclose(fid);
end

function[omniDriverLocation,omniDriverFileName]=retrieveJavaPathFile(javaLibraryPathFileName)






    ooiHome=getenv("OOI_HOME");
    [omniDriverFileName,omniDriverLocation]=getOmniFileDetails(ooiHome);



    if isempty(omniDriverFileName)
        fid=fopen(javaLibraryPathFileName,'a+');


        frewind(fid);

        while isempty(omniDriverFileName)

            fileContent=fgetl(fid);
            if fileContent==-1


                break
            elseif fileContent==""


                continue
            end

            [omniDriverFileName,omniDriverLocation]=getOmniFileDetails(fileContent);
        end
    end
end

function[fileName,fileLocation]=getOmniFileDetails(folderPath)
    fileName=[];
    fileLocation=[];
    fileNameTemp=fullfile(folderPath,'OmniDriver.jar');


    if exist(fileNameTemp,'file')
        fileName=fileNameTemp;
        fileLocation=folderPath;
    end
end
