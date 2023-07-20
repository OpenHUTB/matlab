function hObj=NeElementHelperObj(varargin)



    narginchk(1,1);
    pm_assert(l_IsElement(varargin{1}));

    hObj=NetworkEngine.NeElementHelperObj();
    hObj.hElementObj=varargin{1};

    hObj.parameterVec=[];
    hObj.variableVec=[];
    hObj.terminalVec=[];
    hObj.inputVec=[];
    hObj.outputVec=[];
    hObj.portVec=[];

    hObj.descriptorStr=hObj.hElementObj.descriptor;

    itemLst=hObj.hElementObj.items();
    nItems=numel(itemLst);
    for idx=1:nItems
        itemName=itemLst{idx,1};
        itemObj=eval(['hObj.hElementObj.',itemName]);

        clsName=class(itemObj);
        switch(clsName)
        case 'NetworkEngine.Terminal'
            hObj.terminalVec=[hObj.terminalVec;itemObj];
            hObj.portVec=[hObj.portVec;itemObj];
        case 'NetworkEngine.Parameter'
            hObj.parameterVec=[hObj.parameterVec;itemObj];
        case{'NetworkEngine.LocalVariable','NetworkEngine.ComponentVariable'}
            hObj.variableVec=[hObj.variableVec;itemObj];
        case 'NetworkEngine.Input'
            hObj.inputVec=[hObj.inputVec;itemObj];
            hObj.portVec=[hObj.portVec;itemObj];
        case 'NetworkEngine.Output'
            hObj.outputVec=[hObj.outputVec;itemObj];
            hObj.portVec=[hObj.portVec;itemObj];
        otherwise
            disp(sprintf('Unhandled class type: %s.',clsName));
        end
    end
end

function isElem=l_IsElement(hObj)
    isElem=strcmp(class(hObj),'NetworkEngine.ElementSchema');
end
