function[pValue,propName]=getPropValue(~,objList,propName)





    switch propName
    case 'DataSources'
        pValue={objList(:).DataSources};

    case 'HasUnsavedChanges'
        pValue={objList(:).HasUnsavedChanges};

    case 'NumberOfEntries'
        pValue={objList(:).NumberOfEntries};
    otherwise
        pValue='';
    end





