function cleanupBeforeMakehdl(this)



    this.TraceabilityDriver=[];
    this.CodeGenSuccessful=false;



    outfile=this.getParameter('generatedmodelname');
    if isempty(outfile)
        outfile=this.ModelName;
    end
    outfileprefix=this.getParameter('generatedmodelnameprefix');




    if~isempty(outfileprefix)
        genMdlName=getGeneratedModelName(outfileprefix,outfile);


        if this.getParameter('generatevalidationmodel')
            gc=cosimtb.gencoverifymdl('CoverifyBlockAndDut',this,[]);



            outfile=[genMdlName,'_',gc.getCurrentLinkOpt];
            getGeneratedModelName('',outfile);
        end
    end
end

