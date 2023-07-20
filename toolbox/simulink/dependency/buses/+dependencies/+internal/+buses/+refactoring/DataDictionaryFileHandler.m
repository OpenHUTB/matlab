classdef DataDictionaryFileHandler<dependencies.internal.buses.refactoring.FileHandler




    properties(Constant)
        Type=dependencies.internal.buses.analysis.DataDictionaryNodeAnalyzer.BaseType;
    end

    methods

        function changeName(this,filePath,oldVariableName,newVariableName)
            [entry,dictionary]=this.openDictionary(filePath,oldVariableName);
            entry.Name=newVariableName;
            dictionary.saveChanges;
        end

        function modifyObject(this,filePath,variableName,updateSignalFunc)
            [entry,dictionary]=this.openDictionary(filePath,variableName);
            newObject=updateSignalFunc(entry.getValue);
            entry.setValue(newObject);
            dictionary.saveChanges;
        end

    end

    methods(Static,Access=private)

        function[entry,dictionary]=openDictionary(filePath,variableName)
            dictionary=Simulink.data.dictionary.open(filePath);
            section=dictionary.getSection('Design Data');
            entry=section.getEntry(variableName);
        end

    end

end

