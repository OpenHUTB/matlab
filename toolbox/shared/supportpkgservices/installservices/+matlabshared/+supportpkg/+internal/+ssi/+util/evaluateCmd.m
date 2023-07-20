function[returnCmd,cmdOutput]=evaluateCmd(cmd)

















    validateattributes(cmd,{'char'},{'nonempty'},'evaluateCmd','cmd',1);
    cmdOutput=[];
    [mlst,mlend]=regexp(cmd,'\<matlab:','start','end');
    if~isempty(mlst)

        commandToExecute=cmd(mlend+1:end);





        parseTree=mtree(commandToExecute);
        hasReturn=mtfind(parseTree,'Kind','EQUALS');

        if isempty(hasReturn)

            eval([commandToExecute,';']);
        else





            stringParts=regexp(commandToExecute,'\s*=\s*','split','once');

            if length(stringParts)~=2
                error(message('supportpkgservices:installservices:WrongCmd',commandToExecute));
            end

            commandToExecute=stringParts{2};
            cmdOutput=eval([commandToExecute,';']);
        end
        returnCmd=['matlab:',commandToExecute];
    end
