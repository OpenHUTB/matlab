function dLabel=getDisplayLabel(this)




    if(this.Expanded)
        dLabel='-';
    else
        dLabel='+';
    end

    postLine=char('-'*ones(1,max(32-length(this.CategoryName),8)));

    dLabel=[dLabel,'  ',this.CategoryName,'  ',postLine];
