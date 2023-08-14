function parser=restoreParser




    parser=inputParser;


    inputName='prerestoreclosefiles';
    defaultval='all';
    addParameter(parser,inputName,defaultval,@ischar);

    inputName='postrestoreloadstate';
    defaultval=0;
    addParameter(parser,inputName,defaultval,@islogical);
end


