function c=getChildren(this)




    c=[];

    f=find(this,'-isa','SlCovResultsExplorer.Data','-depth',1);%#ok

    for cf=f'
        c=[c,cf,cf.getAllChildren'];%#ok
    end


