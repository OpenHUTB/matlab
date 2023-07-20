function updateNodeParameter(parameterUpdater,node,paramName,paramValue,merge,add,partner,targetSide,parameterNameToDiffMap)



















    if nargin<9
        parameterNameToDiffMap=[];
        if nargin<8
            targetSide=[];
            if nargin<7
                partner=[];
                if nargin<6
                    add=false;
                    if nargin<5
                        merge=false;
                    end
                end
            end
        end
    end

    parameterUpdater.updateParameter(node,paramName,paramValue,merge,add,partner,targetSide,parameterNameToDiffMap);

end
