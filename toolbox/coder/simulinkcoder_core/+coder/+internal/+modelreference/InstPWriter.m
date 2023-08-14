classdef InstPWriter<handle
    properties(Access=private)
ModelInterface
ModelInterfaceUtils
Writer
    end


    methods(Access=public)
        function this=InstPWriter(modelInterfaceUtils,writer)
            this.ModelInterfaceUtils=modelInterfaceUtils;
            this.ModelInterface=this.ModelInterfaceUtils.getModelInterface;
            this.Writer=writer;
        end


        function write(this)
            if~this.ModelInterfaceUtils.isMultiInstance
                if isfield(this.ModelInterface,'CoderDataGroups')
                    coderDataGroups=this.ModelInterface.CoderDataGroups;
                    numCoderDataGroups=numel(coderDataGroups.CoderDataGroup);
                    for i=1:numCoderDataGroups
                        if numCoderDataGroups==1
                            coderDataGroup=coderDataGroups.CoderDataGroup;
                        else
                            coderDataGroup=coderDataGroups.CoderDataGroup{i};
                        end
                        if coderDataGroup.IsInstanceSpecific&&...
                            coderDataGroup.SingleInstanceDefiner&&...
                            strcmp(coderDataGroup.DataInit,'Static')
                            this.writeInstP(coderDataGroup);
                        end
                    end
                end
            end
        end
    end



    methods(Access=private)
        function writeInstP(this,coderDataGroup)
            this.Writer.writeLine('%s %s;',coderDataGroup.Type,coderDataGroup.SelfPath);
        end
    end

end
