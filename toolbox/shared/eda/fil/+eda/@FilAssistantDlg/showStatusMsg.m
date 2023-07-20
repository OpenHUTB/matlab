function showStatusMsg(this,msg,mode)



    switch(mode)
    case 'append'
        this.Status=[this.Status,msg];
    otherwise
        this.Status=msg;
    end
