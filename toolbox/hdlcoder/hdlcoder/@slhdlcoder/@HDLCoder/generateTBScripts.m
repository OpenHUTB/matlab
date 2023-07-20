function generateTBScripts(this)







    if this.getParameter('gen_eda_scripts')
        this.setParameter('hdlcompilescript',true);
        this.setParameter('hdlcompiletb',true);
        this.setParameter('hdlsimscript',true);
        this.setParameter('hdlsimprojectscript',false);
        this.setParameter('hdlsynthscript',false);
        this.setParameter('hdlmapfile',false);
    else

        this.setParameter('hdlcompilescript',false);
        this.setParameter('hdlcompiletb',false);
        this.setParameter('hdlsimscript',false);
        this.setParameter('hdlsimprojectscript',false);
        this.setParameter('hdlsynthscript',false);
        this.setParameter('hdlmapfile',false);
    end


    generateTB=this.getParameter('generatehdltestbench');
    if generateTB
        this.makehdlscripts(pir(this.AllModels(end).modelName),true);
    end

