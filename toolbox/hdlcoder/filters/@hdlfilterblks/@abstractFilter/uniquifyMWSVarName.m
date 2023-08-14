function finalname=uniquifyMWSVarName(this,hws,givenname)






    mwsvars=hws.data;
    n=1;

    totalvars=length(mwsvars);
    mtched_indcs=[];
    if totalvars>0
        while n<=totalvars
            if strmatch(givenname,mwsvars(n).Name)
                mtched_indcs=[mtched_indcs,n];
            end
            n=n+1;
        end
    end

    newsuffix=max(mtched_indcs);
    finalname=[givenname,num2str(newsuffix)];



