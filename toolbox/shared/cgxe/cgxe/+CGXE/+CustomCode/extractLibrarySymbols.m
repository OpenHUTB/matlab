

function syms=extractLibrarySymbols(libNames,varargin)


    narginchk(1,inf);
    persistent argParser;
    if isempty(argParser)
        argParser=inputParser();
        argParser.addOptional('lang','c',@(x)((ischar(x)||isStringScalar(x))&&any(strcmpi(x,{'c','c++','cxx'}))));
    end
    argParser.parse(varargin{:});


    libNames=convertStringsToChars(libNames);


    lang=lower(convertStringsToChars(argParser.Results.lang));
    if strcmp(lang,'cxx')
        lang='c++';
    end
    isCxx=strcmp(lang,'c++');


    try
        syms=CGXE.CustomCode.cgxe_extract_objsyms_mex(libNames,isCxx&&false);
    catch
        syms=cell(0,1);
    end


