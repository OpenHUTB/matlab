function isLccCompiler=lccCompatibilityCheck(lModelName,...
    lConfigSet,...
    lToolchainAlias,...
    lModelReferenceTargetType)




    isLccCompiler=false;

    if~isempty(lToolchainAlias)

        isLccCompiler=any(strcmpi(lToolchainAlias,'LCC-x'));

        if isLccCompiler


            isCpp=rtwprivate('rtw_is_cpp_build',lConfigSet);
            if isCpp

                DAStudio.error('RTW:makertw:lccNotCPPcompilerSL');
            end

            isXCP=coder.internal.xcp.isXCPTarget(lConfigSet);
            if isXCP

                DAStudio.error('RTW:makertw:lccNotXCPCompatible');
            end


            if strcmp(lModelReferenceTargetType,'SIM')


                simscapeSolverConfig=find_system(lModelName,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'LookUnderMasks','on',...
                'FollowLinks','on',...
                'FirstResultOnly','on',...
                'ReferenceBlock','nesl_utility/Solver Configuration');
                if~isempty(simscapeSolverConfig)
                    hyperlink='https://www.mathworks.com/support/compilers/current_release';
                    hyperlink={sprintf('web(''%s'')',hyperlink),hyperlink};
                    DAStudio.error('RTW:makertw:lccNotSimscapeCompatible',hyperlink);
                end
            end
        end
    end
