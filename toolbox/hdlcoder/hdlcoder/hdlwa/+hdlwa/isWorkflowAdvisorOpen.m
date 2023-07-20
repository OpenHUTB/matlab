function result=isWorkflowAdvisorOpen()




    result=false;



    mdlAdv=hdlwa.getHdladvObj();


    if~isempty(mdlAdv)
        mdlExplorer=mdlAdv.MAExplorer;
        if(~isempty(mdlExplorer))
            result=mdlExplorer.isVisible;
        end
    end


end