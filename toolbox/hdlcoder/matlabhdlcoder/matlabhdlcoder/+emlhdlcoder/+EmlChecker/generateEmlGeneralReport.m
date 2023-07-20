


function generateEmlGeneralReport(X,fid)




    fprintf(fid,'<BR>');
    tableHeader(fid,getMsgCatalogString('MLProjectInfo'));
    emitTR(fid,{bold(getMsgCatalogString('MLNumFiles')),num2str(numel(X.pUserFcns))});
    emitTR(fid,{bold(getMsgCatalogString('MLNumLines')),num2str((X.pNrLines))});
    fprintf(fid,'</table class="table_footer">');
    fprintf(fid,'<BR>');




    fprintf(fid,'<BR>');
    tableHeader(fid,getMsgCatalogString('MLToolboxUsage'));

    tbx=X.ToolboxUsed;
    str='';
    if isempty(tbx)
        emitTR(fid,{'NONE'});
    else
        clen=numel(tbx);
        for k=1:clen

            str=[str,tbx{k}];%#ok<*AGROW>
            if k~=clen
                str=[str,'<BR>'];
            end
        end
        emitTR(fid,{'Name',str});
    end
    fprintf(fid,'</table>');
    fprintf(fid,'<BR>');





    displayFcnUsage(fid,X.pSupportedEML,1);
    displayFcnUsage(fid,X.pUnsupportedEML,0);

    if isempty(X.pUserFcns)
        return;
    end


    LUserFcns=numel(X.pUserFcns);
    LMEXFile=numel(X.pMEXFile);
    L=LUserFcns+LMEXFile;
    CallMatrix=zeros(LUserFcns,L);
    Table=cell(1,L);
    TableNrLines=zeros(L,1);
    for ii=1:LUserFcns
        Table{ii}=X.pUserFcns{ii}.pName;
        TableNrLines(ii)=X.pUserFcns{ii}.pNrLines;
    end
    for ii=1:LMEXFile
        Table{LUserFcns+ii}=X.pMEXFile{ii}.pName;
    end



    for nn=1:numel(X.pUserFcns)
        f=X.pUserFcns{nn};
        if~isempty(f.pCallTree)
            for jj=1:length(f.pCallTree)
                [isthere,loc]=ismember(f.pCallTree{jj},Table);
                if isthere
                    CallMatrix(nn,loc)=1;
                end
            end
        end
    end




    CumCallMatrix=CallMatrix;
    PrevCumCallMatrix=zeros(size(CumCallMatrix));
    while~isequal(CumCallMatrix,PrevCumCallMatrix)
        PrevCumCallMatrix=CumCallMatrix;

        for ii=1:size(CumCallMatrix,1)
            for jj=1:size(CumCallMatrix,2)


                if CumCallMatrix(ii,jj)
                    for kk=1:size(CumCallMatrix,1)
                        if CumCallMatrix(kk,ii)
                            CumCallMatrix(kk,jj)=1;
                        end
                    end
                end
            end
        end
    end






    CumNrLines=CumCallMatrix*TableNrLines+TableNrLines(1:LUserFcns);


    [~,sequence]=sort(CumNrLines);sequence=flipud(sequence(:));




    fcnStr=['<script><!--',char(10)...
    ,'function hdlTableShrink(o,tagNameStr)',char(10)...
    ,'{',char(10)...
    ,'var temp = document.getElementsByName(tagNameStr);',char(10)...
    ,'if (temp[0].style.display == "")',char(10)...
    ,'{',char(10)...
    ,'temp[0].style.display = "none";',char(10)...
    ,'o.innerHTML = ''<span style="font-family:monospace">[+]</span>'';',char(10)...
    ,'}',char(10)...
    ,'else',char(10)...
    ,'{',char(10)...
    ,'temp[0].style.display = "";',char(10)...
    ,'o.innerHTML = ''<span style="font-family:monospace">[-]</span>'';',char(10)...
    ,'}',char(10)...
    ,'}',char(10)...
    ,'// --></script>'];
    fprintf(fid,fcnStr);


    fprintf(fid,'<BR>');
    tableHeader(fid,getMsgCatalogString('MLListOfCalledFcns'));


    if~X.pObfuscate
        if numel(X.pUserFcns)>1

            for nn=1:numel(X.pUserFcns)
                f=X.pUserFcns{sequence(nn)};
                if~isempty(f.pCallTree)

                    fileName=f.pName;
                    clen=length(f.pCallTree);
                    cstr='';
                    for jj=1:clen



                        cn=f.pCallTree{jj};
                        cn=strtrim(strrep(cn,'(local)',''));
                        cname=fcnOpenLink(cn,fileName);
                        cstr=[cstr,cname];
                        if jj~=clen
                            cstr=[cstr,'<BR>'];
                        end
                    end
                    emitTR(fid,{bold(fileName),cstr});
                end
            end
        else
            emitTR(fid,{'NONE'});
        end
    end

    fprintf(fid,'</table>');
    fprintf(fid,'<BR>');

    fprintf(fid,'<BR>');
    tableHeader(fid,getMsgCatalogString('MLFcnCallsReqAttn'));


    goodFcns=[X.pUserFcns,X.pSupportedEML];
    if isempty(goodFcns)
        goodFcns={};
    else
        goodFcns=[goodFcns{:}];
        goodFcns={goodFcns(:).pName};
    end

    thereisnone=true;
    for k=1:numel(X.pUserFcns)
        f=X.pUserFcns{sequence(k)};

        cs=f.pCallees;
        badCallees=setdiff(cs,goodFcns);
        if~isempty(badCallees)
            thereisnone=false;

            fcnName=f.pName;
            if X.pObfuscate

            else

            end

            cstr='';
            clen=numel(badCallees);
            for i=1:clen

                cstr=[cstr,badCallees{i}];
                if i~=clen
                    cstr=[cstr,'<BR>'];
                end
            end

            emitTR(fid,{bold(fcnName),cstr});
            pp(fid,'\n');
        end
    end


    if thereisnone,emitTR(fid,{'NONE'});end

    fprintf(fid,'</table>');
    fprintf(fid,'<BR>');





    tableHeader(fid,getMsgCatalogString('MLCallTreeReport'));



    [~,loc]=ismember(X.pFilename,Table);
    if loc
        functionid=loc;

        pp(fid,'\n');
        FunctionUsed=false(1,L);

        if X.pObfuscate
            for ii=1:length(Table)
                Table{ii}=sprintf('File %d',ii);
            end
        end

        print_children(fid,functionid,CallMatrix,Table,FunctionUsed,loc);

    else
        disp(getMsgCatalogString('MLTopLvlNotFound'));
    end
    fprintf(fid,'</TABLE class="table_footer">');



end




function print_children(fid,functionid,callgraph,Table,FunctionUsed,parent)



    FunctionUsed(parent)=true;
    fprintf(fid,'<TR class="datatable"><TD><UL>');
    hasChildren=any(callgraph(functionid,:));
    parentName=Table{parent};
    fcnName=Table{functionid};
    if hasChildren
        ppTree(fid,fcnName,parentName);
    else
        pp(fid,'<li><H4>%s</H4></li>',fcnOpenLink(fcnName,parentName));
    end

    clen=size(callgraph,2);
    for child=1:clen
        if callgraph(functionid,child)

            if~FunctionUsed(child)
                if child<=size(callgraph,1)
                    print_children(fid,child,callgraph,Table,FunctionUsed,child);
                else

                    ppTree(fid,Table{child},parentName);
                end
            else

                ppTree(fid,Table{child},parentName);
            end
        end
    end

    if hasChildren
        fprintf(fid,'</span>');
    else
    end

    fprintf(fid,'</ul></TD></TR>');


end


function str=fcnOpenLink(fcnName,parent)
    fp=which(fcnName);

    if isempty(fp)
        if~isempty(which(fcnName,'in',parent))

            str=sprintf('<a href="matlab:matlab.desktop.editor.openAndGoToFunction(''%s'', ''%s'');">%s</a>',...
            which(parent),fcnName,fcnName);
        else
            str=sprintf('<a href="matlab:matlab.desktop.editor.openAndGoToFunction(''%s'', ''%s'');">%s</a>',...
            which(parent),'',fcnName);
        end
    else
        if isempty(strfind(fp,'Java method'))&&isempty(strfind(fp,'built-in method'))
            str=sprintf('<a href="matlab:matlab.desktop.editor.openDocument(''%s'');">%s</a>',fp,fcnName);
        else
            str=fcnName;
        end
    end

end


function ppTree(fid,fcnName,parent)


    cstr=sprintf(['<span name="collapsible" id="collapsible" style="font-family: monospace" onclick="hdlTableShrink(this, ''%s'')"',...
    'onmouseover="this.style.cursor = ''pointer''">[-]</span> <span style="font-family: monospace">',...
    '%s </span> <span name="%s" id="%s">'],fcnName,fcnOpenLink(fcnName,parent),fcnName,fcnName);

    fprintf(fid,'%s',cstr);

end


function pp(fid,varargin)

    fprintf(fid,varargin{:});

end


function res=bold(str)
    res=['<b>',str,'</b>'];
end


function h=heading(str)


    h=str;
end


function tableHeader(fid,caption)

    fprintf(fid,'<table class="table_header">');

    fprintf(fid,['<TR><TH><H3>',heading(caption),'</H3></TH></TR>']);

end


function emitTR(fid,data)
    fprintf(fid,'<TR class="datatable2">');
    for i=1:length(data)
        value=data{i};
        fprintf(fid,'<TD><H4>%s</H4></TD>',value);
    end
    fprintf(fid,'</TR>');
end


function displayFcnUsage(fid,func,supported)

    if supported
        tblHdr=getMsgCatalogString('MLSupportedFcnList');
    else
        tblHdr=getMsgCatalogString('MLUnSupportedFcnList');
    end

    fprintf(fid,'<BR>');
    fprintf(fid,'<BR>');
    tableHeader(fid,tblHdr);

    if isempty(func)
        emitTR(fid,{'NONE'});
    else

        kv=containers.Map;

        for k=1:numel(func)
            tbxCat=func{k}.pCategory;
            fcnName=func{k}.pName;

            if~isKey(kv,tbxCat)
                kv(tbxCat)={};
            end

            l=kv(tbxCat);
            l{end+1}=fcnName;
            kv(tbxCat)=l;
        end

        ks=keys(kv);
        for k=1:length(ks)
            tbxCat=ks{k};
            fcnList=kv(tbxCat);

            str='';
            flen=length(fcnList);
            for j=1:flen
                fcnName=fcnList{j};
                if~supported&&strcmpi(fcnName,'fi')
                    continue;
                end
                str=[str,'  ',fcnName];
                if j~=flen
                    str=[str,'<BR>'];
                end
            end

            emitTR(fid,{bold(tbxCat),str});
        end
    end
    fprintf(fid,'</table class="table_footer">');
    fprintf(fid,'<BR>');
end


function str=getMsgCatalogString(varargin)
    varargin{1}=['hdlcoder:makecheckhdlreport:',varargin{1}];
    str=message(varargin{:}).getString();
end
