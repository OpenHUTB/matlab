function createInternal(ddConnection,creationMode)














    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();

    if strcmp(creationMode,'testing')
        allowedValuesCalPrm=Simulink.CodeMapping.CalPrmCoderGroups;
        allowedValuesVariable=Simulink.CodeMapping.VariablesCoderGroups;
        ListML=[allowedValuesCalPrm,allowedValuesVariable];
        paramGroup=[ones(1,length(allowedValuesCalPrm)),zeros(1,length(allowedValuesVariable))];
    else
        ListML={};
    end
    swcEntry=coder.internal.CoderDataStaticAPI.getSWCT(ddConnection);
    for idx=1:length(ListML)
        cdict=hlp.openDD(ddConnection);
        foundEntry=hlp.findEntry(cdict,'AbstractStorageClass',ListML{idx});
        if~isempty(foundEntry)
            continue;
        end

        cgEntry=hlp.createEntry(cdict,'StorageClass',ListML{idx});
        if paramGroup(idx)

            hlp.setProp(cgEntry,'DataInit','Static');
            hlp.addAllowableCoderDataForElement(swcEntry,'StorageClass','Constants',cgEntry,true);
            hlp.addAllowableCoderDataForElement(swcEntry,'StorageClass','LocalParameters',cgEntry,true);
            hlp.addAllowableCoderDataForElement(swcEntry,'StorageClass','ParameterArguments',cgEntry,true);
            hlp.addAllowableCoderDataForElement(swcEntry,'StorageClass','GlobalParameters',cgEntry,true);
        else

            hlp.setProp(cgEntry,'DataInit','Dynamic');
            hlp.addAllowableCoderDataForElement(swcEntry,'StorageClass','Inports',cgEntry,true);
            hlp.addAllowableCoderDataForElement(swcEntry,'StorageClass','Outports',cgEntry,true);
            hlp.addAllowableCoderDataForElement(swcEntry,'StorageClass','InternalData',cgEntry,true);
            hlp.addAllowableCoderDataForElement(swcEntry,'StorageClass','DataTransfers',cgEntry,true);
            hlp.addAllowableCoderDataForElement(swcEntry,'StorageClass','ModelData',cgEntry,true);
            hlp.addAllowableCoderDataForElement(swcEntry,'StorageClass','SharedLocalDataStores',cgEntry,true);
            hlp.addAllowableCoderDataForElement(swcEntry,'StorageClass','GlobalDataStores',cgEntry,true);

        end
    end
end


