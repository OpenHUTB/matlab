function bpath=FromPipePath(inPath)




    blocks={};
    subPath='';

    restPath=inPath;
    errID='stm:MultipleReleaseTesting:PipePathDecodeError';
    while(~isempty(restPath))
        [block,submodel,restPath,sepChar]=slprivate('decpath',restPath,true);

        switch sepChar
        case 'modelref'
            blocks{end+1}=block;%#ok<AGROW>

        case 'stateflow'
            if(~isempty(submodel)||isempty(restPath))
                me=MException(errID,stm.internal.MRT.share.getString(errID,inPath));
                throw(me);
            end

            blocks{end+1}=block;%#ok<AGROW>

            [subPath,submodel,restPath,sepChar]=slprivate('decpath',restPath);
            if(isempty(subPath)||~isempty(submodel)||~isempty(restPath)||~strcmp(sepChar,'none'))
                me=MException(errID,stm.internal.MRT.share.getString(errID,inPath));
                throw(me);
            end

        case 'none'
            blocks{end+1}=block;%#ok<AGROW>
            if(~isempty(submodel)||~isempty(restPath))
                me=MException(errID,stm.internal.MRT.share.getString(errID,inPath));
                throw(me);
            end

        otherwise
            me=MException(errID,stm.internal.MRT.share.getString(errID,inPath));
            throw(me);
        end
    end

    bpath=Simulink.BlockPath(blocks,subPath);

end

