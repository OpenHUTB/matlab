classdef Location<handle




    properties(Access='public')
        Path='';
    end

    properties(Dependent=true,Access='public')
Drive
EscapedPath
ShortPath
LongPath
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



        function value=get.EscapedPath(h)
            value=strrep(h.Path,'\','\\');
        end

        function value=get.ShortPath(h)
            value=h.Path;
            if(ispc()&&h.exists())
                value=RTW.transformPaths(h.Path,'pathType','alternate');
            end
        end

        function value=get.LongPath(h)
            value=h.Path;
            if(ispc()&&h.exists())
                value=RTW.transformPaths(h.Path,'pathType','full');
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


        function relPath=relativePathTo(h,inputPath)
            relPath=h.Path;
            if(~isa(inputPath,'linkfoundation.util.Location'))
                inputPath=linkfoundation.util.Location(inputPath);
            end
            if(isempty(h.Path)||isempty(inputPath.Path))
                return;
            end
            runningIndex=0;
            if(ispc())
                if(~strcmpi(inputPath.Drive,h.Drive))


                    return;
                end
            else

                if isequal(relPath(1),'.')
                    return;
                end
            end



            relPath='';










            inputTokens=textscan(inputPath.Path,'%s','Delimiter',strrep(filesep,'\','\\'),'MultipleDelimsAsOne',true);
            objectTokens=textscan(h.Path,'%s','Delimiter',strrep(filesep,'\','\\'),'MultipleDelimsAsOne',true);
            for index=1:length(inputTokens{1,1})
                runningIndex=index;
                input=char(inputTokens{1,1}(index));
                if(length(objectTokens{1,1})<index)


                    relPath=sprintf('%s..%c',relPath,filesep);
                    continue;
                end
                object=char(objectTokens{1,1}(index));

                if(ispc())
                    comparison=@strcmpi;
                else
                    comparison=@strcmp;
                end

                if(comparison(input,object))
                    continue;
                else
                    for inputIndex=index:length(inputTokens{1,1})
                        relPath=sprintf('%s..%c',relPath,filesep);
                    end
                    for objectIndex=index:length(objectTokens{1,1})
                        object=char(objectTokens{1,1}(objectIndex));
                        relPath=sprintf('%s%s%c',relPath,object,filesep);
                    end
                    break;
                end
            end
            if(isempty(relPath))
                relPath=['.',filesep];
                for objectIndex=(runningIndex+1):length(objectTokens{1,1})
                    object=char(objectTokens{1,1}(objectIndex));
                    relPath=sprintf('%s%s%c',relPath,object,filesep);
                end
            end
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
                file=linkfoundation.util.File([h.Path,files(index).name]);
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
                directory=linkfoundation.util.Location([h.Path,files(index).name]);
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






        function[found,locations]=findFiles(h,name,recurse,first)

            found=false;
            locations={};
            if(3>nargin),recurse=false;end
            if(4>nargin),first=true;end

            files=h.files(name);
            if(isempty(files)&&recurse)
                doRecurse();
            else
                if(~isempty(files))
                    found=true;
                    locations{end+1}=linkfoundation.util.Location(h.Path);
                end
                if(~first&&recurse)
                    doRecurse();
                end
            end
            function doRecurse()
                subDirectories=h.directories();
                for index=1:length(subDirectories)
                    [hit,subLocations]=subDirectories{index}.findFiles(name,recurse,first);
                    if(hit)
                        found=hit;
                        locations=[locations,subLocations];%#ok
                        if(first)
                            break;
                        end
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


    methods(Static=true,Access='public')



        function absPath=rel2abs(relPath,base)
            absPath=perl('util_rel2abs.pl',relPath,base);
        end



        function unixStyle=convertToUnixPath(path)



            newPath=regexprep(path,'^(\\*)?','//');



            newPath=regexprep(newPath,'(\\*)?','/');
            unixStyle=newPath;
        end

    end


    methods


        function test=eq(obj1,obj2)
            if(ispc())


                test=strcmpi(obj1.LongPath,obj2.LongPath);
            else
                test=strcmp(obj1.Path,obj2.Path);
            end
        end

        function test=ne(obj1,obj2)
            test=~(obj1==obj2);
        end
    end
end
