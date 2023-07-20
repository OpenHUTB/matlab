function dir_out=getConnectivityDirector(director_in)











    mlock;
    persistent director;

    if nargin>0,
        director=director_in;
    end
    dir_out=director;



