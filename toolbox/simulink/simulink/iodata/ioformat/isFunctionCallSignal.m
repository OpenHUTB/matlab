function[bool]=isFunctionCallSignal(aVar)






















    if nargin>0
        aVar=convertStringsToChars(aVar);
    end

    bool=false;


    if isnumeric(aVar)&&...
        strcmpi('double',class(aVar))&&...
        isreal(aVar)


        dims=size(aVar);


        if length(dims)==2&&...
            dims(2)==1&&...
            all(diff(aVar(:,1))>=0)


            bool=true;
        end

    end

end
