


classdef queryflowmodesenum
    enumeration
        NONE,MATLAB,VIVADOSYSGEN
    end

    methods
        function isQueryFlow=isQueryFlow(obj)
            isQueryFlow=obj~=downstream.queryflowmodesenum.NONE;
        end

        function tclFileName=getTclFileName(obj)
            switch obj
            case downstream.queryflowmodesenum.VIVADOSYSGEN
                tclFileName='sysgensimscripts_prj';
            otherwise
                tclFileName='';
            end
        end

        function tclDirName=getTclDirName(obj)
            switch obj
            case downstream.queryflowmodesenum.VIVADOSYSGEN
                tclDirName='sysgensimscripts_prj';
            otherwise
                tclDirName='';
            end
        end

        function defaultProjectFolder=getDefaultProjectFolder(obj,hdlDrv,defvalue)
            switch obj
            case downstream.queryflowmodesenum.VIVADOSYSGEN

                if~isempty(hdlDrv)&&isempty(strfind(hdlDrv.hdlGetCodegendir,'hdl_prj'))
                    defaultProjectFolder='';
                else
                    defaultProjectFolder=defvalue;
                end
            otherwise
                defaultProjectFolder=defvalue;
            end
        end

        function tclFilePath=getTclFilePath(obj,hDI)
            switch obj
            case downstream.queryflowmodesenum.VIVADOSYSGEN
                hdlDrv=hDI.hCodeGen.hCHandle;
                tclFilePath=fullfile(hdlDrv.hdlGetCodegendir,obj.getTclDirName,[obj.getTclFileName,'.tcl']);
            otherwise
                tclFilePath='';
            end
        end

        function driveTclEmitter(obj,tEmitter,fid)
            switch obj
            case downstream.queryflowmodesenum.VIVADOSYSGEN
                tEmitter.printAddSimFileTcl(fid);
                tEmitter.printSetSourceTop(fid);
                tEmitter.printSetSimTop(fid);
            end
        end

        function createHDISetup(obj,hDI,varargin)

            pvMap=obj.parseInputPV(varargin);


            switch obj
            case downstream.queryflowmodesenum.VIVADOSYSGEN

                if pvMap.isKey('modelName')
                    modelName=pvMap('modelName');
                else
                    modelName=[];
                end

                if pvMap.isKey('hdlDrv')
                    hdlDrv=pvMap('hdlDrv');
                else
                    hdlDrv=[];
                end


                hDI.hCodeGen=downstream.CodeGenInfo(hDI,modelName,hdlDrv);

                hDI.hCodeGen.hCHandle.DownstreamIntegrationDriver=hDI;
            case downstream.queryflowmodesenum.MATLAB

                if pvMap.isKey('modelName')
                    modelName=pvMap('modelName');
                else
                    modelName=[];
                end


                hDI.hCodeGen.dutName=modelName;
                hDI.hCodeGen.getDutName=@()hDI.hCodeGen.dutName;
            end
        end

        function postCreateHDISetup(obj,hDI)

            switch obj
            case downstream.queryflowmodesenum.VIVADOSYSGEN

                hDI.hCodeGen.getDUTCodeGenInfo;
                hDI.hCodeGen.setBackupCgInfo;


                hDI.set('tool','Xilinx Vivado');
                [simScriptsProjectDir,tclFileName,tclFileExt]=fileparts(obj.getTclFilePath(hDI));
                hDI.setProjectPath(simScriptsProjectDir);
                hDI.hToolDriver.hEmitter.TclFileName=[tclFileName,tclFileExt];
            end
        end



        function pvMap=parseInputPV(obj,pv)
            pvMap=containers.Map;
            for i=1:2:length(pv)-1
                prop=pv{i};
                val=pv{i+1};
                pvMap(prop)=val;
            end
        end
    end
end
