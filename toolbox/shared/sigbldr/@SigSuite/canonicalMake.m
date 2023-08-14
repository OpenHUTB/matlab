





function[time,data,sigNames,grpNames]=canonicalMake(time,data,sigNames,grpNames)
    if~isempty(sigNames)&&~iscell(sigNames)
        sigNames={sigNames};
    end






    if~isempty(grpNames)&&~iscell(grpNames)
        grpNames={grpNames};
    end






    if~iscell(time)
        time={time};
    end

    if~iscell(data)
        data={data};
    end


    nDims=find(cellfun('ndims',data)>2);

    if~isempty(nDims)
        for k=1:length(nDims)

            data{nDims(k)}=squeeze(data{nDims(k)});

            if~isvector(data{nDims(k)})
                DAStudio.error('Sigbldr:sigsuite:DataMetaDataCustomInvalidData');
            end
        end
    end


    [r,c]=find(cellfun('size',data,1)>1);


    if~isempty(r)
        for k=1:length(r)
            data{r(k),c(k)}=data{r(k),c(k)}';
        end
    end


    nDims=find(cellfun('ndims',time)>2);

    if~isempty(nDims)
        for k=1:length(nDims)

            time{nDims(k)}=squeeze(time{nDims(k)});

            if~isvector(time{nDims(k)})
                DAStudio.error('Sigbldr:sigsuite:DataMetaDataCustomInvalidTime');
            end
        end
    end


    [r,c]=find(cellfun('size',time,1)>1);


    if~isempty(r)
        for k=1:length(r)
            time{r(k),c(k)}=time{r(k),c(k)}';
        end
    end

    if isequal(size(time),size(data))
        return;
    end


    [rowCnt,colCnt]=size(data);

    if length(time)==1
        timeElm=time;
        time=cell(rowCnt,colCnt);
        for i=1:rowCnt
            for j=1:colCnt
                time(i,j)=timeElm;
            end
        end
    else
        timeOrig=time;
        time=cell(rowCnt,colCnt);
        for i=1:rowCnt
            for j=1:colCnt
                time(i,j)=timeOrig(j);
            end
        end
    end
end
