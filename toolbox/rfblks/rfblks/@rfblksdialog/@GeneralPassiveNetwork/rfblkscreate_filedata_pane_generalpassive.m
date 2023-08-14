function[items,layout,info]=...
    rfblkscreate_filedata_pane_generalpassive(this,varargin)




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
            myfile='passive.s2p';
            tempinfo='';
            this.File='passive.s2p';
        end
        if isempty(tempinfo)
            tempinfo=dir(which('passive.s2p'));
        end
        Udata=this.Block.UserData;
        if all(isfield(Udata,{'Filename','Date','RFDATAObj'}))&&...
            ~isempty(Udata.Filename)&&...
            ~isempty(Udata.Date)&&...
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
                    mydata=read(rfdata.data,'passive.s2p');
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

    Udata=this.Block.UserData;

    if isa(mydata,'rfdata.data')
        if hasreference(mydata)
            temp_filename=mydata.Reference.Filename;
            temp_date=mydata.Reference.Date;
        else
            temp_filename='';
            temp_date='';
        end

    elseif isa(mydata,'rfdata.reference')
        temp_filename=mydata.Filename;
        temp_date=mydata.Date;

    elseif isa(mydata,'rfdata.network')
        refobj=rfdata.reference('NetworkData',mydata);
        temp_filename=refobj.Filename;
        temp_date=refobj.Date;

    else
        temp_filename='';
        temp_date='';
    end

    filename_changed=true;
    if all(isfield(Udata,{'Filename','Date'}))&&...
        strcmp(Udata.Filename,temp_filename)...
        &&strcmp(Udata.Date,temp_date)
        filename_changed=false;
    end
    if filename_changed
        [isLibrary,isLocked]=this.isLibraryBlock(this.Block);
        if~isLibrary&&~isLocked
            this.Block.UserData.Filename=temp_filename;
            this.Block.UserData.Date=temp_date;
        end
    end

    items={datasource,datasourceprompt,rfdataObj,rfdataObjprompt,...
    file,fileprompt,browse,interpMethod,interpMethodprompt,spacerMain};

    info={mydata};

