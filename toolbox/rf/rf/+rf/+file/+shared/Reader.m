classdef Reader<handle


    properties(SetAccess=protected)
Filename
    end

    properties(Abstract,SetAccess=protected)
MainCommentChar
DataSections
    end

    methods
        function obj=Reader(fname)
            obj.Filename=fname;
            fid=fopen(fname,'r');
            if fid==-1

                error(message('rf:rffile:shared:CannotOpenFile',fname))
            end


            numinitlines=512;
            buff=textscan(fid,'%s',numinitlines,...
            'Delimiter','','CommentStyle',obj.MainCommentChar);
            buff=buff{1};
            netdata={};
            while~isempty(buff)
                netdata=vertcat(netdata,buff);%#ok<AGROW>

                buff=textscan(fid,'%s',2*length(buff),...
                'Delimiter','','CommentStyle',obj.MainCommentChar);
                buff=buff{1};
            end


            fclose(fid);

            processnetdata(obj,netdata)
        end
    end

    methods
        function set.Filename(obj,newfname)
            validateattributes(newfname,{'char'},{'row'},'','Filename',1)
            obj.Filename=newfname;
        end
    end

    methods(Abstract,Access=protected,Hidden)
        processnetdata(obj,netdata)
    end

    methods(Abstract)
        trimtrailingcomments(obj,linestr)
        [dblN,lenN,nidx]=reacttostrindataline(obj,linestr,nidx);
    end
end