function integerToBitBlocks(obj)




    if isReleaseOrEarlier(obj.ver,'R2021b')






        if~iscommblksinstalled
            blkTypeComm={'Integer to Bit Converter','Bit to Integer Converter'};
            for i=1:numel(blkTypeComm)
                allBlksOfThisType=locFindBlock(obj.modelName,'MaskType',blkTypeComm{i});
                obj.replaceWithEmptySubsystem(allBlksOfThisType);
            end
        end
    end

    function b=iscommblksinstalled


        b=issimulinkinstalled;

        if b
            b=license('test','Communication_Toolbox')&&~isempty(ver('comm'));
        end
    end
    function b=issimulinkinstalled


        b=license('test','SIMULINK')&&~isempty(ver('simulink'));
    end

    function foundBlocks=locFindBlock(modelName,varargin)


        p=inputParser;
        p.addRequired('modelName',@isscalarstring);
        p.parse(modelName);
        function b=isscalarstring(v)
            b=ischar(v)||(isstring(v)&&numel(v)==1);
        end

        foundBlocks=find_system(modelName,...
        'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.allVariants,...
        'IncludeCommented','on',...
        varargin{:});
    end
end
