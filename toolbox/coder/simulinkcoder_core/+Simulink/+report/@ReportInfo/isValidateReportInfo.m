function out=isValidateReportInfo(obj,varargin)



    out=true;
    narginchk(1,3);
    sys='';
    buildFolder='';
    if nargin>1
        sys=convertStringsToChars(varargin{1});
    end
    if nargin>2
        buildFolder=convertStringsToChars(varargin{2});
    end

    if~isempty(sys)
        if~ischar(sys)
            sys=getfullname(sys);
        end
        [~,remain]=strtok(sys,':/');
        isSubsystemBuild=~isempty(remain);
        if isSubsystemBuild

            if isempty(obj.SourceSubsystem)||...
                (~strcmp(obj.SourceSubsystem,sys)&&~contains(sys,'/'))||...
                (~strcmp(obj.SourceSubsystemFullName,sys)&&contains(sys,'/'))
                out=false;
                return
            end
        else
            if~strcmp(obj.ModelName,sys)
                out=false;
                return
            end
        end
    end
    if~isempty(buildFolder)
        out=strcmp(buildFolder,obj.BuildDirectory);
    end
end
