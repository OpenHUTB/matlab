









function SFTargets(obj)

    verobj=obj.ver;
    machine=getStateflowMachine(obj);

    if isempty(machine)
        return;
    end









    obj.appendRule(['<Stateflow<machine<sfVersion:repval ',sfprivate('translate_sl2sfversion',verobj),'>>>']);

    if isR2008aOrEarlier(verobj)
        cs=getActiveConfigSet(obj.modelName);


        if isempty(cs)
            return;
        end

        isLib=machine.IsLibrary;
        targets=sf('TargetsOf',machine.Id);
        sfun=sf('find',targets,'target.name','sfun');
        rtw=sf('find',targets,'target.name','rtw');


        if isempty(sfun)
            sfun=Stateflow.Target(machine);
            sfun.Name='sfun';
            sfun=sfun.Id;
        end

        if isLib
            useLocal=convert_on_off(get_param(cs,'SimUseLocalCustomCode'));
        else
            useLocal=0;
            sf('set',sfun,'target.codeFlags',get_code_flags(cs,false));
            sf('set',sfun,'target.reservedNames',slprivate('cs_reserved_array_to_names',get_param(cs,'SimReservedNameArray')));
        end

        sf('set',sfun,'target.customCode',get_param(cs,'SimCustomHeaderCode'));
        sf('set',sfun,'target.userIncludeDirs',get_param(cs,'SimUserIncludeDirs'));
        sf('set',sfun,'target.userLibraries',get_param(cs,'SimUserLibraries'));
        sf('set',sfun,'target.customInitializer',get_param(cs,'SimCustomInitializer'));
        sf('set',sfun,'target.customTerminator',get_param(cs,'SimCustomTerminator'));
        sf('set',sfun,'target.userSources',get_param(cs,'SimUserSources'));
        sf('set',sfun,'target.useLocalCustomCodeSettings',useLocal);
        sf('set',sfun,'target.applyToAllLibs',1);

        if~isLib
            return;
        end


        if isempty(rtw)
            rtw=Stateflow.Target(machine);
            rtw.Name='rtw';
            rtw=rtw.Id;
        end

        useLocal=convert_on_off(get_param(cs,'RTWUseLocalCustomCode'));

        sf('set',rtw,'target.customCode',get_param(cs,'CustomHeaderCode'));
        sf('set',rtw,'target.userIncludeDirs',get_param(cs,'CustomInclude'));
        sf('set',rtw,'target.userLibraries',get_param(cs,'CustomLibrary'));
        sf('set',rtw,'target.customInitializer',get_param(cs,'CustomInitializer'));
        sf('set',rtw,'target.customTerminator',get_param(cs,'CustomTerminator'));
        sf('set',rtw,'target.userSources',get_param(cs,'CustomSource'));
        sf('set',rtw,'target.useLocalCustomCodeSettings',useLocal);
        sf('set',rtw,'target.applyToAllLibs',1);

    end




    function re=convert_on_off(in)
        if strcmp(in,'on')
            re=1;
        else
            re=0;
        end






        function output=get_code_flags(cs,isRTW)
            if isRTW

                output=' comments=';
                if(strcmp(get_param(cs,'GenerateComments'),'on'))
                    output=[output,'1 statebitsets='];
                else
                    output=[output,'0 statebitsets='];
                end

                if(strcmp(get_param(cs,'StateBitsets'),'on'))
                    output=[output,'1 databitsets='];
                else
                    output=[output,'0 databitsets='];
                end

                if(strcmp(get_param(cs,'DataBitsets'),'on'))
                    output=[output,'1'];
                else
                    output=[output,'0'];
                end

            else

                output=' debug=1 overflow=1 echo=';
                if(strcmp(get_param(cs,'SFSimEcho'),'on'))
                    output=[output,'1'];
                else
                    output=[output,'0'];
                end

            end


