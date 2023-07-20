function[genCode,genModel,genTB]=getCodeModelTBParams(this)






    genCode=this.getParameter('generatehdlcode');
    genModel=this.getParameter('generatemodel');

    genTB=this.getParameter('generatetb');

    if(~isempty(hdlfeature('DNNFPGACodegen'))&&strcmpi(hdlfeature('DNNFPGACodegen'),'on'))
        genModel=false;
        genTB=false;
        genCode=true;
    end

    if strcmpi(this.getParameter('codegenerationoutput'),'DisplayGeneratedModelOnly')
        genModel=true;
        genCode=false;
    end

    if genTB
        genModel=true;
        genCode=true;
    end

