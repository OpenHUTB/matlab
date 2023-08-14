function nodeObj=useGUI(maObj,varargin)



















    if nargin>1
        searchCondition=varargin{1};
    else
        error('Incorrect usage.');
    end
    if nargin>2
        action=varargin{2};
    else
        action='focus';
    end

    if ischar(searchCondition)
        searchCondition={searchCondition,'-type','CheckID'};
    end
    nodeObj=maObj.getTaskObj(searchCondition{:});
    if length(nodeObj)>1
        nodeObj=nodeObj{1};
    end

    window=maObj.AdvisorWindow;
    switch lower(action)
    case 'focus'
        window.Controller.focusNode(nodeObj.ID);
    case 'select'
        window.Controller.selectNode(nodeObj.ID);
    case 'deselect'
        window.Controller.deselectNode(nodeObj.ID);
    case 'fix'
        window.Controller.selectNode(nodeObj.ID);
        nodeObj.runAction();
    case 'run'
        nodeObj.runTaskAdvisor;
    otherwise
    end

end