classdef SubsystemBlackBoxHDLInstantiation<hdldefaults.abstractBBox



    methods
        function this=SubsystemBlackBoxHDLInstantiation(block)
            supportedBlocks={...
            'built-in/SubSystem',...
            'built-in/ModelReference',...
            };

            if nargin==0
                block='';
            else
                blockPath=strtok(block,'/');
                if iscellstr(blockPath)
                    blockPath=char(blockPath);
                end
                libloc=which(blockPath,'-all');
                for i=1:length(libloc)
                    if(~isempty(strfind(libloc{i},'.mdl'))||~isempty(strfind(libloc{i},'.slx')))
                        libName=dir(libloc{i});
                        libBd=strtok(libName.name,'.');
                        if~bdIsLoaded(libBd)
                            load_system(libBd);
                        end
                        break;
                    end
                end
                if~strcmpi(block,'built-in/SubSystem')&&strcmpi(get_param(block,'BlockType'),'Subsystem')
                    supportedBlocks=block;
                end
            end

            desc=struct(...
            'ShortListing','Subsystem BlackBox HDL instantiation',...
            'HelpText','Instantiate Builtin Subsystems without recursively doing codegeneration');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'CodeGenMode','instantiation',...
            'Description',desc,...
            'ArchitectureNames',{'BlackBox'},...
            'Deprecates','hdldefaults.ModelReferenceHDLInstantiation');


        end

    end

    methods
        hdlcode=emit(this,hC)
        genericsList=getGenericsInfo(this)
        stateInfo=getStateInfo(this,hC)
        hNewC=elaborate(this,hN,hC)
        val=hasDesignDelay(~,~,~)
        registerImplParamInfo(this)
        setGenericsInfo(this,hC)
        setImplParams(this,params)
        v=validateBlock(this,hC)
        v=validateImplParams(this,hC)
        [inPortNames,outPortNames]=getPortNamesFromSimulink(~,blockHandle)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        v=validateVerilogBlackBoxPorts(~,~)
    end

end

