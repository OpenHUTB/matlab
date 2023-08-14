function varargout=privhdllib_library_browser(inputOption)



    persistent oldTitleStr

    narginchk(1,1);

    if(isempty(oldTitleStr))
        oldTitleStr='';
    end

    if(strcmpi(inputOption,'checkState'))


        varargout{1}=~isempty(oldTitleStr);
        return
    else


        resetLibraryBrowser=inputOption;
    end


    if(resetLibraryBrowser)
        privhdllibstate('reset');
        disp(message('hdlsllib:hdlsllib:hdllibrevert_info1').getString())
    else
        privhdllibstate('set');
        disp(message('hdlsllib:hdlsllib:hdllib_info1').getString())
        disp(message('hdlsllib:hdlsllib:hdllib_info2').getString())
    end


    sl_refresh_customizations();


    hLib=slLibraryBrowser();


    if(resetLibraryBrowser)
        if~isempty(oldTitleStr)
            hLib.setTitle(oldTitleStr{end});
            oldTitleStr(end)=[];
        end
    else
        hdllib_title=message('hdlsllib:hdlsllib:hdllib_title').getString();
        if strcmpi(hdllib_title,hLib.getTitle().getTranslatedString())

            oldTitleStr{end+1}=oldTitleStr{end};
        else

            oldTitleStr{end+1}=hLib.getTitle().getTranslatedString();
        end
        hLib.setTitle(hdllib_title);
    end
end
