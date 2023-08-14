function[elementVal,name,retIdx]=get(this,searchArg,varargin)













    narginchk(1,inf);
    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
        searchArg=convertStringsToChars(searchArg);
    end

    elementVal={};
    name='';
    retIdx=[];

    if nargin==1
        len=this.numElements();
        for idx=1:len
            [~,locName,~]=this.getElement(idx);
            if~isempty(locName)
                elementVal{end+1}=locName;%#ok
            end
        end
        elementVal=unique(elementVal');
    else
        [elementVal,name,retIdx]=...
        this.getElement(searchArg,varargin{:});
    end
end
