function validateCell=makehdlturnkey(this)






    oldDriver=hdlcurrentdriver;
    oldMode=hdlcodegenmode;

    try

        hdlcurrentdriver(this);
        hdlcodegenmode('slcoder');


        if~isempty(this.DownstreamIntegrationDriver)
            hD=this.DownstreamIntegrationDriver;
        else
            error(message('hdlcoder:engine:NoDIDriver'));
        end
        hT=hD.hTurnkey;


        validateCell=hT.validateWrapperCodeGen;


        if hT.hD.isQuartus
            if~strcmpi(hT.hCHandle.getParameter('vhdl_library_name'),'work')
                error(message('hdlcoder:engine:NonDefaultLibName',hT.hCHandle.getParameter('vhdl_library_name')));
            end
        end


        makehdlArgs=hdlturnkey.table.getMakehdlArgs(hD);


        hPIRCreation=hT.hTable.hPIRCreation;
        needRunEntireMakehdl=true;
        if~isempty(hPIRCreation)
            needRunEntireMakehdl=hPIRCreation.checkNeedRunEntireMakehdl;
        end






        this.SkipFrontEnd=false;

        if needRunEntireMakehdl

            this.makehdl(makehdlArgs);
        else












            this.runPIRTransformAndCodegen(hPIRCreation.GeneratedPIR,hPIRCreation.CodegenParams,makehdlArgs);
            hPIRCreation.reset;
        end


        hT.makehdlturnkey;

    catch ME

        hdlcurrentdriver(oldDriver);
        hdlcodegenmode(oldMode);

        rethrow(ME);
    end


    hdlcurrentdriver(oldDriver);
    hdlcodegenmode(oldMode);

end




