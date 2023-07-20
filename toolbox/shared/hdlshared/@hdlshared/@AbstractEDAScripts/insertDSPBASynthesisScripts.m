
function insertDSPBASynthesisScripts(this,fid)



    str=targetcodegen.alteradspbadriver.getDSPBASynthesisScripts(this.HdlSynthCmd);
    str=strrep(str,'\','\\');
    fprintf(fid,str);
end


