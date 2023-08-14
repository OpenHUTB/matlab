classdef File<hwconnectinstaller.util.Location




    properties
        Name='';
        Extension='';
    end
    properties(Dependent=true,Access='public')
FullPathName
FileName
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
    end
    methods(Access='public')
        function h=File(name)



            args={};
            if(0~=nargin)
                if(isa(name,'hwconnectinstaller.util.File'))
                    name=name.FullPathName;
                end
                args{1}=fileparts(name);
            end
            h=h@hwconnectinstaller.util.Location(args{:});
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
        function test=containsSpaces(h)
            test=false;
            if(any(h.FullPathName==' '))
                test=true;
            end
        end
    end

end

