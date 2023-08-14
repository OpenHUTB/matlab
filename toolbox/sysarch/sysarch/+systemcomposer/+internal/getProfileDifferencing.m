function changeSet=getProfileDifferencing(refProfileName,updatedProfileName)


    if(~isempty(refProfileName)&&~isempty(updatedProfileName))

        added=cell2table(cell(0,2),'VariableNames',{'Type','AddedField'});
        deleted=cell2table(cell(0,2),'VariableNames',{'Type','DeletedField'});
        modified=cell2table(cell(0,4),'VariableNames',{'Type','ModifiedField','OldValue','UpdatedValue'});




        [refPrototypeNameMap,refPropertyDefaultValMap]=systemcomposer.internal.getProfileMap(refProfileName);
        [uptdPrototypeNameMap,uptdPropertyDefaultValMap]=systemcomposer.internal.getProfileMap(updatedProfileName);

        refPrototypeNames=cellfun(@stripProfileName,refPrototypeNameMap.keys,'UniformOutput',false);
        uptdPrototypeNames=cellfun(@stripProfileName,uptdPrototypeNameMap.keys,'UniformOutput',false);

        addedPrototypeNames=uptdPrototypeNames(~ismember(refPrototypeNames,uptdPrototypeNames));
        deletedPrototypeNames=refPrototypeNames(~ismember(uptdPrototypeNames,refPrototypeNames));



        for itr=1:numel(addedPrototypeNames)
            added=[added;cell2table({'Prototype',strcat(refProfileName,'.',addedPrototypeNames{itr})},'VariableNames',{'Type','AddedField'})];
        end
        for itr=1:numel(deletedPrototypeNames)
            deleted=[deleted;cell2table({'Prototype',strcat(refProfileName,'.',deletedPrototypeNames{itr})},'VariableNames',{'Type','DeletedField'})];
        end

        commonPrototypeNames=intersect(uptdPrototypeNames,refPrototypeNames);

        refPropertyNames=cellfun(@stripProfileName,refPropertyDefaultValMap.keys,'UniformOutput',false);
        uptdPropertyNames=cellfun(@stripProfileName,uptdPropertyDefaultValMap.keys,'UniformOutput',false);

        addedPropertyNames=uptdPropertyNames(~ismember(refPropertyNames,uptdPropertyNames));
        deletedPropertyNames=refPropertyNames(~ismember(uptdPropertyNames,refPropertyNames));

        commonPropertyNames=intersect(uptdPropertyNames,refPropertyNames);

        for itr=1:numel(addedPropertyNames)
            added=[added;cell2table({'Property',strcat(refProfileName,'.',addedPropertyNames{itr})},'VariableNames',{'Type','AddedField'})];
        end
        for itr=1:numel(deletedPropertyNames)
            deleted=[deleted;cell2table({'Property',strcat(refProfileName,'.',deletedPropertyNames{itr})},'VariableNames',{'Type','DeletedField'})];
        end


        for cProtoItr=1:numel(commonPrototypeNames)
            prototypeName=commonPrototypeNames(cProtoItr);
            refProtoFQN=strcat(refProfileName,'.',prototypeName);

            refprototype=refPrototypeNameMap(refProtoFQN{:});

            refProperties=refprototype.propertySet.getAllPropertyNames;
            refPropString=refProperties{1};
            for i=2:numel(refProperties)
                refPropString=strcat(refPropString," , ",refProperties(i));
            end

            updtProtoFQN=strcat(updatedProfileName,'.',prototypeName);
            updtprototype=uptdPrototypeNameMap(updtProtoFQN{:});
            updtProperties=updtprototype.propertySet.getAllPropertyNames;
            updtPropString=updtProperties{1};
            for i=2:numel(updtProperties)
                updtPropString=strcat(updtPropString," , ",updtProperties(i));
            end

            if~isequal(refProperties,updtProperties)

                modified=[modified;cell2table({'Prototype',refProtoFQN,refPropString,updtPropString},'VariableNames',{'Type','ModifiedField','OldValue','UpdatedValue'})];
            end
        end

        for pProtoItr=1:numel(commonPropertyNames)

            propertyName=commonPropertyNames(pProtoItr);
            refPropFQN=strcat(refProfileName,'.',propertyName);
            refproperty=refPropertyDefaultValMap(refPropFQN{:});

            refPropertyString=strcat(string(refproperty.defaultValue.expression),"{",string(refproperty.defaultValue.units),'}');

            updtPropFQN=strcat(updatedProfileName,'.',propertyName);
            updtproperty=uptdPropertyDefaultValMap(updtPropFQN{:});
            updtPropertyString=strcat(string(updtproperty.defaultValue.expression),"{",string(updtproperty.defaultValue.units),'}');

            if~isequal(refPropertyString,updtPropertyString)

                modified=[modified;cell2table({'Property',refPropFQN,refPropertyString,updtPropertyString},'VariableNames',{'Type','ModifiedField','OldValue','UpdatedValue'})];
            end
        end

        changeSet.added=added;
        changeSet.modified=modified;
        changeSet.deleted=deleted;
    end
end


function strippedName=stripProfileName(iName)
    if isa(iName,'cell')
        iName=iName{:};
    end
    pos=strfind(iName,'.');
    strippedName=iName(pos+1:end);
end

