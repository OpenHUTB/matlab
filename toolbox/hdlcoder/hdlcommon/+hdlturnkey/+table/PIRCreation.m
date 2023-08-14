





classdef PIRCreation<handle













    properties

hTable


GeneratedPIR


CodegenParams


MakehdlArgs
    end

    methods

        function obj=PIRCreation(hTable)
            obj.hTable=hTable;
            obj.reset;
        end


        function runPirFrontEnd(obj)


            hT=obj.hTable.hTurnkey;
            hDI=hT.hD;


            dutName=hDI.hCodeGen.getDutName;








            if~isempty(hDI.hWCProjectFolder)
                hDI.setProjectFolder(hDI.hWCProjectFolder);
            end




            hdlcoderObj=hdlcoderargs(dutName);
            hdlcoderObj.CalledFromMakehdl=false;
            hdlcoderObj.setParameter('verbose',0);








            hdlcoderObj.SkipFrontEnd=~hDI.cliDisplay;


            hdlcoderObj.OrigModelName=hdlcoderObj.ModelName;
            hdlcoderObj.OrigStartNodeName=hdlcoderObj.getStartNodeName;
            hdlcoderObj.nonTopDut=hdlcoderObj.prelimNonTopDUTChecks;
            hdlcoderObj.checkStateflowOnTop;
            hdlcurrentdriver(hdlcoderObj);

            hdlcoderObj.ChecksCatalog.remove(hdlcoderObj.ChecksCatalog.keys());
            if(hdlcoderObj.nonTopDut&&strcmp(hdlfeature('NonTopNoModelReference'),'off'))||hdlcoderObj.isDutModelRef
                hdlcoderObj.ChecksCatalog(hdlcoderObj.ModelName)=[];
            end











            failed=hdlcoderObj.createModelList;
            if failed
                checkStruct=hdlcoderObj.ChecksCatalog(hdlcoderObj.ModelName);
                error(message('hdlcommon:workflow:BuildInterfaceTableFail',checkStruct.message));
            end


            obj.MakehdlArgs=hdlturnkey.table.getMakehdlArgs(hDI);



            if~hDI.cliDisplay
                obj.MakehdlArgs=horzcat(obj.MakehdlArgs,{'Verbosity',0});
            end











            try

                if hDI.Verbosity>0
                    hdlDispWithTimeStamp(message('hdlcommon:workflow:ModelCompilationAndPIRCreationStart'),hDI.Verbosity,0);
                end


                [obj.GeneratedPIR,obj.CodegenParams]=compileModelAndCreatePIR(hdlcoderObj,obj.MakehdlArgs);


                if hDI.Verbosity>0
                    hdlDispWithTimeStamp(message('hdlcommon:workflow:ModelCompilationAndPIRCreationComplete'),hDI.Verbosity,0);
                end


                obj.hTable.hTunableParamPortList.buildTunableParamPortList(hdlcoderObj,hDI);


                obj.checkNeedRunEntireMakehdl;

            catch me

                if~isempty(hdlcoderObj.hs)
                    hdlcoderObj.cleanup(hdlcoderObj.hs,false);
                end
                rethrow(me);
            end

        end















        function needRunEntireMakehdl=checkNeedRunEntireMakehdl(obj)


            hT=obj.hTable.hTurnkey;
            hDI=hT.hD;


            nonCliMode=~hDI.cliDisplay;


            dutName=hDI.hCodeGen.getDutName;


            isDUTModelReference=downstream.tool.isDUTModelReference(dutName);


            isDUTTopLevel=downstream.tool.isDUTTopLevel(dutName);


            tunableParamNameList=obj.hTable.hTunableParamPortList.TunableParamNameList;
            hasTunableParam=~isempty(tunableParamNameList);


            isAXI4StreamFrameMode=hDI.hTurnkey.hStream.isAXI4StreamFrameMode;


            emptyPIR=isempty(obj.GeneratedPIR);


            needRunEntireMakehdl=nonCliMode||...
            isDUTModelReference||...
            isDUTTopLevel||...
            isAXI4StreamFrameMode||...
            hasTunableParam||...
            emptyPIR;


            hdlcoderObj=hT.hCHandle;
            if needRunEntireMakehdl&&~isempty(hdlcoderObj.hs)
                obj.reset;
                hdlcoderObj.cleanup(hdlcoderObj.hs,false);
                hdlcoderObj.hs=[];
            end
        end

        function reset(obj)
            obj.GeneratedPIR=[];
            obj.CodegenParams=[];
            obj.MakehdlArgs=[];
        end

    end
end


