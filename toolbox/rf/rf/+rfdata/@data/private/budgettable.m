function datatable=budgettable(h,ydata,ynames,yformats,xdata,xname,xunit)





    nparams=numel(ydata);
    nStages=h.BudgetData.nCkts;
    nxdata=length(xdata)/nStages;
    nrow=nStages*nparams+1;
    ncolumn=nxdata+1;
    datatable=cell(ncolumn,nrow);

    if isempty(xunit)
        datatable{1,1}=xname;
    else
        datatable{1,1}=[xname,' ',xunit];
    end
    for ii=1:nparams
        yformat=modifyformat(h,yformats{ii},2);
        if isempty(yformat)
            yparam=simplifytip(h,ynames{ii});
        else
            yparam=[simplifytip(h,ynames{ii}),' [',yformat,']'];
        end
        for jj=1:nStages
            datatable{1,(ii-1)*nStages+jj+1}=['Stage ',num2str(jj),': ',yparam];
        end
    end
    for kk=1:nxdata
        datatable{kk+1,1}=xdata(kk);
        for ii=1:nparams
            for jj=1:nStages
                datatable{kk+1,(ii-1)*nStages+jj+1}=ydata{ii}((jj-1)*nxdata+kk);
            end
        end
    end