function varargout=refreshReportList(this,startStop)









    persistent CONTINUE_SEARCH;


    if nargin<2
        CONTINUE_SEARCH=true;
    elseif islogical(startStop)
        CONTINUE_SEARCH=startStop;
    elseif ischar(startStop)
        if strcmpi(startStop,'-deferred')


            if isa(this.ReportList,'RptgenML.Library')
                varargout{1}='-noop';
            else
                varargout{1}='-invalidate';
                tempLib=RptgenML.Library;
                for i=1:length(this.ReportList)
                    if isa(this.ReportList(i),'RptgenML.LibraryRpt')
                        connect(this.ReportList(i),tempLib,'up');
                    end
                end
                this.ReportList=tempLib;
            end
            return;
        elseif strcmpi(startStop,'-invalidate')



            if~isempty(this.ReportList)
                if~isa(this.ReportList,'rptgen.DAObject')
                    this.ReportList=[];
                else
                    rLib=find(this.ReportList,'-isa','RptgenML.LibraryRpt');
                    for i=1:length(rLib)



                        disconnect(rLib(i));
                    end
                    this.ReportList=rLib;
                end
            end


        end
        CONTINUE_SEARCH=false;
    end


    if CONTINUE_SEARCH

        if isempty(this.ReportList)
            oldList=[];
        else
            oldList=find(this.ReportList,'-isa','RptgenML.LibraryRpt');



            oldReportListObject=this.ReportList;
        end



        this.ReportList=RptgenML.Library;

        pSep=pathsep;

        if isempty(findstr(lower(pwd),lower(path)));
            pathString=[pSep,pwd,pSep,path,pSep];
        else
            pathString=[pSep,path,pSep];
        end

        breakIndex=findstr(pathString,pSep);

        initLength=0;
        lastIndex=length(breakIndex)-1;
        dirIdx=1;
        ed=DAStudio.EventDispatcher;

        while dirIdx<=lastIndex&&CONTINUE_SEARCH
            myDir=pathString(breakIndex(dirIdx)+1:breakIndex(dirIdx+1)-1);
            myCat=[];

            fileList=dir([myDir,filesep,'*.rpt']);
            if~isempty(fileList)
                for fileIdx=1:length(fileList)

                    addFile=true;
                    if length(fileList(fileIdx).name)>6&&strcmpi(fileList(fileIdx).name(end-6:end),'-v1.rpt')

                        addFile=false;
                    end

                    if addFile
                        [libRpt,myCat]=this.addLibraryRpt(myCat,fileList(fileIdx).name,myDir);
                    end
                end
            end
            dirIdx=dirIdx+1;
        end

        for i=1:length(oldList)









            this.findRptByName(oldList(i),...
            true,...
            false);
        end

        if isempty(this.ReportList.down)

            msg=getString(message('rptgen:RptgenML_Root:noFilesFoundLabel'));
            connect(RptgenML.LibraryRpt(msg,''),this.ReportList,'up');
        end


        if isa(this.Editor,'DAStudio.Explorer')
            ed.broadcastEvent('ListChangedEvent',[]);




            ime=DAStudio.imExplorer(this.Editor);
            ime.enableListSorting(false,'Name',false,false);
        end
    end

    if nargout>0
        if isempty(this.ReportList)
            varargout{1}=[];
        else
            varargout{1}=find(this.ReportList,'-isa','RptgenML.LibraryRpt');
        end
    end
