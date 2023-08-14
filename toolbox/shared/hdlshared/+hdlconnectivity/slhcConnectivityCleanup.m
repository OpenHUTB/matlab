function slhcConnectivityCleanup(mpcg,modelname,pass)











    if hdlgetparameter('multicyclepathinfo')
        hCD=hdlconnectivity.getConnectivityDirector;
        if~isempty(hCD),
            hB=hCD.builder;
        else
            hB=[];
        end

        hD=hdlcurrentdriver;

        if~isempty(mpcg)&&pass,

            hD.MCPinfo.mcp=mpcg.mcp;
            hD.MCPinfo.codegendir=hdlGetCodegendir;
            hD.MCPinfo.topEntity=hdlentitytop;
            hD.MCPinfo.ucf_subscript='_constraints.ucf';
            hD.MCPinfo.genby=hdlgetparameter('tool_file_comment');
            hD.MCPinfo.modelname=modelname;
            hD.MCPinfo.delim=mpcg.delim;
            hD.MCPinfo.langDeref=mpcg.langDeref;
            hD.MCPinfo.partSelDeref=mpcg.partSelDeref;
            hD.MCPinfo.arrayDeref=mpcg.arrayDeref;

            mpcg.writeTXT(modelname);
        else
            hD.MCPinfo=[];
        end




        hdlconnectivity.getConnectivityDirector([]);

        hdlconnectivity.genConnectivity(false);

        if~isempty(mpcg),delete(mpcg);end
        if~isempty(hCD),
            tU=hCD.timingUtil;
            pU=hCD.pathUtil;
            delete(hCD);
            if~isempty(tU),delete(tU);end
            if~isempty(pU),delete(pU);end
        end
        if~isempty(hB),delete(hB);end
    end


