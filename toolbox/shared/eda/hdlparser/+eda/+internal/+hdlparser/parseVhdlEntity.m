function[entityinfo,parserinfo,codeinfo]=parseVhdlEntity(filename,entityname)


















    if nargin==1
        [~,entityname,~]=fileparts(filename);
    end

    h=eda.internal.hdlparser.VhdlParser(filename,entityname);
    [entityinfo,parserinfo,codeinfo]=h.parse;













