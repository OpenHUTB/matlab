function numVectors=genVectors(this)








    sc=this.ModelConnection;

    try
        this.testBenchComponents();


        sc.initModelForTBGen(this.OrigSllogName,this.OutLogNamePrefix,this.InLogNamePrefix);
        sc.simulateModel();

        this.OrigSllog=[];
        this.OrigSllog.(this.OrigSllogName)=eval(this.OrigSllogName);
        numVectors=this.sllog2tlmvec();




    catch ME
        sc.restoreModelFromTBGen();
        sc.termModel();
        rethrow(ME);
    end

    sc.restoreModelFromTBGen();
    sc.termModel();

end
