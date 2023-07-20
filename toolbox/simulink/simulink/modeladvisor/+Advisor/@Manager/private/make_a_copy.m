



function varargout=make_a_copy(slCustomizationDataStructure,varargin)
    for i=1:length(varargin)
        currentValue=slCustomizationDataStructure.(varargin{i});
        if iscell(currentValue)
            tmpVar=cell(1,length(currentValue));
            for j=1:length(currentValue)
                tmpVar{j}=copy(currentValue{j});
            end
            varargout{i}=tmpVar;%#ok<AGROW>
        elseif isstruct(currentValue)
            varargout{i}=currentValue;%#ok<AGROW>
        else
            varargout{i}=copy(currentValue);%#ok<AGROW>
        end
    end
end