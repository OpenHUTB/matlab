function out=execute(this,d,varargin)






    adSL=rptgen_sl.appdata_sl;
    modelName=adSL.CurrentModel;




    if~RptgenRMI.option('toolsReqReport')
        mdlLoop=this.getParent.getParent;
        if isa(mdlLoop,'rptgen_sl.csl_mdl_loop')
            RptgenRMI.option('inheritLibLinksOption',~strcmp(mdlLoop.LoopList.isLibrary,'off'))
        end
    end


    if RptgenRMI.option('followLibraryLinks')

        [docs,sys,counts]=rmi('docs',modelName,'withLibs');
    else

        [docs,sys,counts]=rmi('docs',modelName,'all');
    end
    if isempty(docs)
        out=d.createComment(getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:NoRequirementsFound')));
        adSL.ReportedDocs={};
        return;
    end





    resolved=cell(size(docs));
    is_relative=false(size(docs));
    for i=1:length(docs)
        [resolved{i},is_relative(i)]=rmiprj.resolveDoc(docs{i},sys{i},modelName);
    end
    [resolved,sort_index]=sort(resolved);
    docs=docs(sort_index);
    sys=sys(sort_index);
    counts=counts(sort_index);
    is_relative=is_relative(sort_index);
    adSL.ReportedDocs=docs;


    switch this.TitleType
    case 'none'
        tTitle='';
    case 'name'
        tTitle=modelName;
    case 'manual'
        tTitle=rptgen.parseExpressionText(this.TableTitle);
    otherwise
        error(message('Slvnv:RptgenRMI:execute:InvalidTitleType'));
    end



    theTable={};
    colWid=[];


    col=1;
    colWid(col)=1;
    theTable{1,col}='ID';

    col=2;
    colWid(col)=9;
    theTable{1,col}=getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:DocumentPathsStoredInTheModel'));


    if this.includeDate
        col=col+1;
        colWid(col)=4;
        theTable{1,col}=getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:LastModified'));
    end


    if this.includeCount
        col=col+1;
        colWid(col)=1;
        theTable{1,col}=getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:NumberOfLinks'));
    end






    if ispc
        if rmidoors.isAppRunning('nodialog')
            use_DOORS=true;
        elseif this.useDOORS

            if any(strcmpi('doors',sys))||any(strcmpi('linktype_rmi_doors',sys))
                use_DOORS=rmidoors.isAppRunning('RMI report');
            else
                use_DOORS=false;
            end
        else
            use_DOORS=false;
        end
    else
        use_DOORS=false;
    end
    if use_DOORS
        adSL.ReportedDocsUseDOORS='on';
    else
        adSL.ReportedDocsUseDOORS='off';
    end


    for i=1:length(docs)


        col=1;
        theTable{i+1,col}=['DOC',num2str(i)];%#ok<*AGROW>


        col=col+1;
        link=rmiprj.rptHyperlinkForDoc(docs{i},resolved{i},sys{i},modelName,d);
        theTable{i+1,col}=link;


        if this.checkPaths&&is_relative(i)&&~isempty(resolved{i})
            same=find(strcmp(resolved{i},resolved));
            if length(same)>1&&i>same(1)
                theTable{i+1,col}=['WARNING: ',docs{i},' duplicates DOC',int2str(same(1))];
            end
        end


        if this.includeDate
            col=col+1;
            linkType=rmi.linktype_mgr('resolveByRegName',sys{i});
            if isempty(linkType)
                linkType=rmi.linktype_mgr('resolveByFileExt',docs{i});
            end
            if isempty(resolved{i})
                if~isempty(linkType)&&~isempty(linkType.DocDateFcn)
                    try
                        dateTimeString=feval(linkType.DocDateFcn,docs{i});
                        if isempty(dateTimeString)
                            theTable{i+1,col}=getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:FileNotFound'));
                        else
                            theTable{i+1,col}=dateTimeString;
                        end
                    catch Ex
                        if strcmp(Ex.identifier,'Simulink:Commands:OpenSystemUnknownSystem')
                            theTable{i+1,col}=getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:SystemNotFound'));
                        else
                            theTable{i+1,col}=getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:FileNotFound'));
                        end
                    end
                else
                    theTable{i+1,col}=getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:FileNotFound'));
                end
            else
                if~isempty(linkType)&&~isempty(linkType.DocDateFcn)
                    dateTimeString=feval(linkType.DocDateFcn,resolved{i});
                    if isnumeric(dateTimeString)
                        theTable{i+1,col}=datestr(dateTimeString);
                    else
                        theTable{i+1,col}=dateTimeString;
                    end
                elseif isempty(linkType)||linkType.IsFile
                    fileinfo=dir(resolved{i});
                    if isempty(fileinfo)
                        theTable{i+1,col}=getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:FileNotFound'));
                    else
                        theTable{i+1,col}=datestr(fileinfo.datenum);
                    end
                else
                    theTable{i+1,col}=getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:NA'));
                end
            end
        end

        if this.includeCount
            col=col+1;
            theTable{i+1,col}=num2str(counts(i));
        end
    end

    tm=makeNodeTable(d,...
    theTable,...
    0,...
    true);
    tm.setColWidths(colWid);
    tm.setTitle(tTitle);
    tm.setBorder(true);
    tm.setPageWide(false);
    tm.setNumHeadRows(1);
    tm.setNumFootRows(0);

    out=tm.createTable;


    if RptgenRMI.option('toolsReqReport')

        if RptgenRMI.option('docIndex')
            adSL.ReportedDocsUseIDs='on';
        else
            adSL.ReportedDocsUseIDs='off';
        end


    elseif this.useIDs
        adSL.ReportedDocsUseIDs='on';
    else
        adSL.ReportedDocsUseIDs='off';
    end
end

