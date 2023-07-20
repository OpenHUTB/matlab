




function newName=getNewLabel(currentNames,prefix)


    match=currentNames.contains(prefix+wildcardPattern+digitsPattern+lineBoundary);
    currentNames(~match)=[];
    tokens=currentNames.extract(digitsPattern+lineBoundary);


    numeric=sort(tokens.double);


    if isempty(numeric)||numeric(1)~=1
        suffix="1";
    else

        numeric=[numeric,numeric(end)+2];
        suffix=string(find(diff(numeric)>=2,1)+1);
    end

    newName=prefix+suffix;

end

