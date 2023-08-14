function debugDumpXML(this,p,suffix)


    if this.getParameter('debug')>1
        outputDir=this.hdlMakeCodegendir;
        dumpBaseName=hdllegalname(p.getTopNetwork.Name);
        fullPath=fullfile(outputDir,[dumpBaseName,suffix]);
        hdldisp(sprintf('Dumping DOT into %s',hdlgetfilelink(fullPath)));
        p.dumpXML(fullPath);
    end
end
