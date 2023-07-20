function tf=genConnectivity(new_genConn)

























    mlock;
    persistent genC;

    if isempty(genC),
        genC=false;
    end


    tf=genC;


    if nargin>0,
        genC=new_genConn;
    end
