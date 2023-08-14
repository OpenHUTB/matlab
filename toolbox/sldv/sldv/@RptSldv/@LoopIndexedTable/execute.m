function out=execute(this,d,varargin)









    try

        [ct,title]=this.getContent;
        ct=sldv_processhtml(ct,d);
        if isempty(ct)
            out=createComment(d,getString(message('Sldv:RptSldv:LoopIndexedTable:execute:ComponentSkipped')));
            return;
        end
        tm=makeNodeTable(d,...
        ct,...
        0,...
        true,...
        this.ShrinkEntries*2048);
    catch Mex
        out=[];
        this.status(Mex.message,1);
        return;
    end

    nCols=tm.getNumCols;
    if nCols==0
        out='';
        this.status(getString(message('Sldv:RptSldv:LoopIndexedTable:execute:TableIsEmpty')),2);
        return;
    end

    tCells=tm.getContent;
    nRows=ceil(length(tCells)/nCols);

    nHeadRows=min(nRows,this.numHeaderRows);

    switch this.Footer
    case 'NONE'
        nFootRows=0;
    case 'COPY_HEADER'
        nFootRows=nHeadRows;
        oldLength=length(tCells);
        for i=nHeadRows*nCols:-1:1

            tCells(oldLength+i)=tCells(i).cloneNode(true);
        end
        tm.setContent(tCells);
    case 'LASTROWS'
        nFootRows=min(nRows-nHeadRows,this.numFooterRows);
    end

    if~isempty(this.ColumnWidths)
        cWid=this.ColumnWidths;
        if length(cWid)>nCols
            cWid=cWid(1:nCols);
        elseif length(cWid)<nCols
            if~isempty(cWid),
                cWid=[cWid,cWid(end)*ones(1,nCols-length(cWid))];
            else
                cWid=[cWid,ones(1,nCols-length(cWid))];
            end
        end

        tm.setColWidths(cWid);
    end


    if isempty(title)
        title=rptgen.parseExpressionText(this.TableTitle);
    end
    tm.setTitle(title);
    tm.setBorder(this.isBorder);
    tm.setGroupAlign(this.AllAlign);
    tm.setPageWide(this.isPgWide);
    tm.setNumHeadRows(nHeadRows);
    tm.setNumFootRows(nFootRows);

    out=tm.createTable;


    function processed_ct=sldv_processhtml(ct,d)
        processed_ct=[];
        if(isempty(ct))
            return;
        end

        processed_ct=ct;
        [m,n]=size(ct);
        for i=1:m
            for j=1:n
                nodeInfo=processed_ct{i,j};
                if isstruct(nodeInfo)





                    elmCnt=numel(nodeInfo);

                    if elmCnt>1
                        df=d.createDocumentFragment();
                    end

                    for idx=1:numel(nodeInfo)
                        info=nodeInfo(idx);
                        if isfield(info,'url')&&~isempty(info.url)
                            node=d.makeLink(info.url,info.disp,'matlab');
                        else
                            node=d.createTextNode(info.disp);
                        end

                        if isfield(info,'style')&&~isempty(info.style)
                            node=d.createElement('emphasis',node);
                            node.setAttribute('role',info.style);
                        end

                        if elmCnt>1
                            df.appendChild(node);
                        end
                    end

                    if elmCnt>1
                        processed_ct{i,j}=df;
                    else
                        processed_ct{i,j}=node;
                    end


                elseif iscell(nodeInfo)
                    allLinks='';
                    for k=1:length(nodeInfo)
                        subUrlInfo=nodeInfo{k};
                        if isstruct(subUrlInfo)
                            allLinks{end+1}=d.makeLink(subUrlInfo.url,subUrlInfo.disp,'matlab');%#ok<AGROW>
                        else
                            allLinks{end+1}=subUrlInfo;%#ok<AGROW>
                        end
                    end
                    processed_ct{i,j}=allLinks;
                end
            end
        end

