



function BuildSFunction(blockHandle)
    sfunBlkType=getSFunctionBlockType(blockHandle);
    if~isBuildRequired(blockHandle,sfunBlkType)

        return;
    end
    switch sfunBlkType
    case 'SFUNCTION_BUILDER',
        doBuildSFunctionBuilder(blockHandle)
    case 'USER_DEFINED'
        doBuildUserDefined(blockHandle)
    otherwise

    end

end








function out=getSFunctionBlockType(blockHandle)
    wd=get_param(blockHandle,'WizardData');
    if~isempty(wd)
        out='SFUNCTION_BUILDER';
    else
        out='USER_DEFINED';
    end
end




function flag=isBuildRequired(blockHandle,sfunBlkType)
    flag=false;%#ok
    sFName=get_param(blockHandle,'FunctionName');
    sFNameDotC=which([sFName,'.c']);
    if isempty(sFNameDotC)

        if~strcmp(sfunBlkType,'SFUNCTION_BUILDER')
            flag=false;
            return;
        end
    else

        tbxPath=fullfile(matlabroot,'toolbox','');
        if(strncmp(sFNameDotC,tbxPath,length(tbxPath)))
            flag=false;
            return;
        end
    end

    wOutput=which([sFName,'.',mexext]);
    if isempty(wOutput)
        flag=true;
    else



        flag=false;
    end
end




function doBuildSFunctionBuilder(blockHandle)
    fullBlockName=getfullname(blockHandle);
    disp(['#### Building S-function for: ',fullBlockName,9]);

    appdata=sfunctionwizard(blockHandle,'GetApplicationData');

    appdata=sfunctionwizard(blockHandle,'Build',appdata);
    sFName=get_param(blockHandle,'FunctionName');
    wOutput=which([sFName,'.',mexext]);
    if isempty(wOutput)
        buildLog=appdata.SfunBuilderPanel.fCompileStatsTextArea.getText();
        if~buildLog.isEmpty
            disp(buildLog.toString);
        end
    end
    sfunctionwizard(blockHandle,'delete',appdata)
end





function doBuildUserDefined(blockHandle)
    mexCommnad=get_param(blockHandle,'MexCommand');
    if(~(isempty(mexCommnad)&&ischar(mexCommnad)))
        eval(mexCommnad);
    end
end


