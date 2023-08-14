classdef SLDVMatFile<Simulink.io.MatFile



    methods

        function[varOut,warnStr]=importAVariable(theFile,varName)



            DAStudio.error('sl_web_widgets:customfiles:slSLDVImportAVariableNotSupported');
        end

    end

    methods(Hidden)

        function aList=whosImpl(aFile)





            matFileData=load(aFile.FileName);
            varList=fieldnames(matFileData);
            aList=struct;


            if length(varList)==1&&isSLDVTestVector(matFileData.(varList{1}))
                dataSetList=sldvsimdata(matFileData.(varList{1}));
                for i=1:length(dataSetList)
                    if~(isa(dataSetList(i),'Simulink.SimulationData.Dataset'))

                        aList=[];
                        break;
                    end
                    varName=dataSetList(i).Name;
                    if~isvarname(varName)
                        varName=convertTestCaseName(aFile,varName);
                    end
                    aList(i).name=varName;
                    aList(i).type=Simulink.io.FileType.getVariableTypeFromVariable(dataSetList(i));
                end
            else
                aList=[];
            end
        end

        function matFileData=loadImpl(aFile)



            try

                matFileData=load(aFile.FileName);
                if isempty(matFileData)
                    DAStudio.error('sl_web_widgets:customfiles:slSLDVMatFileLoadEmpty',aFile.FileName);
                end


                varList=fieldnames(matFileData);
                if isempty(varList)
                    DAStudio.error('sl_web_widgets:customfiles:slSLDVMatFileLoadEmpty',aFile.FileName);
                end


                if length(varList)~=1
                    DAStudio.error('sl_web_widgets:customfiles:slSLDVMatFileInvalid');
                end
                if~isSLDVTestVector(matFileData.(varList{1}))
                    DAStudio.error('sl_web_widgets:customfiles:slSLDVMatFileLoadEmpty',aFile.FileName);
                end


                matFileData=convertSLDVData(aFile,matFileData);
            catch ME
                throwAsCaller(ME);
            end
        end

        function[didWrite,errMsg]=exportImpl(~,fileName,cellOfVarNames,cellOfVarValues,isAppend)




            DAStudio.error('sl_web_widgets:customfiles:slSLDVMatFileExportNotSupported');
        end

        function varOut=loadAVariableImpl(aFile,varName)
















            DAStudio.error('sl_web_widgets:customfiles:slSLDVLoadAVariableNotSupported');
        end

    end

    methods(Access=private)

        function newMatFileData=convertSLDVData(aFile,matFileData)






            newMatFileData=matFileData;
            varList=fieldnames(newMatFileData);
            for i=1:length(varList)
                if isSLDVTestVector(newMatFileData.(varList{i}))
                    dataSetList=sldvsimdata(newMatFileData.(varList{i}));
                    for j=1:length(dataSetList)
                        if~(isa(dataSetList(j),'Simulink.SimulationData.Dataset'))
                            DAStudio.error('sl_web_widgets:customfiles:slSLDVConversionFailed',aFile.FileName);
                        end
                        varName=dataSetList(j).Name;
                        if~isvarname(varName)

                            varName=convertTestCaseName(aFile,varName);
                            dataSetList(j).Name=varName;
                        end
                        newMatFileData.(varName)=dataSetList(j);
                    end
                    newMatFileData=rmfield(newMatFileData,varList{i});
                end
            end
        end

        function validVarName=convertTestCaseName(~,testCaseName)





            validVarName=matlab.lang.makeValidName(deblank(testCaseName));
        end

    end

    methods(Static)

        function isSupported=isFileSupported(fileLocation)
            isSupported=false;
            [~,~,ext]=fileparts(fileLocation);
            if strcmpi(ext,'.mat')
                isSupported=true;
            end
        end

        function aFileReaderDescription=getFileTypeDescription()
            aFileReaderDescription=DAStudio.message('sl_web_widgets:customfiles:slSLDVMatFileDescription');
        end

    end

end