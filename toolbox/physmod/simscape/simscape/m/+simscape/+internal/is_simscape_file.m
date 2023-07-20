function[isSimscapeFile]=is_simscape_file(fullFileName)












    isSimscapeFile=false;%#ok<NASGU>




    [~,~,tSuffix]=fileparts(fullFileName);




    if~strcmpi(tSuffix,'.m')&&...
        ~strcmpi(tSuffix,'.p')&&...
        ~strcmpi(tSuffix,'.ssc')&&...
        ~strcmpi(tSuffix,'.sscp')
        isSimscapeFile=false;
        return;
    end





    if strcmpi(tSuffix,'.ssc')||strcmpi(tSuffix,'.sscp')
        isSimscapeFile=true;
        return;
    end



    functionOfFile=pm_pathtofunctionhandle(fullFileName);




    try
        returnObj=feval(functionOfFile);
    catch tmpException %#ok<NASGU>
        isSimscapeFile=false;
        return;
    end

    if isa(returnObj,'NetworkEngine.ElementSchema')
        isSimscapeFile=true;
    else
        if isa(returnObj,'NetworkEngine.DomainSchema')
            isSimscapeFile=true;
        else
            isSimscapeFile=false;
        end
    end

    return;
end

