classdef FromFilePreviewMatFile<iofile.STAMatFile






    methods

        function theMatFile=FromFilePreviewMatFile(varargin)
            theMatFile=theMatFile@iofile.STAMatFile(varargin{:});
        end


        function loadOutput=load(theMatFile)

            loadOutput=load@iofile.STAMatFile(theMatFile);


            structFieldStrs=fieldnames(loadOutput);

            for kField=1:length(structFieldStrs)
                if ismatrix(loadOutput.(structFieldStrs{kField}))
                    loadOutput.(structFieldStrs{kField})=loadOutput.(structFieldStrs{kField})';
                end
            end


        end



        function varOut=loadAVariable(theMatFile,varName)

            varOut=loadAVariable@iofile.STAMatFile(theMatFile,varName);

            if ismatrix(varOut.(varName))
                varOut.(varName)=(varOut.(varName))';
            end


        end


    end

end
