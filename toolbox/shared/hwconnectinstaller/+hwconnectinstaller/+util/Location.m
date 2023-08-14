classdef Location<handle




    properties(Access='public')
        Path='';
    end
    properties(Dependent=true,Access='public')
Drive
    end
    properties(Dependent=true,GetAccess='public',SetAccess='private')
Parent
    end

    methods




        function value=get.Path(h)
            value='';
            if(~isempty(h.Path))
                if(filesep==h.Path(length(h.Path)))
                    value=h.Path;
                else
                    value=[h.Path,filesep];
                end
            end
        end


        function value=get.Drive(h)
            value='';
            if(ispc()&&~isempty(h.Path)&&strcmp(h.Path(2),':'))
                value=h.Path(1);
            end
        end

        function value=get.Parent(h)
            value=fileparts(h.Path(1:end-1));
        end
    end
    methods(Access='public')
        function h=Location(path)


            if(0~=nargin&&~isempty(path))
                if(ispc())
                    replace='\/';
                else
                    replace='\\';
                end
                h.Path=regexprep(path,replace,filesep);



                if(h.isUNCPath())

                    tempPath=h.Path(3:end);
                    pathTokens=textscan(tempPath,'%s','Delimiter',['\',filesep],'MultipleDelimsAsOne',true);
                    tempVar='';
                    for index=1:length(pathTokens{1,1})
                        tempVar=sprintf('%s%s%c',tempVar,char(pathTokens{1,1}(index)),filesep);
                    end
                    h.Path=sprintf('%c%c%s',filesep,filesep,tempVar);
                else

                    if(ispc())
                        pathTokens=textscan(h.Path,'%s','Delimiter',['\',filesep],'MultipleDelimsAsOne',true);
                    else
                        pathTokens=textscan(h.Path,'%s','Delimiter',filesep,'MultipleDelimsAsOne',true);
                    end
                    tempVar='';
                    for index=1:length(pathTokens{1,1})
                        tempVar=sprintf('%s%s%c',tempVar,char(pathTokens{1,1}(index)),filesep);
                    end
                    if(~ispc()&&strcmp(h.Path(1),filesep))
                        h.Path=sprintf('%c%s',filesep,tempVar);
                    else
                        h.Path=tempVar;
                    end
                end
            end
        end

        function value=exists(h)
            value=false;
            if(7==exist(h.Path,'dir'))
                value=true;
            end
        end

        function value=isempty(h)
            value=isempty(h.Path);
        end



        function fileList=files(h,filter)
            if(1==nargin)
                filter='';
            end
            files=dir([h.Path,filter]);
            fileList={};
            for index=1:length(files)
                if(files(index).isdir)
                    continue;
                end
                file=hwconnectinstaller.util.File([h.Path,files(index).name]);
                fileList{end+1}=file;%#ok
            end
        end


        function directoryList=directories(h,filter)
            if(1==nargin)
                filter='';
            end
            files=dir([h.Path,filter]);
            directoryList={};
            for index=1:length(files)
                if(~files(index).isdir)
                    continue;
                end

                if(regexp(files(index).name,'^\.\.*$'))
                    continue;
                end
                directory=hwconnectinstaller.util.Location([h.Path,files(index).name]);
                directoryList{end+1}=directory;%#ok
            end
        end

        function flag=isUNCPath(h)
            flag=false;
            if~ispc||isempty(h.Path)
                return
            end
            if strcmp(h.Path(1:2),'\\')
                flag=true;
            end
        end


        function ret=isFolderWritable(h,subFolder)
            ret=false;
            if(h.exists())
                if(nargin==1)
                    subFolder='';
                end
                if(exist(fullfile(h.Path,subFolder),'dir')==7)
                    [succes,m]=fileattrib(fullfile(h.Path,subFolder));
                    if((succes==true)&&(m.UserWrite==1))
                        ret=true;
                    end
                end
            end
        end

        function test=containsSpaces(h)
            test=false;
            if(any(h.Path==' '))
                test=true;
            end
        end
    end

end

