classdef HDLC<hdlimplbase.HDLDirectCodeGen



    properties

        component=[];

        InputPortNames=[];

        OutputPortNames=[];

        blkParam=[];
    end


    methods
        function this=HDLC(block,param)
            supportedBlocks={...
            'none',...
            };

            desc=struct(...
            'ShortListing','Place Holder for @hdl components',...
            'HelpText','Place Holder for @hdl components');

            if nargin==0
                CodeGenMode='emission';
            else
                component=feval(block,param{:});
                CodeGenMode=component.CodeGenMode;
                this.component=component;
                this.InputPortNames=component.InputPortName;
                this.OutputPortNames=component.OutputPortName;
                this.blkParam=component.blkParam;
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block','none',...
            'CodeGenMode',CodeGenMode,...
            'Description',desc);




        end

    end

    methods
    end

    methods
        hdlcode=emit(this,hC,component)
        generateClocks(this,hN,hC)
        stateInfo=getStateInfo(this,hC)
    end


    methods(Hidden)
        str=getCodeGenMode(this)
    end

end

