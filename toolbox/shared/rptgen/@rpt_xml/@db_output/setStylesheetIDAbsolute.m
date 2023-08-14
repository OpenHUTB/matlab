function setStylesheetIDAbsolute(this,ss)














    if isa(ss,'RptgenML.StylesheetEditor')

    elseif ischar(ss)
        r=RptgenML.Root;
        if~isempty(r.StylesheetLibrary)
            ssFound=find(r.StylesheetLibrary,...
            '-isa','RptgenML.StylesheetEditor',...
            'ID',ss);
        end

        if isempty(ssFound)
            ss=RptgenML.StylesheetEditor(ss);




        else
            ss=ssFound;
        end
    elseif isa(ss,'com.mathworks.toolbox.rptgencore.tools.StylesheetMaker')
        ss=RptgenML.StylesheetEditor(ss);
    else
        error(message('rptgen:rx_db_output:unrecognizedStylesheetInput'));
    end

    switch ss.TransformType
    case 'html'
        ssProp='StylesheetHTML';
        preferredFormat='html';
    case 'fo'
        ssProp='StylesheetFO';
        preferredFormat='pdf';
    case 'dsssl'
        ssProp='StylesheetDSSSL';
        preferredFormat='rtf97';

    case 'dssslhtml'
        ssProp='StylesheetDSSSL';

        preferredFormat='dsssl-html';
    case 'latex'
        ssProp='StylesheetLaTeX';
        preferredFormat='latex';
    case 'dotx'
        ssProp='StylesheetDOTX';
        preferredFormat='dotx';
    otherwise
        ssProp='';
        preferredFormat='db';
    end

    set(this,'Format',preferredFormat);
    if~isempty(ssProp)
        set(this,ssProp,ss.ID);
    end


