function msg=escapeOriginalMessage(exc)



    msg='';



    if~isa(exc,'MException')
        return;
    end

    msg=strrep(exc.message,'\','\\');


