function[objs,otherItems]=getObjWithReqs(modelH,varargin)





    [slHs,sfHs,otherItems]=rmisl.getHandlesWithRequirements(modelH,varargin{:});





    if~isempty(slHs)&&~isempty(sfHs)&&rmidata.isExternal(modelH)
        removeIdx=false(size(sfHs));
        sfRoot=Stateflow.Root;
        redirectedTypes={'Stateflow.Chart','Stateflow.SLFunction',...
        'Stateflow.TruthTableChart','Stateflow.EMChart'};
        for i=1:length(sfHs)
            sfObj=sfRoot.idToHandle(sfHs(i));
            if any(strcmp(class(sfObj),redirectedTypes))
                removeIdx(i)=true;
            end
        end
        if any(removeIdx)
            sfHs(removeIdx)=[];
        end
    end


    objs=[slHs(:);sfHs(:)];
end

