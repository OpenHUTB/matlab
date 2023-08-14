classdef DataDictionaryEntry<lutdesigner.data.source.DataSource

    methods
        function this=DataDictionaryEntry(filePath,entryName)
            assert(endsWith(filePath,'.sldd')&&isfile(filePath),...
            'lutdesigner:data:cannotFindFileAtGivenPath',...
            sprintf('File at path %s does not exist or is not in MATLAB path.',filePath));

            [~,fileName,extension]=fileparts(filePath);
            fileFullPath=which([fileName,extension]);

            this=this@lutdesigner.data.source.DataSource(...
            'data dictionary',...
            fileFullPath,...
            entryName);
        end

        function tf=isOpened(this)
            tf=ismember(this.Source,Simulink.data.dictionary.getOpenDictionaryPaths());
        end
    end

    methods(Access=protected)
        function restrictions=getReadRestrictionsImpl(~)
            restrictions=lutdesigner.data.restriction.ReadRestriction.empty();
        end

        function restrictions=getWriteRestrictionsImpl(~)
            restrictions=lutdesigner.data.restriction.WriteRestriction.empty();
        end

        function data=readImpl(this)
            wasOpened=this.isOpened();
            file=Simulink.data.dictionary.open(this.Source);
            if~wasOpened
                oc=onCleanup(@()file.close());
            end
            entry=getDesignDataEntry(file,this.Name);
            data=entry.getValue();
        end

        function writeImpl(this,data)
            file=Simulink.data.dictionary.open(this.Source);
            entry=getDesignDataEntry(file,this.Name);
            entry.setValue(data);
        end
    end
end

function entry=getDesignDataEntry(file,entryName)
    section=file.getSection('Design Data');
    entry=section.getEntry(entryName);
end
