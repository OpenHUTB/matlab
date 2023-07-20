classdef File<handle










    properties
FileName

    end


    properties(Hidden)

        filterStruct=struct;













fileMetrics

    end

    methods(Abstract)
        aList=whos(theFile);
        loadAVariable(theFile,varName);
        load(theFile);
        validateFileName(theFile,str);
    end
    methods

        function theFile=File(varargin)

            if nargin==1

                if isstring(varargin{1})&&isscalar(varargin{1})
                    inFile=char(varargin{1});
                else
                    inFile=varargin{1};
                end



                theFile.FileName=deblank(inFile);
            end

            theFile.filterStruct.ALLOW_FOR_EACH=false;
            theFile.filterStruct.ALLOW_EMPTY_DS=false;
            theFile.filterStruct.ALLOW_EMPTY_TS=false;
            theFile.filterStruct.ALLOW_DATASORE_MEM=false;
            theFile.filterStruct.ALLOW_TIME_TABLE=true;

            theFile.fileMetrics.SLDVVarNames={};
            theFile.fileMetrics.SLDVTransformedNames={};
        end


        function set.FileName(theFile,str)

            validateFileName(theFile,str);

            theFile.FileName=str;
        end

        function[importedData,warnStr]=import(theFile)




            narginchk(1,1);


            importedData.Data=[];
            importedData.Names=[];%#ok<STRNU>
            theFile.fileMetrics.SLDVVarNames={};
            theFile.fileMetrics.SLDVTransformedNames={};
            try
                [importedData,warnStr]=theFile.loadAndValidateData();
            catch ME
                [~,fileName,~]=fileparts(theFile.FileName);
                error(message('sl_iofile:matfile:unexpectedDataFormat',fileName));
            end
        end


        function[varOut,warnStr]=importAVariable(theFile,varName)
            varOut=[];
            warnStr=[];

            if isstring(varName)&&isscalar(varName)
                varName=char(varName);
            end


            if~isempty(varName)&&ischar(varName)


                aList=whos(theFile);
                varOnFile={aList.name};


                if~isempty(varOnFile)&&any(ismember(varOnFile,varName))

                    varOut=loadAVariable(theFile,varName);


                    varOut=varOut.(varName);

                    if~isVarSupported(theFile,varOut)
                        varOut=[];
                        warnStr.ID='sl_iofile:matfile:unexpectedDataFormat';
                        [~,fileName,Ext]=fileparts(theFile.FileName);
                        warnStr.message=getString(message('sl_iofile:matfile:unexpectedDataFormat',[fileName,Ext]));
                    end
                end
            end
        end

    end

    methods(Hidden)
        function canSupport=isVarSupported(theFile,inVar)
            canSupport=iofile.Util.isValidSignal(inVar,theFile.filterStruct);
        end
    end


    methods(Access=protected)

        function[importedData,warnStr]=loadAndValidateData(theFile)
            warnStr=[];


            UNSUPPORTED_FOUND=false;


            importedData=[];
            importedData.Data=[];
            importedData.Names=[];


            matFileData=load(theFile);


            structFieldStrs=fieldnames(matFileData);

            for kField=1:length(structFieldStrs)



                if isVarSupported(theFile,matFileData.(structFieldStrs{kField}))

                    importedData=theFile.parseValidSDIData(...
                    matFileData.(structFieldStrs{kField}),...
                    importedData,(structFieldStrs{kField}));


                    if iofile.isaTimeExpression(matFileData.(structFieldStrs{kField}))
                        warnStr.ID='sl_iofile:matfile:TimeExpressionNoSupport';
                        warnStr.message=getString(message('sl_iofile:matfile:TimeExpressionNoSupport'));
                    end
                else

                    UNSUPPORTED_FOUND=true;
                end
            end


            if isempty(importedData.Names)
                warnStr.ID='sl_iofile:matfile:emptyImport';
                warnStr.message=getString(message(...
                'sl_iofile:matfile:emptyImport',...
                theFile.FileName,theFile.FileName));
                warnStr.hole={theFile.FileName,theFile.FileName};
                return;
            end


            if UNSUPPORTED_FOUND&&isempty(warnStr)
                warnStr.ID='sl_iofile:matfile:unexpectedDataFormat';
                warnStr.message=getString(message(...
                'sl_iofile:matfile:unexpectedDataFormat',...
                theFile.FileName));
                warnStr.hole=theFile.FileName;
            end
        end


        function importedData=parseValidSDIData(~,...
            sdiDataIn,importedData,fieldname)

            importedData.Names{...
            length(importedData.Names)+1}=...
            fieldname;
            importedData.Data{...
            length(importedData.Data)+1}=...
            sdiDataIn;

        end


    end
end
