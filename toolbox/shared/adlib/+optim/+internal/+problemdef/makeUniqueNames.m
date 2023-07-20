function[uniqueNames,uniqueIdx,outIdx]=makeUniqueNames(names)















    uniqueNames=names;

    if~isempty(names)

        [sortNames,sortIdx]=sort(uniqueNames(:));


        unmatchedIdx=~strcmp(sortNames(1:end-1),sortNames(2:end));

        unmatchedIdx=[true;unmatchedIdx(:)];


        uniqueNames=sortNames(unmatchedIdx).';

        if nargout>1


            uniqueIdx=sortIdx(unmatchedIdx);

            if nargout>2
                [~,revIdx]=sort(sortIdx);
                outIdx=cumsum(unmatchedIdx);
                outIdx=outIdx(revIdx);
            end
        end
    else
        uniqueIdx=true(size(names));
        outIdx=ones(size(names));
    end