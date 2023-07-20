


classdef WrapGenBase<hdlwfsmartbuild.SmartbuildBase



    properties(Constant,Hidden=true)
        SBSTATUSFILENAME='hdlwfbuildstatus.mat';
        CODEGENSTATUSFILENAME='hdlcodegenstatus.mat';
    end
    properties(Access=protected)
        hDI;
    end

    methods(Access=public)

        function obj=WrapGenBase(hDIhandle)
            obj=obj@hdlwfsmartbuild.SmartbuildBase;
            obj.hDI=hDIhandle;
        end

        function setTargetMap(this,targetMap)
            targetMap('Workflow')=this.hDI.get('Workflow');
            targetMap('Board')=this.hDI.get('Board');
            targetMap('Tool')=this.hDI.get('Tool');
            targetMap('Family')=this.hDI.get('Family');
            targetMap('Device')=this.hDI.get('Device');
            targetMap('Package')=this.hDI.get('Package');
            targetMap('Speed')=this.hDI.get('Speed');
            targetMap('ProjectFolder')=this.hDI.getProjectFolder;%#ok<NASGU>
        end



        function cmpsaveDUTChecksum(this)



            sbStatusFileFullName=fullfile(getProp(this.hDI.hCodeGen.hCHandle.getINI,'codegendir'),this.hDI.hCodeGen.ModelName,this.SBSTATUSFILENAME);

            DUTchecksumstr='';
            codeGenhandle=this.hDI.hCodeGen.hCHandle;
            numModels=numel(codeGenhandle.AllModels);
            for mdlIdx=1:numModels
                codeGenhandle.mdlIdx=mdlIdx;
                statusmatDir=codeGenhandle.hdlGetCodegendir;
                statusmatFile=fullfile(statusmatDir,this.CODEGENSTATUSFILENAME);

                if(exist(statusmatFile,'file'))&&(~isempty(statusmatFile))


                    checksumRtl=this.mySbServe.getDUTChecksumFile(statusmatFile,codeGenhandle.ModelName);
                else
                    return;
                end
                DUTchecksumstr=[DUTchecksumstr,';',checksumRtl];%#ok<AGROW>
            end
            dutchecksum=this.mySbServe.getChecksumStr(DUTchecksumstr);

            this.mySbServe.saveVarToFile(sbStatusFileFullName,'dutChecksum',dutchecksum);

        end

    end

end


