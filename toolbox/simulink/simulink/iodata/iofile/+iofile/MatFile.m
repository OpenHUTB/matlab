classdef MatFile<iofile.File














    properties(Hidden=true,GetAccess=protected,SetAccess=protected)
        Version=1.0;
    end

    methods

        function theMatFile=MatFile(varargin)
            theMatFile=theMatFile@iofile.File(varargin{:});
        end


        function validateFileName(theMatFile,str)


            status=theMatFile.verifyFileName(str);

            if status>0

                [~,~,ext]=fileparts(str);
                if~strcmp(ext,'.mat')
                    DAStudio.error('sl_iofile:matfile:invalidFileType',str)
                end

            end

        end


        function varOut=loadAVariable(theMatFile,varName)
            varOut=load(theMatFile.FileName,varName);
        end


        function matFileData=load(theMatFile)
            matFileData=load(theMatFile.FileName);

        end


        function aList=whos(theMatFile)


            if(~exist(theMatFile.FileName,'file'))
                DAStudio.error('sl_iofile:matfile:invalidFile',theMatFile.FileName);
            end


            aList=whos('-file',theMatFile.FileName);
        end



        function[didWrite,errMsg]=export(~,fileName,cellOfVarNames,cellOfVarValues,isAppend)






            [didWrite,errMsg]=iofile.MatFile.save(fileName,cellOfVarNames,cellOfVarValues,isAppend);
        end
    end

    methods(Access=private)

        function status=verifyFileName(~,fileName)
            status=1;

            if(isempty(fileName))
                DAStudio.error('sl_iofile:matfile:emptyFileName');
            end


        end

    end


    methods(Static)


        function[didWrite,errMsg]=save(fileName,cellOfVarNames,cellOfVarValues,isAppend)

            didWrite=false;

            errMsg='';

            if isstring(cellOfVarNames)&&~isscalar(cellOfVarNames)
                cellOfVarNames=cellstr(cellOfVarNames);
            end

            if isstring(cellOfVarNames)&&isscalar(cellOfVarNames)
                cellOfVarNames={char(cellOfVarNames)};
            end



            if(~iscellstr(cellOfVarNames)||~iscell(cellOfVarValues))||...
                (length(cellOfVarNames)~=length(cellOfVarValues))||...
                (~islogical(isAppend)&&~isnumeric(isAppend))
                return;
            end


            s=struct;


            for k=1:length(cellOfVarNames)
                s.(cellOfVarNames{k})=cellOfVarValues{k};
            end


            try

                if~isAppend||~exist(fileName,'file')

                    save(fileName,'-struct','s');

                else

                    save(fileName,'-struct','s','-append');
                end

                didWrite=true;
            catch ME


                errMsg=ME.message;
                return

            end
        end

    end
end
