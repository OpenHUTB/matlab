classdef MatFileHandler<dependencies.internal.buses.refactoring.FileHandler




    properties(Constant)
        Type=dependencies.internal.buses.analysis.MatBusNodeAnalyzer.BaseType;
    end

    methods

        function changeName(~,filePath,oldVariableName,newVariableName)
            data=load(filePath);
            data.(newVariableName)=data.(oldVariableName);
            data=rmfield(data,oldVariableName);
            save(filePath,'-v7.3','-struct','data');
        end

        function modifyObject(~,filePath,variableName,updateSignalFunc)
            data=load(filePath,variableName);
            data.(variableName)=updateSignalFunc(data.(variableName));
            save(filePath,'-struct','data','-append',variableName);
        end

    end

end
