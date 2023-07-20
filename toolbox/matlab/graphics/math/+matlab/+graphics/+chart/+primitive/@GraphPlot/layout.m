function layout(hObj,varargin)




















































    if nargin<=1
        layoutauto(hObj);
    else
        method=validatestring(varargin{1},...
        {'auto','circle','force','layered','subspace','force3','subspace3'});
        switch method
        case 'auto'
            if numel(varargin)>1
                error(message('MATLAB:graphfun:plot:NoOptionalInput','auto'));
            end
            layoutauto(hObj);
        case 'circle'
            layoutcircle(hObj,varargin{2:end});
        case 'force'
            layoutforce(hObj,varargin{2:end});
        case 'layered'
            layoutlayered(hObj,varargin{2:end});
        case 'subspace'
            layoutsubspace(hObj,varargin{2:end});
        case 'force3'
            layoutforce3(hObj,varargin{2:end});
        otherwise
            layoutsubspace3(hObj,varargin{2:end});
        end
    end

    function layoutauto(hObj)

        if numnodes(hObj.BasicGraph_)<=hObj.LargeGraphThreshold_
            if hObj.IsDirected_
                hascycles=~dfsTopologicalSort(hObj.BasicGraph_);
            else
                hascycles=hasCycles(hObj.BasicGraph_);
            end
            if hascycles
                layoutforce(hObj);
            else
                layoutlayered(hObj);
            end
        else
            layoutsubspace(hObj);
        end
