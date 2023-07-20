function theCells=makeNodeTable(d,v,hLimit,makeTM,varargin)












    if nargin<4
        makeTM=true;
    end

    if nargin<3||hLimit==0
        hLimit=inf;
    end

    sz=size(v);
    szLen=length(sz);

    numHeadRows=0;
    if szLen>3
        error(message('rptgen:rx_document:cannotRepresentAs2DTable'));
    elseif iscell(v)
        checkLimit(hLimit,sz);
        [theCells,nCols]=locMakeTextNodeCells(d,v,varargin{:});
    elseif isnumeric(v)||isa(v,'logical')
        checkLimit(hLimit,sz);
        [theCells,nCols]=locMakeTextNodeCells(d,num2cell(v),varargin{:});
    elseif isstruct(v)&&min(sz)==1
        [theCells,nCols,numHeadRows]=locCellifyStruct(d,v,hLimit,varargin{:});
    elseif ischar(v)
        v=locCellstr(v);
        checkLimit(hLimit,size(v));
        [theCells,nCols]=locMakeTextNodeCells(d,v,varargin{:});
    elseif isa(v,'org.w3c.dom.Node')
        theCells=v;
        nCols=1;
    elseif isa(v,'handle')
        [theCells,nCols,numHeadRows]=locCellifyStruct(d,get(v),hLimit,varargin{:});
    else
        try

            [theCells,nCols,numHeadRows]=locCellifyStruct(d,struct(v),hLimit,varargin{:});
        catch
            error(message('rptgen:rx_document:cannotConvertToTable'));
        end
    end





    if~isempty(theCells)
        if rptgen.use_java
            cellVec=theCells(1);
            for i=2:size(theCells,1)
                cellVec=[cellVec,theCells(i)];%#ok<*AGROW>
            end
        else
            cellVec=theCells(1,:);
            for i=2:size(theCells,1)
                cellVec=[cellVec,theCells(i,:)];
            end
        end
    else
        cellVec=theCells;
    end

    if makeTM
        if rptgen.use_java
            tm=com.mathworks.toolbox.rptgencore.docbook.TableMaker(java(d));
        else
            tm=mlreportgen.re.internal.db.TableMaker(d.Document);
        end
        tm.setNumCols(nCols);

        tm.setNumHeadRows(numHeadRows);
        tm.setContent(cellVec);



        if strcmpi(get(get(rptgen.appdata_rg,'RootComponent'),'Format'),'html')
            tm.forceHtmlTable(true);
        end

        theCells=tm;
    else
        theCells=cellVec;
    end


    function checkLimit(hLimit,sz)

        if hLimit~=inf&&sum(sz.^2)>hLimit^2
            error(message('rptgen:rx_document:tableIsTooLarge'));
        end


        function[nt,nCols]=locMakeTextNodeCells(d,cellArray,varargin)

            if isempty(cellArray)
                nt=[];
                nCols=0;
                return;
            end

            if rptgen.use_java
                sz=size(cellArray);


                nt=javaArray('org.w3c.dom.Node',sz);
                for i=sz(1):-1:1
                    for j=sz(2):-1:1
                        nt(i,j)=makeNode(d,cellArray{i,j},varargin{:});
                    end
                end
            else
                sz=size(cellArray);
                currRow=[];
                nt=[];
                for r=1:sz(1)
                    for c=1:sz(2)
                        nd=makeNode(d,cellArray{r,c},varargin{:});
                        currRow=[currRow,nd];
                    end
                    nt=[nt;currRow];
                    currRow=[];
                end
            end
            nCols=sz(2);


            function c=locCellstr(s)


                c=cellstr(s);
                i=1;
                while i<=length(c)
                    crLoc=strfind(c{i},newline);
                    if~isempty(crLoc)

                        if crLoc(1)~=1
                            crLoc=[0,crLoc];
                        end
                        if crLoc(end)~=length(c{i})
                            crLoc(end+1)=length(c{i})+1;
                        end

                        for j=length(crLoc)-1:-1:1
                            tempCell{j,1}=c{i}(crLoc(j)+1:crLoc(j+1)-1);
                        end
                        c=[c(1:i-1);tempCell;c(i+1:end)];
                        i=i+length(tempCell);
                    else
                        i=i+1;
                    end
                end



                nonBlankCells=find(~cellfun('isempty',c));
                c=c(min(nonBlankCells):max(nonBlankCells));


                function[tCells,nCols,numHeadRows]=locCellifyStruct(d,v,hLimit,varargin)


                    numHeadRows=0;

                    nStruct=length(v);

                    fNames=fieldnames(v);
                    nFields=length(fNames);

                    checkLimit(hLimit,[nFields+1-(nStruct<2),nStruct+1]);


                    if nStruct==0
                        tCells=fNames(:);
                    else
                        if nStruct<2
                            headRow=cell(0,2);
                        else
                            numHeadRows=1;
                            headRow=[{getString(message('rptgen:rx_document:fieldLabel'))},num2cell(1:1:nStruct)];


                        end

                        for i=nStruct:-1:1
                            tCells(:,i)=struct2cell(v(i));
                        end
                        tCells=[headRow;[fNames(:),tCells]];
                    end

                    [tCells,nCols]=locMakeTextNodeCells(d,tCells,varargin{:});
