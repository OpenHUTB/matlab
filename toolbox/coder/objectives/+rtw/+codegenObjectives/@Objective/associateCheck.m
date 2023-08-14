function associateCheck(obj,check,arg)




    check=convertStringsToChars(check);
    if~ischar(check)
        throw(MSLException([],message('MATLAB:class:MustBeString')));
    end

    thisCheck=rtw.codegenObjectives.Check(check,arg);


    if~isempty(obj.checkHash.get(check))
        if strcmpi(check,'mathworks.codegen.CodeGenSanity')
            return;
        end

        if obj.checkHash.get(check)==arg
            throw(MSLException([],message(...
            'Simulink:tools:existedCheckError',check,obj.objectiveName,arg)));
        end



        obj.checks{obj.checkHashPos.get(check)}=thisCheck;
    else

        obj.checks{end+1}=thisCheck;
        obj.checkHash.put(check,arg);
        obj.checkHashPos.put(check,length(obj.checks));
    end



    if isempty(obj.baseObjective)
        cm=DAStudio.CustomizationManager;
        additionalCheck=cm.ObjectiveCustomizer.additionalCheck;

        fixedCheck=coder.advisor.internal.CGOFixedCheck;
        checkHash=coder.advisor.internal.HashMap(fixedCheck.checkHash);


        for i=1:length(additionalCheck)
            checkHash.put(additionalCheck{i},1);
        end




        if isempty(checkHash.get(check))
            cm.ObjectiveCustomizer.addAdditionalCheck(check);
        end
    end

