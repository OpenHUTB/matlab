function db=getImplDatabase(this)





    db=this.ImplDB;


    if isempty(db)
        db=this.buildDatabase;
    end

