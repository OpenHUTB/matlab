classdef(Sealed,StrictDefaults,Hidden)DataGeneratorBlock<fixed.DataGeneratorEngine







    properties(Nontunable)




        OutputIsDoneFlag(1,1)logical=false;
    end

    methods

        function obj=DataGeneratorBlock(varargin)









            obj=obj@fixed.DataGeneratorEngine(varargin{:});
        end
    end


    methods(Access=protected)
        function nout=getNumOutputsImpl(obj)


            nout=numel(obj.DataSpecifications)+obj.OutputIsDoneFlag;
        end

        function varargout=stepImpl(obj)



            varargout=cell(1,nargout);
            for i=1:obj.NumDataSpecs
                varargout{i}=obj.OutBuf{i};
            end


            stepImpl@fixed.DataGeneratorEngine(obj);


            if obj.OutputIsDoneFlag
                varargout{nargout}=obj.IsDone;
            end
        end

        function varargout=getOutputDataTypeImpl(obj)


            nds=numel(obj.DataSpecifications);
            varargout=cell(1,nargout);
            for i=1:nds
                varargout{i}=numerictype(obj.DataSpecifications{i}.getDataTypeInfo);
            end
            if obj.OutputIsDoneFlag
                varargout{nargout}='logical';
            end
        end

        function varargout=isOutputComplexImpl(obj)


            nds=numel(obj.DataSpecifications);
            varargout=cell(1,nargout);
            for i=1:nds
                varargout{i}=strcmp(obj.DataSpecifications{i}.Complexity,'complex');
            end
            if obj.OutputIsDoneFlag
                varargout{nargout}=false;
            end
        end

        function varargout=getOutputSizeImpl(obj)




            nds=numel(obj.DataSpecifications);
            varargout=cell(1,nargout);
            for i=1:nds
                if isscalar(obj.DataSpecifications{i}.Dimensions)
                    varargout{i}=[1,obj.DataSpecifications{i}.Dimensions];
                else
                    varargout{i}=obj.DataSpecifications{i}.Dimensions;
                end
            end
            if obj.OutputIsDoneFlag
                varargout{nargout}=[1,1];
            end
        end

        function varargout=isOutputFixedSizeImpl(~)



            varargout=repmat({true},1,nargout);
        end

        function maskDisplayCommands=getMaskDisplayImpl(obj)




            nds=numel(obj.DataSpecifications);
            iconText="";
            outportLabelCommands={};
            for i=1:nds
                iconText=iconText+sprintf("out%d: %s (%s) [%s]",i,...
                obj.DataSpecifications{i}.getDataTypeInfo,...
                obj.DataSpecifications{i}.Complexity,...
                num2str(obj.DataSpecifications{i}.Dimensions))+"\n";
                outportLabelCommands{i}=char(sprintf("port_label('output', %d, 'out%d');",i,i));%#ok
            end
            if~isempty(obj.NumDataSpecs)

                iconText=iconText+"\n"+sprintf("Number of steps: %d",obj.CPSize);
            end
            iconTextCommands=char(sprintf("text(5, 50, '%s', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');",iconText));
            if obj.OutputIsDoneFlag
                outportLabelCommands{nds+1}=char(sprintf("port_label('output', %d, 'done');",nds+1));
            end
            maskDisplayCommands=[...
            {'plot([0 0 100 100 0], [0 100 100 0 0]);'},...
            {iconTextCommands},...
outportLabelCommands
            ];
        end
    end

    methods(Static,Access=protected)
        function simMode=getSimulateUsingImpl



            simMode="Interpreted execution";
        end
    end
end
