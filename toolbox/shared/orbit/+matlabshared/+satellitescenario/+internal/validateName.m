function formattedNames=validateName(nameIn,numAssets,functionName)





%#codegen

    coder.allowpcode('plain');

    if isempty(coder.target)


        validateattributes(nameIn,{'string','char','cell'},{},...
        functionName,'Name');
    else


        validateattributes(nameIn,{'char','cell'},{},...
        functionName,'Name');
    end

    if~isempty(nameIn)
        if coder.target('MATLAB')&&isstring(nameIn)


            validateattributes(nameIn,{'string'},...
            {'vector'},functionName,'Name');



            if(numAssets>1)&&~isscalar(nameIn)
                validateattributes(nameIn,{'string'},...
                {'numel',numAssets},functionName,'Name');
            end


            formattedNames=cell(1,numel(nameIn));

            for idx=1:numel(nameIn)

                extractedName=nameIn(idx);


                validateattributes(char(extractedName),{'char'},...
                {'nonempty'},functionName,'Name');


                formattedNames{idx}=extractedName;
            end
        elseif iscell(nameIn)



            if coder.target('MATLAB')
                scalarOrVector='vector';
            else
                scalarOrVector='scalar';
            end
            validateattributes(nameIn,{'cell'},...
            {scalarOrVector},functionName,'Name');



            if(numAssets>1)&&~isscalar(nameIn)
                validateattributes(nameIn,{'cell'},...
                {'numel',numAssets},functionName,'Name');
            end


            formattedNames=cell(1,numel(nameIn));

            for idx=1:numel(nameIn)

                extractedName=nameIn{idx};


                validateattributes(extractedName,...
                {'char'},{'nonempty','scalartext'},functionName,'Name');



                formattedNames{idx}=string(extractedName);
            end
        elseif ischar(nameIn)



            validateattributes(nameIn,{'char'},...
            {'nonempty'},'groundStation','Name');


            formattedNames={string(nameIn)};
        end
    else

        formattedNames={''};
    end
end

