function c=loadRpt(fileName)




    foundFile=rptgen.findFile(fileName,'rpt');

    if isempty(foundFile)

        error(message('rptgen:rptgen:fileNotFound',fileName));
    else
        fileName=foundFile;
    end

    oldWarn=warning('off','MATLAB:unknownElementsNowStruc');





    loadResult=load(fileName,'-mat');
    warning(oldWarn);


    if isfield(loadResult,'rptgen_component_v2')
        c=loadResult.('rptgen_component_v2');
        if~isempty(c.findprop('RptFileName'))
            set(c,'RptFileName',fileName);
        end
    elseif~isempty(strmatch('hgS',fieldnames(loadResult)))


        try
            c=RptgenML.v1convert(fileName);
            if~isempty(c.findprop('RptFileName'))
                set(c,'RptFileName',fileName);
            end
            if~isempty(c.findprop('WarnOnSaveFilename'))
                set(c,'WarnOnSaveFilename',fileName);
            end
        catch
            error(message('rptgen:rptgen:conversionError'));
        end
    else
        c=[];
        error(message('rptgen:rptgen:loadError',fileName));
    end
