function inputs=parseInputs(varargin)




    parser=inputParser;





    inputName='filepath';
    defaultval=string.empty;
    addOptional(parser,inputName,defaultval,@isstring);

    inputName='xml';

    addOptional(parser,inputName,defaultval);

    inputName='fileinfo';
    defaultval=char.empty;
    addOptional(parser,inputName,defaultval);


    parse(parser,varargin{:});
    inputs=parser.Results;
end


