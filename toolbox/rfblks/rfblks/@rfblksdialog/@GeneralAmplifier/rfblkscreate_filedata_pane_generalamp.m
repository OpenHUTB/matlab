function[items,layout,info]=rfblkscreate_filedata_pane_generalamp(...
    this,varargin)




    [tempitems,layout]=rfblkscreate_filedata_pane(this,varargin{:});

    [datasource,datasourceprompt,rfdataObj,rfdataObjprompt,file,...
    fileprompt,browse,interpMethod,interpMethodprompt,spacerMain]=...
    deal(tempitems{:});



    switch this.DataSource
    case 'RFDATA object'
        rfdataObj.Enabled=1;
        file.Enabled=0;
        browse.Enabled=0;

        try
            mydata=evalin('base',this.RFDATA);
        catch
            MaskWSVars=this.Block.MaskWsVariables;
            mydata=MaskWSVars(strcmpi('RFData',{MaskWSVars.Name})).Value;
            if~isa(mydata,'rfdata.data')
                mydata=rfdata.data('S_Parameters',[0,0;1,0],'Freq',1e9);
            end
        end


    case 'Data file'
        rfdataObj.Enabled=0;
        file.Enabled=1;
        browse.Enabled=1;
        if~isempty(strtrim(this.File))
            tempname=strtrim(this.File);
            temppath=fileparts(tempname);
            if isempty(temppath)
                myfile=which(tempname);
                tempinfo=dir(myfile);
            else
                myfile=tempname;
                tempinfo=dir(tempname);
            end
        else
            myfile='default.amp';
            tempinfo='';
            this.File='default.amp';
        end
        if isempty(tempinfo)
            tempinfo=dir(which('default.amp'));
        end
        Udata=this.Block.UserData;
        if all(isfield(Udata,{'Filename','Date','RFDATAObj'}))&&...
            ~isempty(Udata.Filename)&&~isempty(Udata.Date)&&...
            strcmp(Udata.Filename,myfile)&&...
            strcmp(Udata.Date,tempinfo(1).date)&&...
            isa(Udata.RFDATAObj,'rfdata.data')&&...
            hasreference(Udata.RFDATAObj)
            mydata=Udata.RFDATAObj;
        else
            tempbar=waitbar(0.1,'Loading file ...');
            try
                mydata=read(rfdata.data,this.File);
            catch
                tempname=fliplr(strtok(fliplr(this.File),filesep));
                try
                    mydata=read(rfdata.data,tempname);
                catch secondREADException
                    errordlg(secondREADException.message,...
                    [this.Block.Name,' Error Dialog']);
                    mydata=read(rfdata.data,'default.amp');
                end
            end
            for ii=2:10
                waitbar(ii/10)
            end
            close(tempbar)
            [isLibrary,isLocked]=this.isLibraryBlock(this.Block);
            if~isLibrary&&~isLocked
                if isfield(Udata,'RFDATAObj')&&...
                    isa(this.Block.UserData.RFDATAObj,'rfdata.data')
                    this.Block.UserData.Date='Changed';
                end
                this.Block.UserData.RFDATAObj=mydata;
            end
        end
    end

    opTab_Enable=false;
    Udata=this.Block.UserData;

    if isa(mydata,'rfdata.data')
        if hasreference(mydata)
            temp_filename=mydata.Reference.Filename;
            temp_date=mydata.Reference.Date;
        else
            temp_filename='';
            temp_date='';
        end

        if hasmultireference(mydata)
            opTab_Enable=true;
            multiref_filename_changed=true;

            if all(isfield(Udata,{'RefSel','Filename','Date'}))&&...
                ~isempty(Udata.Filename)&&~isempty(Udata.Date)&&...
                strcmp(Udata.Filename,mydata.Reference.Filename)&&...
                strcmp(Udata.Date,mydata.Reference.Date)&&...
                Udata.RefSel<=numel(mydata.Reference.References)
                mydata.Reference.Selection=Udata.RefSel;
                multiref_filename_changed=false;
            end
        end
        refobj=getreference(mydata);

    elseif isa(mydata,'rfdata.reference')
        refobj=mydata;
        temp_filename=mydata.Filename;
        temp_date=mydata.Date;

    elseif isa(mydata,'rfdata.network')
        refobj=rfdata.reference('NetworkData',mydata);
        temp_filename=refobj.Filename;
        temp_date=refobj.Date;

    else
        refobj=[];
        temp_filename='';
        temp_date='';

    end

    filename_changed=true;
    if all(isfield(Udata,{'Filename','Date'}))&&...
        strcmp(Udata.Filename,temp_filename)&&...
        strcmp(Udata.Date,temp_date)
        filename_changed=false;
    end
    if filename_changed
        [isLibrary,isLocked]=this.isLibraryBlock(this.Block);
        if~isLibrary&&~isLocked
            this.Block.UserData.Filename=temp_filename;
            this.Block.UserData.Date=temp_date;
            this.Block.UserData.RefSel=1;
            this.Block.UserData.ConditionNames='';
            this.Block.UserData.ConditionValues='';
        end
    end

    if isa(refobj,'rfdata.reference')
        p2ddata=get(refobj,'P2DData');
        noisedata=get(refobj,'NoiseData');
        nfdata=get(refobj,'NFData');
        powerdata=get(refobj,'PowerData');
        ip3data=get(refobj,'IP3Data');
        OneDBC=get(refobj,'OneDBC');
        PS=get(refobj,'PS');
        GCS=get(refobj,'GCS');
    else
        p2ddata=[];
        noisedata=[];
        nfdata=[];
        powerdata=[];
        ip3data=[];
        OneDBC=[];
        PS=[];
        GCS=[];
    end

    if~opTab_Enable
        multiref_filename_changed=false;
    end
    info={opTab_Enable,multiref_filename_changed,mydata,noisedata,...
    nfdata,powerdata,ip3data,p2ddata,OneDBC,PS,GCS};

    items={datasource,datasourceprompt,rfdataObj,rfdataObjprompt,...
    file,fileprompt,browse,interpMethod,interpMethodprompt,spacerMain};

