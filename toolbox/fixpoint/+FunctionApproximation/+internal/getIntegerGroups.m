function[valueGroups,indicesGroups]=getIntegerGroups(integerVector)
























    validateattributes(integerVector,{'numeric'},{'vector','integer','increasing'});
    N=numel(integerVector);
    if N<3
        indicesGroups={1:N};
    else
        dx=integerVector(2:end)-integerVector(1:end-1);
        k=1;
        start=1;
        while start<=N
            if start==N
                indicesGroups{k}=N;%#ok<AGROW>
            else


                dxLocal=dx(start:end);
                cutOff=find(dxLocal~=dxLocal(1),1,'first');
                if isempty(cutOff)
                    cutOff=length(dxLocal)+1;
                end
                if cutOff==2

                    indicesGroups{k}=start;%#ok<AGROW>
                else

                    stop=start+cutOff-1;
                    indicesGroups{k}=start:stop;%#ok<AGROW>
                end
            end
            start=indicesGroups{k}(end)+1;
            k=k+1;
        end
        indicesGroups=indicesGroups(cellfun(@(x)~isempty(x),indicesGroups));
    end
    valueGroups=cell(size(indicesGroups));
    for i=1:numel(indicesGroups)
        valueGroups{i}=integerVector(indicesGroups{i});
    end
end
