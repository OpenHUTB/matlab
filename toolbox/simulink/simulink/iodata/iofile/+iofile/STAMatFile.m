classdef STAMatFile<iofile.MatFile







    methods

        function theMatFile=STAMatFile(varargin)
            theMatFile=theMatFile@iofile.MatFile(varargin{:});
        end


        function whosFileData=whos(theMatFile)

            unsortedMatFileData=load(theMatFile.FileName);
            theNameOfTheFields=fieldnames(unsortedMatFileData);

            if~isempty(theNameOfTheFields)
                whosFileData=cell2struct(theNameOfTheFields,'name',length(theNameOfTheFields));
            else
                whosFileData=[];
            end
        end


        function varOut=loadAVariable(theMatFile,varName)

            whosDefault=whos('-file',theMatFile.FileName);
            whosOnFileRAW={whosDefault.name};

            if any(strcmp(whosOnFileRAW,varName))
                varOut=load(theMatFile.FileName,varName);
                return;
            else


                [importedData,~]=import(theMatFile);

                idxSigMatch=strcmp(importedData.Names,varName);


                if any(idxSigMatch)

                    varOut.(varName)=importedData.Data{idxSigMatch};
                else

                    DAStudio.error('sl_iofile:matfile:varNotOnFile',varName);
                end

            end

        end


        function sortedMatFileData=load(theMatFile)




            unsortedMatFileData=load(theMatFile.FileName);
            sortedMatFileData=orderfields(unsortedMatFileData);

        end

    end

end
