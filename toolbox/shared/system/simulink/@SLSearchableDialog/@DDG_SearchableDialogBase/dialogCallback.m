function dialogCallback(this,dlg,tag,varargin)





    switch(tag)
    case 'case_option_tag'
        this.DialogData.CaseSensitive=varargin{1};

        if this.DialogData.CaseSensitive==true
            this.DialogData.hSearchFcn=@regexp;
        else
            this.DialogData.hSearchFcn=@regexpi;
        end

    case 'regexp_option_tag'
        this.DialogData.RegexpSupport=varargin{1};
    end

    refreshResultsImp(this,dlg);

end
