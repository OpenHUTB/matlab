function display(this)%#ok




    fprintf(1,'\n');

    if numel(this)>1
        fprintf(1,'%s =\n\n',inputname(1));
        builtin('disp',this);
        return
    end

    if isempty(this)
        fprintf(1,'%s =\n\n  0x0 cvdata\n\n',inputname(1));
        return
    end
    id=this.id;

    fprintf(1,'%s = ... %s\n',inputname(1),class(this));
    if~this.isLoaded
        cv.internal.cvdata.checkFileRef(this);
        fprintf(1,'               file: %s\n',this.fileRef.name);
        fprintf(1,'               date: %s\n',datestr(this.fileRef.datenum));
        return
    end


    if id>0||(~isempty(this.localData)&&isfield(this.localData,'dbVersion'))
        dbVersion=this.dbVersion;
    else
        dbVersion='[]';
    end
    fprintf(1,'            version: %s\n',dbVersion);
    fprintf(1,'                 id: %g\n',id);

    if id>0
        this.checkId();

        fprintf(1,'               type: %s\n',this.type);
        fprintf(1,'               test: cvtest object\n');
        fprintf(1,'             rootID: %g\n',this.rootID);
        fprintf(1,'           checksum: [1x1 struct]\n');
        fprintf(1,'          modelinfo: [1x1 struct]\n');
        fprintf(1,'          startTime: %s\n',this.startTime);
        fprintf(1,'           stopTime: %s\n',this.stopTime);
        fprintf(1,'  intervalStartTime: %d\n',this.intervalStartTime);
        fprintf(1,'   intervalStopTime: %d\n',this.intervalStopTime);
        fprintf(1,'simulationStartTime: %d\n',this.simulationStartTime);
        fprintf(1,' simulationStopTime: %d\n',this.simulationStopTime);
        if iscell(this.filter)
            filterFiles=join(this.filter,',');
            filterFiles=filterFiles{1};
        else
            filterFiles=this.filter;
        end
        fprintf(1,'             filter: %s\n',filterFiles);
    else
        fprintf(1,'               type: DERIVED_DATA\n');
        fprintf(1,'               test: []\n');
        if isempty(this.localData)||~isfield(this.localData,'rootId')
            fprintf(1,'             rootID: []\n');
        else
            fprintf(1,'             rootID: %g\n',this.localData.rootId);
        end
        fprintf(1,'           checksum: [1x1 struct]\n');
        fprintf(1,'          modelinfo: [1x1 struct]\n');
        if isempty(this.localData)||~isfield(this.localData,'startTime')
            fprintf(1,'          startTime: []\n');
            fprintf(1,'           stopTime: []\n');
            fprintf(1,'  intervalStartTime: []\n');
            fprintf(1,'   intervalStopTime: []\n');
        else
            fprintf(1,'          startTime: %s\n',datestr(this.localData.startTime));
            fprintf(1,'           stopTime: %s\n',datestr(this.localData.stopTime));
            fprintf(1,'  intervalStartTime: %d\n',this.localData.intervalStartTime);
            fprintf(1,'   intervalStopTime: %d\n',this.localData.intervalStopTime);
        end
        if isempty(this.localData)||~isfield(this.localData,'covFilter')
            fprintf(1,'             filter: []\n');
        else
            if iscell(this.localData.covFilter)
                filterFiles=join(this.localData.covFilter,',');
                filterFiles=filterFiles{1};
            else
                filterFiles=this.localData.covFilter;
            end
            fprintf(1,'             filter: %s\n',filterFiles);
        end
    end

    if id>0||(~isempty(this.localData)&&isfield(this.localData,'simMode'))
        mode=char(SlCov.CovMode(this.simMode));
    else
        mode='[]';
    end
    fprintf(1,'            simMode: %s\n',mode);

    fprintf(1,'\n');


