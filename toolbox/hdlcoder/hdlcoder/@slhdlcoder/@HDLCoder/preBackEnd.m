function preBackEnd(this,p)




    p.startTimer('Emit HDL Code','Stage ehc');
    CGDir=this.hdlMakeCodegendir;
    p.endEmission(CGDir);
    p.stopTimer;

    hdldisp(message('hdlcoder:hdldisp:EndCodegen',p.ModelName));
end

