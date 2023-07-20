function[bool]=isDataArray(aVar)













    if nargin>0
        aVar=convertStringsToChars(aVar);
    end


    N=size(aVar);


    bool=false;
    if~isempty(aVar)






        if isreal(aVar)&&ismatrix(aVar)&&strcmpi('double',class(aVar))...
            &&all(diff(aVar(:,1))>=0)&&N(2)>1
            bool=true;



            if(N(2)-1)>SlIOFormatUtil.SDI_REPO_CHANNEL_UPPER_LIMIT
                bool=false;
            end
        end
    end

end
