function blockDiagram=getBlockDiagram(blockH)




    blockDiagram=[];


    mdlName=get(bdroot(blockH),'Name');


    if~isempty(mdlName)&&bdIsLoaded(mdlName)


        aDiagram=get_param(mdlName,'Object');

        blockDiagram=aDiagram;

    end

end

