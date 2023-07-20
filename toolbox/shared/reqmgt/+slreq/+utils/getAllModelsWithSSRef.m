function out=getAllModelsWithSSRef(ssrefname,allmodels)





    out={};
    if ishandle(ssrefname)
        ssrefname=get_param(ssrefname,'Name');
    end

    if nargin<2


        allmodels=getfullname(Simulink.allBlockDiagrams('model'));

        if~iscell(allmodels)
            allmodels={allmodels};
        end
    end

    for mindex=1:length(allmodels)
        cModel=allmodels{mindex};
        if~isempty(rmisl.getSSRefInstanceFromSourceItemInModel(ssrefname,cModel))
            out{end+1}=getfullname(cModel);%#ok<AGROW>
        end
    end


    out=out';
end
