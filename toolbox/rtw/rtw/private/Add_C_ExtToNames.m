







function namesWithExt=Add_C_ExtToNames(nameList,varargin)
    if nargin>1
        customExt=varargin{1};
    else
        customExt='.c';
    end

    namesWithExt=nameList;
    for i=1:length(nameList)
        name=nameList{i};
        [~,~,nExt]=fileparts(name);
        if isempty(nExt)
            namesWithExt{i}=[name,customExt];
        end
    end



