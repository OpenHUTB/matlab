function run(this,root,recurse)










    if nargin<3
        recurse=true;
    end

    if nargin<2
        root=[];
    end


    if~isempty(root)
        root=this.MdlHierInfo.MdlObjectToComponentMap(root);
    else
        root=this.MdlHierInfo.CompGraph;
    end


    cont=this.setInitialAssessmentOptions();
    if cont

        this.Visited=containers.Map('KeyType','double','ValueType','any');
        if recurse


            this.MdlHierInfo.BatchExtract(root,this.getAdvisorUI);

            this.analyzeCompGraphScheduler(@analyzeAll,root,false);


            job.run=@()this.updateEstimatedAnalysisTimePerComponent;
            this.JobQueue.enqueue(job,false);
        else
            job.run=@()this.analyzeComp(root);
            this.JobQueue.enqueue(job,false);
        end


    end

    if slavteng('feature','TGALoadSavePrevResults')
        job.run=@()this.Store.save();
        this.JobQueue.enqueue(job,false);
    end




    job.run=@()this.pause;
    this.JobQueue.enqueue(job,false);


    function filter=analyzeAll(~)

        filter=false;
    end

end
