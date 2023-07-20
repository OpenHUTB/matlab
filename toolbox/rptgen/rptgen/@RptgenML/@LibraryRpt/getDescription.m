function d=getDescription(this,varargin)








    isForce=false;
    isUpdate=false;
    if~isempty(varargin)
        if islogical(varargin{1})
            isForce=varargin{1};
        elseif ischar(varargin{1})
            switch varargin{1}
            case '-deferred'
                if isempty(this.Description)
                    this.Description=getString(message('rptgen:RptgenML_LibraryRpt:loadingReportMsg'));

                    mlreportgen.utils.internal.defer(@()this.getDescription('-forceupdate'));
                end
            case '-update'
                isUpdate=true;
            case '-force'
                isForce=true;
            case '-forceupdate'
                isUpdate=true;
                isForce=true;
            end
        end
    end

    if isempty(this.Description)||isForce
        try
            d=rptgen.getRptDescription(fullfile(this.PathName,this.FileName));
        catch ME
            d=[getString(message('rptgen:RptgenML_LibraryRpt:errorLoadingReportMsg')),newline(),ME.message];
        end

        if isempty(d)
            d=getString(message('rptgen:RptgenML_LibraryRpt:noDescMsg'));
        end

        this.Description=d;
    else
        d=this.Description;
    end

    if isUpdate

        r=RptgenML.Root;
        if~isempty(r.Editor)
            dlg=r.Editor.getDialog;
            if~isempty(dlg)
                dlg.refresh;
            end
        end
    end


