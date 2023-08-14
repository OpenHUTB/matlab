function[moduleinfo,parserinfo,codeinfo]=parseVlogModule(filename,modulename)

















    if nargin==1
        [~,modulename,~]=fileparts(filename);
    end

    parser=eda.internal.hdlparser.VlogParser(filename,modulename);
    [moduleinfo,parserinfo,codeinfo]=parser.parse;












