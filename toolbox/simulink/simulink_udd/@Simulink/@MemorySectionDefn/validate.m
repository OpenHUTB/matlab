function result=validate(hThis)




    result={};
    myName=hThis.Name;
    try
        LocalValidateMemorySectionDefn(hThis);

    catch err
        expression=DAStudio.message('Simulink:dialog:MATLABErrorPrefixText');
        expression=[expression,'[^\n]*\n'];
        tmpReason=regexprep(err.message,expression,'');
        result={myName;tmpReason};
    end
end


function LocalValidateMemorySectionDefn(msDefn)


    if RTW.isKeywordInTLC(msDefn.Name)
        DAStudio.error('Simulink:dialog:MSNameIsTLCKeyword',msDefn.Name);
    end



    if~isvarname(msDefn.getProp('Name'))
        DAStudio.error('Simulink:dialog:CSCDefnInvalidName');
    end



    if~isempty(msDefn.getProp('Comment'))&&~iscComment(msDefn.getProp('Comment'))
        DAStudio.error('Simulink:dialog:MSDefnInvalidComment');
    end

    if msDefnHasPercentAngle(msDefn)
        DAStudio.error('Simulink:dialog:MSDefnIdentSubstTLCTokensFound');
    end

    if(~msDefn.getProp('PragmaPerVar')&&...
        pragmasUseIdentifierSubstitution(msDefn))
        DAStudio.error('Simulink:dialog:MSDefnIdentSubstPragmaPerVar');
    end

end


function rtn=pragmasUseIdentifierSubstitution(msDefn)
    rtn=(contains(msDefn.PrePragma,'$N')||...
    contains(msDefn.PostPragma,'$N'));
end


function rtn=msDefnHasPercentAngle(msDefn)



    rtn=false;

    if(length(strfind(msDefn.getProp('Comment'),'%<')))%#ok
        rtn=true;
        return
    end
    if(length(strfind(msDefn.getProp('Qualifier'),'%<')))%#ok
        rtn=true;
        return
    end



    prePragmaStr=msDefn.getProp('PrePragma');
    matches=regexp(prePragmaStr,'%<','match');
    validatorRegex='%<(?=AUTOSAR_COMPONENT|MemorySectionName>)';
    if~isempty(matches)
        completeMatches=regexp(prePragmaStr,validatorRegex,'match');
        rtn=~(length(matches)==length(completeMatches));
    end
    postPragmaStr=msDefn.getProp('PostPragma');
    matches=regexp(postPragmaStr,'%<','match');
    if~isempty(matches)
        completeMatches=regexp(postPragmaStr,validatorRegex,'match');
        rtn=~(length(matches)==length(completeMatches));
    end
end


function rtn=iscComment(comment)







    rtn=false;

    if strcmp(class(comment),'char')%#ok
        correctStartAndEnd=false;

        comment=strtrim(comment);
        len=length(comment);
        if len>=4
            correctStartAndEnd=strcmp(comment(1:2),'/*')&...
            (strfind(comment,'*/')==len-1);
        end

        if correctStartAndEnd
            rtn=true;
        end
    end

end




