

function privhdllib_single_library(varargin)




    db=slhdlcoder.HDLImplDatabase;
    db.buildDatabase;


    cm=slhdlcoder.ConfigurationManager('hdlsupported',db);

    cm.parseConfiguration(db,'');





    args=varargin(find(cellfun(@length,varargin)));%#ok<FNDSB>

    buildLibrary(db,cm,args{:});

end
