function result=isAccessMethod(hCSCDefn,hData)




    if nargin==2
        assert(isa(hData,'Simulink.Data'));
    end

    result=strcmp(hCSCDefn.CSCType,'AccessFunction');


