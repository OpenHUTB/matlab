classdef(Abstract)ProcessorModelBase<handle




    properties(Access=private,Constant)
        dnnModelBaseDir=fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','model');
    end

    properties(Access=protected)
        hPC;
        ModelRelativePath;
        ModelName;
        HWChipName;
        HWDUTPath;
        Libs;
        Subsystems;

        Verbose=1;
    end

    methods(Access=public,Hidden=true)
    end

    methods(Access=public,Abstract=true)
    end

    methods(Access=protected,Abstract=true)
    end

    methods(Abstract)


        processor=getProcessor(this)



        preModelSetup(this)

        postModelSetup(this)
    end

    methods(Access=protected)

        function ls=getLoadedLibraries(~)
            ls=find_system('SearchDepth',0,'blockdiagramtype','library');

            ls=strtrim(string(char(ls)));
        end

        function ss=getLoadedSubsystems(~)
            ss=find_system('Type','block_diagram');
            selectFcn=@(name,type)isequal(type,get_param(name,'BlockDiagramType'));
            ss=ss(cellfun(@(name)selectFcn(name,'subsystem'),ss));

            ss=strtrim(string(char(ss)));
        end
    end

    methods
        function baseDir=getModelBaseDir(obj)
            baseDir=obj.dnnModelBaseDir;
        end

        function loadModel(obj,isShowModel)


            if nargin<2
                isShowModel=false;
            end


            obj.Libs=obj.getLoadedLibraries();
            obj.Subsystems=obj.getLoadedSubsystems();

            if isShowModel


                open_system(obj.ModelName);
            else

                load_system(obj.ModelName);
            end

            processor=obj.hPC.createProcessorObject;


            convModule=processor.getCC().convp.conv;
            opDUTBitWidthLimit=convModule.opDUTBitWidthLimit;
            if(opDUTBitWidthLimit==32)
                set_param('testbench/Weights_DDR','outDimension','1');
            end

        end

        function setSystemHDLParams(obj,prop,val)
            hdlset_param(obj.ModelName,prop,val);
        end

        function setDUTHDLParams(obj,prop,val)
            hdlset_param(obj.getHWDUTPath,prop,val);
        end

        function modelName=getModelName(obj)
            modelName=obj.ModelName;
        end

        function dut=getHWDUTPath(obj)
            dut=[obj.ModelName,'/',obj.HWChipName];
        end

        function hPC=getProcessorConfig(obj)
            hPC=obj.hPC;
        end

        function closeModel(obj)


            gp=pir;
            gp.destroy;


            currentLibs=obj.getLoadedLibraries();
            currentSubsystems=obj.getLoadedSubsystems();

            bdclose(obj.ModelName);

            bdclose(setdiff(currentLibs,obj.Libs));
            bdclose(setdiff(currentSubsystems,obj.Subsystems));


        end
    end
end


