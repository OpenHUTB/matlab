function tf=isSupportedObject(sfObj)
    sfClass=class(sfObj);
    tf=ismember(sfClass,rmisf.sfisa('supportedTypes'));
end