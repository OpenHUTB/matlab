classdef Executable<linkfoundation.util.File




    properties(Dependent=true)
CommandLine
Command
    end

    properties(Access='private')
        Flags='';
    end

    properties(Access='public')
        Asynchronous=false;
    end

    methods


        function value=get.CommandLine(h)
            value=strtrim(h.Flags);
        end

        function value=get.Command(h)
            modifier='';
            if(h.Asynchronous)
                modifier='&';
            end
            value=sprintf('"%s" %s%s',h.FullPathName,h.CommandLine,modifier);
        end

        function value=get.Asynchronous(h)
            value=h.Asynchronous;
        end
        function set.Asynchronous(h,value)
            if(islogical(value))
                h.Asynchronous=value;
            end
        end
    end

    methods(Access='public')
        function h=Executable(name)
            args={};
            if(0~=nargin)
                args{1}=name;
            end
            h=h@linkfoundation.util.File(args{:});
        end

        function addFlags(h,flags)
            if(isempty(flags))
                return;
            end
            if(isempty(h.Flags))
                h.Flags=flags;
            else
                h.Flags=sprintf('%s %s',h.Flags,strtrim(flags));
            end
        end

        function[result,output]=execute(h)
            try
                command=h.Command;
                [result,output]=system(command);
            catch ex
                result=1;
                output=ex.message;
            end
        end

        function resetCommandLine(h)
            h.Flags='';
        end

        function disp(h)
            disp(h.Command);
        end
    end
end
