function tf=acceptDrop(this,dropObjects)




    tf=false;

    if isempty(dropObjects)
        return;
    end

    for i=1:length(dropObjects)
        if isa(dropObjects(i),'RptgenML.StylesheetEditor')&&...
            ~isempty(dropObjects(i).ID)
            this.setStylesheetIDAbsolute(dropObjects(i));
            tf=true;
        elseif isa(dropObjects(i),'rptgen.coutline')
            setOutput(this,dropObjects(i).Output);
            tf=true;
        elseif isa(dropObjects(i),'rpt_xml.db_output')
            setOutput(this,dropObjects(i).Output);
            tf=true;
        elseif isa(dropObjects(i),'RptgenML.LibraryFile')
            this.SrcFileName=fullfile(dropObjects(i).PathName,dropObjects(i).FileName);
            tf=true;
        else

        end
    end

    if tf
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('PropertyChangedEvent',this);
        viewChild(RptgenML.Root,this);
    end


    function setOutput(this,o)

        copyProps={
'Format'
'StylesheetHTML'
'StylesheetFO'
'StylesheetLaTeX'
'StylesheetDSSSL'
'DstFileName'
'SrcFileName'
        };

        for i=1:length(copyProps)
            pVal=get(o,copyProps{i});
            if~isempty(pVal)
                this.(copyProps{i})=pVal;
            end
        end

