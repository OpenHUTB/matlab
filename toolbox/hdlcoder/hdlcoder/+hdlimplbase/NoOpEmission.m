classdef NoOpEmission<hdlimplbase.HDLDirectCodeGen




























    methods
        function this=NoOpEmission(~)


            desc=struct(...
            'ShortListing','No Op',...
            'HelpText','Do Nothing');

            this.init('SupportedBlocks','all',...
            'CodeGenMode','emission',...
            'HandleType','useobjandcomphandles',...
            'Description',desc);
        end
    end

    methods

        function hdlcode=emit(~,~)

            hdlcode=hdlcodeinit;
        end


        function[v]=validate(~,~)
            v.Status=0;
            v.Message='';
            v.MessageID='NoOpEmission:validate';
        end

    end
end
