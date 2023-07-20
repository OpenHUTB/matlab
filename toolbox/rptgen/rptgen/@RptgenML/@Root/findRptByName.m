function rpt=findRptByName(this,rName,includeLibrary,includeOpen)





    rDesc='';
    if ischar(rName)
        if isSimulinkModel(rName,this)
            rName=rptgen.findSlRptName(rName);
        end
        [rptPath,rptFile,rptExt]=fileparts(rName);

    elseif isa(rName,'RptgenML.LibraryRpt')


        rDesc=rName.Description;
        rptPath=rName.PathName;


        dotLoc=findstr(rName.FileName,'.');
        if~isempty(dotLoc)
            rptFile=rName.FileName(1:dotLoc(end)-1);
            rptExt=rName.FileName(dotLoc(end):end);
        else
            rptFile=rName.FileName;
            rptExt='';
        end

        rName=fullfile(rptPath,rName.FileName);
    else

        rpt=[];
        return;
    end


    if nargin<4||includeOpen
        f=@(rptFileName)(locMatchedName(rptFileName,rptPath,rptFile,rptExt));
        rpt=find(this,...
        '-depth',1,...
        '-isa','rptgen.coutline',...
        '-function','RptFileName',f);%#ok

        if~isempty(rpt)
            rpt=rpt(1);
            return;
        end
    end

    if nargin>2&&includeLibrary
        if~isempty(this.ReportList)
            if~isempty(rptPath)
                searchTerms={'PathName',rptPath};
            else
                searchTerms={};
            end

            if isempty(rptExt)
                rptExt='.rpt';
            end




            searchTerms=[searchTerms,...
            {'FileName',[rptFile,rptExt]}];

            rpt=find(this.ReportList,...
            '-isa','RptgenML.LibraryRpt',...
            searchTerms{:});
        else
            rpt=[];
        end

        if isempty(rpt)

            rName=rptgen.findFile(rName,...
            'rpt',...
            false);
            if~isempty(rName)
                rpt=this.addLibraryRpt([],[rptFile,rptExt],rptPath);
                if~isempty(rDesc)
                    rpt.Description=rDesc;
                end



                if isa(this.Editor,'DAStudio.Explorer')
                    ed=DAStudio.EventDispatcher;
                    ed.broadcastEvent('ListChangedEvent',[]);

                end
            end
        else
            rpt=rpt(1);
        end
    end


    function tf=locMatchedName(childName,rptPath,rptFile,rptExt)

        [childPath,childFile,childExt]=fileparts(childName);

        tf=(isempty(rptPath)||strcmpi(childPath,rptPath))&&...
        (isempty(rptFile)||strcmpi(childFile,rptFile))&&...
        (isempty(rptExt)||strcmpi(childExt,rptExt));

