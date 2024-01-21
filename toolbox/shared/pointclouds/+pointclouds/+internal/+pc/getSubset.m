function[loc,c,nv,intens,r]=getSubset(location,color,...
    isOrganized,normal,intensity,rangeData,indices,outputSize)

%#codegen

    coder.allowpcode('plain');

    simMode=isempty(coder.target);
    retFullSize=strcmpi(outputSize,'full');

    if~simMode
        if~coder.internal.isConst(size(location))
            if isOrganized&&retFullSize
                coder.varsize('loc',[inf,inf,3],[1,1,0]);
            else
                coder.varsize('loc',[inf,3],[1,0]);
            end
        end

        coder.varsize('c');
        coder.varsize('nv');
        coder.varsize('intens');
        coder.varsize('r');
    end

    if~isempty(location)
        if~isOrganized
            if retFullSize
                loc=nan(size(location),'like',location);
                loc(indices,:)=location(indices,:);
            else
                loc=location(indices,:);
            end
        else
            tempLocation=reshape(location,[],3);
            if retFullSize
                tmp=nan(size(tempLocation),'like',location);
                tmp(indices,:)=tempLocation(indices,:);
                if simMode
                    loc=reshape(tmp,size(location));
                else
                    loc=coder.nullcopy(zeros(size(location),'like',location));
                    loc(:)=tmp(:);
                end
            else
                if~coder.isRowMajor
                    loc=tempLocation(indices,:);
                else
                    if~isa(indices,'logical')
                        validateattributes(indices,{'numeric'},...
                        {'real','nonsparse','vector','integer'});
                        indices_=indices;
                    else
                        sz=size(tempLocation);
                        sz(end)=1;
                        validateattributes(indices,{'logical'},...
                        {'real','nonsparse','size',sz});
                        indices_=find(indices);
                    end
                    loc=tempLocation(indices_,:);
                end
            end
        end
    else
        if isOrganized&&retFullSize
            loc=zeros(0,0,3,'like',location);
        else
            loc=zeros(0,3,'like',location);
        end
    end

    if nargout>1
        if~isempty(color)
            if~isOrganized
                if retFullSize
                    c=zeros(size(color),'like',color);
                    c(indices,:)=color(indices,:);
                else
                    c=color(indices,:);
                end
            else

                if retFullSize
                    tempColor=reshape(color,[],3);
                    tmp=zeros(size(tempColor),'like',tempColor);
                    tmp(indices,:)=tempColor(indices,:);
                    c=reshape(tmp,size(color));
                else
                    c=reshape(color,[],3);
                    c=c(indices,:);
                end
            end
        else
            c=cast([],'like',color);
        end
    end

    if nargout>2
        if~isempty(normal)
            if~isOrganized
                if retFullSize
                    nv=nan(size(normal),'like',normal);
                    nv(indices,:)=normal(indices,:);
                else
                    nv=normal(indices,:);
                end
            else
                if retFullSize
                    tempNormal=reshape(normal,[],3);
                    tmp=nan(size(tempNormal),'like',normal);
                    tmp(indices,:)=tempNormal(indices,:);
                    nv=reshape(tmp,size(normal));
                else
                    nv=reshape(normal,[],3);
                    nv=nv(indices,:);
                end
            end
        else
            nv=cast([],'like',normal);
        end
    end

    if nargout>3
        if~isempty(intensity)
            if~isOrganized
                if retFullSize
                    intens=repmat(cast(nan,class(intensity)),size(intensity));
                    intens(indices)=intensity(indices);
                else
                    intens=intensity(indices,:);
                end
            else
                if retFullSize
                    intens=repmat(cast(nan,class(intensity)),size(intensity));
                    intens(indices)=intensity(indices);
                else
                    tempIntens=intensity(indices);
                    if isrow(tempIntens)
                        intens=tempIntens';
                    else
                        intens=tempIntens;
                    end
                end
            end
        else
            intens=cast([],'like',intensity);
        end
    end

    if nargout>4
        if~isempty(rangeData)
            if~isOrganized
                if retFullSize
                    r=nan(size(rangeData),'like',rangeData);
                    r(indices,:)=rangeData(indices,:);
                else
                    r=rangeData(indices,:);
                end
            else
                if retFullSize
                    tempRangeData=reshape(rangeData,[],3);
                    tmp=nan(size(tempRangeData),'like',rangeData);
                    tmp(indices,:)=tempRangeData(indices,:);
                    r=reshape(tmp,size(rangeData));
                else
                    r=reshape(rangeData,[],3);
                    r=r(indices,:);
                end
            end
        else
            r=cast([],'like',rangeData);
        end
    end

end
