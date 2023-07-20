function newStr=uniqueify_str_with_number(str,ignoreThisIdx,varargin)





    if isempty(ignoreThisIdx)
        ignoreThisIdx=0;
    end

    allStrings=varargin;
    if ignoreThisIdx>0
        allStrings(ignoreThisIdx)=[];
    end

    if~any(strcmp(str,allStrings))
        newStr=str;
        return;
    end

    thisRoot=find_ending_numbers(str);
    [otherRoots,otherNumbers]=find_ending_numbers(allStrings);

    rootMatch=strcmp(thisRoot,otherRoots);
    existNumbers=[otherNumbers{rootMatch}];


    if isempty(existNumbers)||isempty(find(existNumbers==1))%#ok<EFIND>
        newNumber=1;
    else



        [~,ia]=unique(existNumbers);


        sortedNumbers=sort(existNumbers(ia));



        difference=diff(sortedNumbers);


        if any(difference~=1)


            if length(difference)~=1
                idx=find(difference~=1,1,'first');
                newNumber=sortedNumbers(idx)+1;
            else
                newNumber=sortedNumbers(1)+1;
            end

        else



            newNumber=sortedNumbers(end)+1;

        end



        if any(ismember(sortedNumbers,newNumber))

            newNumber=newNumber+1;
        end

    end



    newStr=[thisRoot{1},num2str(newNumber)];
end

function[roots,numbers]=find_ending_numbers(str)

    if~iscell(str)
        str={str};
    end

    digitInd=regexp(str,'\d+$');

    cnt=length(str);
    roots=cell(cnt,1);
    numbers=cell(cnt,1);

    for idx=1:cnt
        if isempty(digitInd{idx})
            roots{idx}=str{idx};
        else
            roots{idx}=str{idx}(1:(digitInd{idx}-1));
            numbers{idx}=str2double(str{idx}(digitInd{idx}:end));
        end
    end
end
