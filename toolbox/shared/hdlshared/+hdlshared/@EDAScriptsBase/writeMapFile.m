function writeMapFile(this,varargin)


    fname=fullfile(this.CodeGenDirectory,[this.TopLevelName,this.MapFilePostFix]);

    enames=this.entityNames;

    pathlist=strrep(this.EntityPathList,newline,' ');
    pathlist=strrep(pathlist,'\','\\');


    if~hdlgetparameter('vhdl_package_required')&&isempty(pathlist{1})
        pathlist(1)=[];
    end

    if length(pathlist)==length(enames)
        map=strcat(pathlist,{[' ',this.HdlMapArrow,' ']},enames,'\n');
    else
        map={};
    end

    if~isempty(map)
        fid=fopen(fname,'w');

        if fid==-1
            error(message('HDLShared:hdlshared:mapopenfile'));
        end
        fprintf(fid,[map{:}]);

        fclose(fid);
    end

