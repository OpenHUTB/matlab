


function reg=mergeCodeLocation(reg,m2c,fileMap)
    if~isempty(reg.location)
        n1=length(reg.location);
    else
        n1=0;
    end
    n2=length(m2c.tokens);
    reg.location(n1+n2).scope='';



    tks=m2c.tokens;
    reg.location(n1+1).column=zeros(1,n2,'int32');
    reg.location(n1+1).file=fileMap{tks(1).fileIdx+1};
    reg.location(n1+1).line=tks(1).line;
    reg.location(n1+1).column(1)=tks(1).beginCol;
    colIdx=1;
    j=1;
    for i=2:n2
        if(tks(i-1).line~=tks(i).line)||tks(i-1).fileIdx~=tks(i).fileIdx
            reg.location(n1+j).column(colIdx+1:end)=[];
            j=j+1;
            reg.location(n1+j).file=fileMap{tks(i).fileIdx+1};
            reg.location(n1+j).line=tks(i).line;
            colIdx=0;
        end
        colIdx=colIdx+1;
        reg.location(n1+j).column(colIdx)=tks(i).beginCol;
    end

    reg.location(n1+j+1:end)=[];



    n=length(reg.location);
    if(n>1)
        fileline=cell(1,n);
        for i=1:n
            fileline{i}=[reg.location(i).file,sprintf('%09d',reg.location(i).line)];
        end
        [~,idx]=unique(fileline);
        reg.location=reg.location(idx);
    end


