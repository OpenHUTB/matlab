classdef Writer17<coder.internal.asap2.Writer161




    methods(Access=public)






        function writeDimension(this,Variable,~,swap)
            dimension=Variable.Dimensions;
            dimSize=length(dimension);
            if swap&&dimSize>1
                dimension([2,1])=dimension([1,2]);
            end
            str=sprintf(repmat('%d ',1,dimSize),dimension);
            this.FormatContentsObj.wLine(['    MATRIX_DIM                        ',str]);
        end
        function sourceFile=getSourceFile(~,arrayLayout)


            if strcmp(arrayLayout,'ROW_DIR')
                sourceFile=fullfile(matlabroot,'toolbox','coder','xcp','+coder','+asap2','RecordLayoutsRowDir17.a2l');
            else
                sourceFile=fullfile(matlabroot,'toolbox','coder','xcp','+coder','+asap2','RecordLayoutsColumnDir17.a2l');
            end
        end

    end

end


