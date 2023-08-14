function[createSILPILBlock,...
    isSILMode]=isCreateSILPILBlock(cs)




    createSILPILBlockParam=get_param(cs,'CreateSILPILBlock');

    if~isempty(createSILPILBlockParam')
        switch createSILPILBlockParam
        case 'SIL'

            codeInfoSILBlock=slfeature('CodeInfoSILBlock');
            if codeInfoSILBlock
                createSILPILBlock=true;
            else

                createSILPILBlock=false;
            end
            isSILMode=true;
        case 'PIL'
            createSILPILBlock=true;
            isSILMode=false;
        case 'None'
            createSILPILBlock=false;
            isSILMode=[];
        otherwise
            assert(false,...
            'Unknown setting for CreateSILPILBlock: %s',...
            createSILPILBlockParam);
        end
    else

        createSILPILBlock=false;
        isSILMode=[];
    end