function formatstr=fitintable(this,headHorz,headVert,data,align)







    numCols=length(headHorz);
    numRows=size(data,1);
    if~iscell(data)
        data=num2strcell(data);
    end

    table=cell(numRows+1,numCols);
    table(1,:)=headHorz;
    for n=1:numRows
        if isempty(headVert)
            table(n+1,:)={data{n,:}};
        else
            table(n+1,:)={headVert{n},data{n,:}};
        end
    end


    width=ones(numCols,1);
    for n=1:size(table,2)
        width(n)=maxlength(table(:,n));
    end


    width=width+2;
    indent=3;
    formatstr={};
    if length(align)==1
        for n=2:numCols
            align{n}=align{1};
        end
    end


    if~isempty(headVert)
        str=[ones(1,indent)*' ',fitinColumn(table{1,1},width(1),'right'),'|'];
    else
        str=[ones(1,indent)*' ','|',fitinColumn(table{1,1},width(1),align{1}),'|'];
    end

    for col=2:numCols
        str=[str,fitinColumn(table{1,col},width(col),'center'),'|'];
    end

    formatstr=[formatstr;str;char([ones(1,indent)*' ',ones(1,length(str)-indent)*'-'])];

    for row=2:numRows+1
        if~isempty(headVert)
            str=[ones(1,indent)*' ',fitinColumn(table{row,1},width(1),'right'),'|'];
        else
            str=[ones(1,indent)*' ','|',fitinColumn(table{row,1},width(1),align{1}),'|'];
        end

        for col=2:numCols
            str=[str,fitinColumn(table{row,col},width(col),align{col}),'|'];
        end
        formatstr=[formatstr;str];
        if row==1
            formatstr=[formatstr;ones(1,indent)*' ',ones(1,length(str)-indent)*'-'];
        end
    end


    function len=maxlength(cellvals)

        len=0;
        for n=1:length(cellvals)
            len=max(len,length(cellvals{n}));
        end



        function formatstr=fitinColumn(str,width,align)

            blanks=width-length(str);
            switch align
            case 'center'
                ltblanks=ceil(blanks/2);
                rtblanks=blanks-ltblanks;

                formatstr=[ones(1,ltblanks)*' ',str,ones(1,rtblanks)*' '];

            case 'left'
                formatstr=[str,ones(1,blanks)*' '];
            case 'right'
                formatstr=[ones(1,blanks)*' ',str];
            end


            function cellstr=num2strcell(nummatrix)

                cellstr=cell(size(nummatrix));
                for r=1:size(nummatrix,1)
                    for c=1:size(nummatrix,2)
                        cellstr(r,c)={num2str(nummatrix(r,c))};
                    end
                end

