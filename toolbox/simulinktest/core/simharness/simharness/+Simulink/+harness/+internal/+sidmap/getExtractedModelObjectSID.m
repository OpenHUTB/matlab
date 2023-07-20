function sid=getExtractedModelObjectSID(origSID,subSystemBlockH,extractModelName)




    featureOn=slfeature('UnifiedHarnessExtract')>0;
    assert(featureOn,'UnifiedHarnessExtract feature should be on when calling extractSubsystem');

    origMdlName=get_param(bdroot(subSystemBlockH),'Name');
    idx=strfind(origSID,':');
    origSubsystem=subSystemBlockH;
    if strcmp(origMdlName,extractModelName)

        origMdlName=origSID(1:idx(1)-1);


        origSubsystem=find_system(origMdlName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SID','1');
        newSubsystem=subSystemBlockH;
    else


        newSubsystem=find_system(extractModelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SID','1');
    end

    origSID=origSID(idx(1)+1:end);




    origObjHandle=find_system(origSubsystem,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SID',origSID);

    if isempty(origObjHandle)
        sid=[extractModelName,':',origSID];
        return;
    end

    if iscell(origObjHandle)
        origObjHandle=origObjHandle{1};
    end
    if iscell(origSubsystem)
        origSubsystem=origSubsystem{1};
    end
    if iscell(newSubsystem)
        newSubsystem=newSubsystem{1};
    end
    origObj=get_param(origObjHandle,'Object');
    origObjFullName=origObj.getFullName;

    subsysObj=get_param(origSubsystem,'Object');
    subsysFullname=subsysObj.getFullName;

    origObjRelPath=strrep(origObjFullName,subsysFullname,'');

    try
        if isempty(origObjRelPath)


            objInNewModel=newSubsystem;
        else


            objInNewModel=find_system([newSubsystem,origObjRelPath],'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
            objInNewModel=objInNewModel{1};
        end
        sid=Simulink.ID.getSID(objInNewModel);
    catch
        sid=[extractModelName,':',origSID];
    end

end
