function parser=createParser




    parser=inputParser;


    inputName='createonmissingfiles';
    defaultval=0;
    addParameter(parser,inputName,defaultval,@islogical);

    inputName='forcesave';
    defaultval=0;
    addParameter(parser,inputName,defaultval,@islogical);
end


