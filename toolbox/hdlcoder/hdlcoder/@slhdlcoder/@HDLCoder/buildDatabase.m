function db=buildDatabase(this,enableDeprecation)



    if(nargin<2)
        enableDeprecation=true;
    end

    db=this.ImplDB;


    if isempty(db)
        db=slhdlcoder.HDLImplDatabase;
        this.ImplDB=db;
    end

    db.buildDatabase(enableDeprecation);
end