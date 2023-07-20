classdef File<linkfoundation.util.Location




    properties
        Name='';
        Extension='';
    end

    properties(Dependent=true,Access='public')
EscapedFullPathName
FullPathName
FileName
LongFullPathName
ShortFullPathName
    end

    methods

        function value=get.Name(h)
            value=h.Name;
        end

        function value=get.Extension(h)
            value=h.Extension;
        end

        function value=get.FullPathName(h)
            value=[h.Path,h.Name,h.Extension];
        end

        function value=get.FileName(h)
            value=[h.Name,h.Extension];
        end



        function value=get.EscapedFullPathName(h)
            value=[h.EscapedPath,h.Name,h.Extension];
        end


        function value=get.ShortFullPathName(h)
            value=h.FullPathName;
            if(ispc()&&h.exists())
                value=RTW.transformPaths(h.FullPathName,'pathType','alternate');
            end
        end


        function value=get.LongFullPathName(h)
            value=h.FullPathName;
            if(ispc()&&h.exists())
                value=RTW.transformPaths(h.FullPathName,'pathType','full');
            end
        end
    end

    methods(Access='public')
        function h=File(name)



            args={};
            if(0~=nargin)
                if(isa(name,'linkfoundation.util.File'))
                    name=name.FullPathName;
                end
                args{1}=fileparts(name);
            end
            h=h@linkfoundation.util.Location(args{:});
            if(0~=nargin)
                [~,h.Name,h.Extension]=fileparts(name);
            end
        end

        function value=exists(h)
            value=false;
            if(2==exist(h.FullPathName,'file'))
                value=true;
            end
        end


        function relPath=relativePathTo(h,path)
            relPath=sprintf('%s%s',relativePathTo@linkfoundation.util.Location(h,path),h.FileName);
        end

        function test=containsSpaces(h)
            test=false;
            if(any(h.FullPathName==' '))
                test=true;
            end
        end



        function value=widthContrainedDisplay(h,w)
            value=h.FullPathName;





            pixelsPerCharacter=8;
            neededWidth=length(value)*pixelsPerCharacter;
            if(neededWidth>w)


                trimCount=((neededWidth-w)/pixelsPerCharacter)+3;
                if(length(h.FileName)>(length(h.FullPathName)-trimCount))


                    value=h.FileName;
                    return;
                end
                maxTrimCount=length(h.FullPathName)-length(h.FileName);
                if(trimCount>maxTrimCount)
                    trimCount=maxTrimCount;
                end
                value=['...',value(trimCount:length(value))];
            end
        end
    end

    methods(Static=true,Access='public')

        function str=replaceFileExtension(name,ext)
            [path,name]=fileparts(name);
            str=fullfile(path,[name,ext]);
        end
    end


    methods


        function test=eq(obj1,obj2)
            if(ispc())


                test=strcmpi(obj1.LongFullPathName,obj2.LongFullPathName);
            else
                test=strcmp(obj1.FullPathName,obj2.FullPathName);
            end
        end

        function test=ne(obj1,obj2)
            test=~(obj1==obj2);
        end
    end
end
