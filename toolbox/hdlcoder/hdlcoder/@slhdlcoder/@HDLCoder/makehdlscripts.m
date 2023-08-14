function makehdlscripts(this,p,isTestbenchMode)




    if nargin<3
        isTestbenchMode=false;
    end


    oldDriver=hdlcurrentdriver;
    hdlcurrentdriver(this);
    oldMode=hdlcodegenmode;
    hdlcodegenmode('slcoder');

    codegenDir=this.hdlGetCodegendir;
    if isTestbenchMode
        isTopModel=true;
    elseif numel(this.AllModels)==1
        isTopModel=true;
    else
        isTopModel=strcmp(this.ModelName,p.ModelName);
    end

    if isTopModel
        topName=this.getEntityTop;

        ext=this.PirInstance.getHDLFileExtension;







        if this.getParameter('BuildToProtectModel')&&...
            strcmpi(this.getParameter('target_language'),'VHDL')
            topName=p.ModelName;
            if strcmpi(this.getParameter('use_single_library'),'on')
                libName=this.getParameter('vhdl_library_name');
            else
                libName=[this.getParameter('vhdl_library_name'),'_',topName];
            end
            oldLibName=this.getParameter('vhdl_library_name');
            this.setParameter('vhdl_library_name',libName);
        end

        if~isTestbenchMode
            subSysName=this.cgInfo.topName;
            hdlFiles=this.cgInfo.hdlFiles;
            if length(this.AllModels)>1
                for itr=1:length(this.AllModels)-1
                    p=pir(this.AllModels(itr).modelName);
                    fList=p.getEntityNames;
                    for itj=1:length(fList)
                        hdlFiles{end+1}=fullfile(this.AllModels(itr).modelName,[fList{itj},ext]);%#ok<AGROW>
                    end
                end
            end


            switch(upper(this.getCLI.HDLLintTool))
            case{'LEDA'}
                prjFullName=fullfile(codegenDir,[subSysName,'_LEDA.prj']);
                hdlcodingstd.Report.genLEDAScript(subSysName,hdlFiles,prjFullName);
            case{'SPYGLASS'}
                prjFullName=fullfile(codegenDir,[subSysName,'_spyglass.prj']);
                hdlcodingstd.Report.genSpyGlassScript(subSysName,hdlFiles,prjFullName);
            case{'CUSTOM'}
                prjFullName=fullfile(codegenDir,[subSysName,'_default.prj']);
                hdlcodingstd.Report.genDefaultScript(subSysName,hdlFiles,prjFullName);
            case{'ASCENTLINT'}
                prjFullName=fullfile(codegenDir,[subSysName,'_AscentLint.prj']);
                hdlcodingstd.Report.genAscentLintScript(subSysName,hdlFiles,prjFullName);
            case{'HDLDESIGNER'}
                prjFullName=fullfile(codegenDir,[subSysName,'_HDLDesigner.prj']);
                hdlcodingstd.Report.genHDLDesignerScript(subSysName,hdlFiles,prjFullName);
            case{'NONE'}

            otherwise
                assert(false,'Unknown Lint Tool Option - Fatal error');
            end

        end

    else
        topName=p.ModelName;
        if strcmpi(this.getParameter('use_single_library'),'on')
            libName=this.getParameter('vhdl_library_name');
        else
            libName=[this.getParameter('vhdl_library_name'),'_',topName];
        end
        oldLibName=this.getParameter('vhdl_library_name');
        this.setParameter('vhdl_library_name',libName);
    end

    if(this.isIPTestbench&&isTestbenchMode)

        this.getIPTestbenchSrcFileList;
    end

    gp=pir;
    scriptGen=hdlshared.EDAScriptsBase(...
    p.getEntityNames,...
    p.getEntityPaths,...
    this.TestBenchFilesList,...
    topName,...
    isTopModel,...
    codegenDir,...
    this.SubModelData,...
    gp.getTargetCodeGenSuccess);

    scriptGen.writeAllScripts;


    if~isTopModel

        this.setParameter('vhdl_library_name',oldLibName);
    end

    hdlcurrentdriver(oldDriver);
    hdlcodegenmode(oldMode);

end

