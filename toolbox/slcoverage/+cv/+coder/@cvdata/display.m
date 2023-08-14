



function display(this)%#ok

    fprintf(1,'\n');

    if isempty(this)
        fprintf(1,'%s =\n\n  0x0 cv.coder.cvdata\n\n',inputname(1));
        return
    end

    if numel(this)>1||~isvalid(this)
        fprintf(1,'%s =\n\n',inputname(1));
        builtin('disp',this);
        return
    end

    fprintf(1,'%s = ... %s\n',inputname(1),class(this));

    if~this.isLoaded
        cv.internal.cvdata.checkFileRef(this);
        fprintf(1,'               file: %s\n',this.fileRef.name);
        fprintf(1,'               date: %s\n',datestr(this.fileRef.datenum));
        return
    end

    fprintf(1,'            version: %s\n',this.dbVersion);
    fprintf(1,'               type: %s\n',this.type);
    if isempty(this.test)
        fprintf(1,'               test:\n');
    else
        fprintf(1,'               test: cv.coder.cvtest object\n');
    end
    fprintf(1,'           checksum: [1x1 struct]\n');
    fprintf(1,'         moduleinfo: [1x1 struct]\n');
    fprintf(1,'          startTime: %s\n',this.startTime);
    fprintf(1,'           stopTime: %s\n',this.stopTime);
    filter=this.filter;
    if iscellstr(filter)||isstring(filter)
        filterFiles=strjoin(filter,',');
    else
        filterFiles=filter;
    end
    fprintf(1,'             filter: %s\n',filterFiles);
    fprintf(1,'            simMode: %s\n',char(SlCov.CovMode(this.simMode)));
    fprintf(1,'\n');


