function varargout=finderSearchData(varargin)



mlock

    persistent searchHistoryList;
    if isempty(searchHistoryList)
        searchHistoryList={};
    end

    if nargin<1
        error(message('Simulink:tools:Finder_NotEnoughInputs'));
    end

    if nargin==1&&iscell(varargin{1})
        varargin=varargin{1};
    end


    Action=varargin{1};

    if strcmpi(Action,'GetSearchHistory')

        varargout{1}=searchHistoryList;

    elseif strcmpi(Action,'AddNewData')&&length(varargin)>1

        newData=varargin{2};



        if~isempty(newData)&&ischar(newData)
            searchHistoryList=[searchHistoryList;newData];

            addNewDataChannel='/finder/searchHistory/addNewItem';
            message.publish(addNewDataChannel,newData);
        end

    elseif strcmpi(Action,'SetSearchHistory')&&length(varargin)>1

        newHistory=varargin{2};
        searchHistoryList=newHistory;

    end
end