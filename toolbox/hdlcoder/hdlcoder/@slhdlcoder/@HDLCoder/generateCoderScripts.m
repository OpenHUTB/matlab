function generateCoderScripts(this,p)




    this.setParameter('hdlcompiletb',false);
    this.setParameter('hdlsimscript',false);
    this.setParameter('hdlsimprojectscript',false);


    this.setParameter('hdlmapfile',true);

    if this.getParameter('gen_eda_scripts')
        this.setParameter('hdlcompilescript',true);
        if~strcmpi(this.getParameter('hdlsynthtool'),'none')
            this.setParameter('hdlsynthscript',true);
        else
            this.setParameter('hdlsynthscript',false);
        end
    else

        this.setParameter('hdlcompilescript',false);
        this.setParameter('hdlsynthscript',false);
    end

    this.makehdlscripts(p);
end
