function[result,msgString,desc]=isValidSimscapeComponent(componentName)








    desc='';
    filePath=which(componentName);

    clear(filePath);

    if~isempty(filePath)
        try

            cm=feval(componentName);
            simscape.validateModel(cm);


            cs=simscape.schema.guiXformedComponentSchema(componentName);
            d=simscape.schema.internal.derivedParameters(cs);



            [result,msgString]=lValidateBuiltinConflicts(cs,d);
            if~result
                return
            end


            [result,msgString]=lValidateDerivedConflicts(cs,d);
            if~result
                return
            end

            i=cs.info();
            desc=sprintf(i.Descriptor);
            msgString=i.Description;

        catch ME



            theMessage=lGetEscapedMessage(ME.message);
            newException=MException(ME.identifier,theMessage);
            for idx=1:numel(ME.cause)
                newException=newException.addCause(ME.cause{idx});
            end
            for idx=1:numel(ME.stack)
                frame=ME.stack(idx);
                [~,~,ext]=fileparts(frame.file);
                if strcmp(ext,'.ssc')
                    newException=newException.addCause(MException(...
                    message('physmod:ne_sli:dialog:LineNumber',...
                    frame.file,...
                    frame.line)));
                end
            end
            msgString=lMakeReport(newException);
            result=false;
        end
    else
        out=message('physmod:simscape:engine:sli:block:FileNotOnPath',componentName);
        msgString=out.getString;
        result=false;
    end
end

function[result,msgString]=lValidateBuiltinConflicts(cs,derived)
    if isSimulinkStarted()
        c=simscape.gui.sli.internal.isBuiltinParam(derived);
    else
        c=false(size(derived));
    end
    result=true;
    msgString='';
    if any(c)
        result=false;
        i=cs.info();
        conflicting=derived(c);
        msgString=message('physmod:ne_sli:dialog:ConflictingBuiltinNames',...
        i.DotPath(),strjoin(conflicting,', ')).getString();
    end
end

function[result,msgString]=lValidateDerivedConflicts(cs,derivedIds)
    [~,idx]=unique(lower(derivedIds));

    result=true;
    msgString='';
    conflicting=derivedIds(setdiff(1:numel(derivedIds),idx));
    if~isempty(conflicting)
        result=false;
        i=cs.info();
        msgString=message('physmod:ne_sli:dialog:ConflictingDerivedNames',...
        i.DotPath(),strjoin(conflicting,', ')).getString();
    end
end


function msg=lGetEscapedMessage(msg)
    specialCharacters={'%','%%'
    '\','\\'};
    for idx=1:size(specialCharacters,1)
        msg=strrep(msg,...
        specialCharacters{idx,1},...
        specialCharacters{idx,2});
    end
end

function str=lMakeReport(exe)




    str=exe.message();
    if~isempty(exe.cause)
        str=sprintf('%s\n\n%s',str,...
        message('physmod:ne_sli:dialog:CausedBy').getString());
    end

    str=[str,causes(exe,'    ')];


    function str=causes(m,tab)
        str='';
        for idx=1:numel(m.cause)
            str=sprintf('%s\n%s%s',str,tab,m.cause{idx}.message());
            str=[str,causes(m.cause{idx},[tab,'    '])];%#ok<AGROW> 
        end
    end
end