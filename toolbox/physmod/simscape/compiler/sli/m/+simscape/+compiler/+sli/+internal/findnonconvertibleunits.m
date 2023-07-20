function[badUnitBlocks,badUnitExceptions]=findnonconvertibleunits(simscapeBlocks)











    badUnitBlocks={};
    badUnitExceptions={};

    for i=1:length(simscapeBlocks)

        block=simscapeBlocks{i};
        cs=physmod.schema.internal.blockComponentSchema(block).info;

        err={};

        params=cs.Members.Parameters;
        for idx=1:numel(params)
            param=params(idx);
            id=param.ID;

            try
                get_param(block,id);
            catch





                continue;
            end


            try
                specifiedUnit=get_param(block,[id,'_unit']);
            catch




                continue;
            end


            defaultUnit=param.Default.Unit;


            if pm_isunit(specifiedUnit)&&...
                pm_commensurate(specifiedUnit,defaultUnit)&&...
                ~pm_directlyconvertible(specifiedUnit,defaultUnit)

                prompt=simscape.compiler.sli.internal.parameterpromptfromblock(id,block);
                if~isempty(prompt)
                    prompt=[' (',prompt,')'];%#ok
                end

                msgObject=message(...
                'physmod:simscape:compiler:sli:block:NonDirectlyConvertibleUnit',...
                id,prompt,defaultUnit,specifiedUnit);
                err{end+1}=MException(msgObject);%#ok<AGROW>
            end

        end

        if~isempty(err)
            msgObject=message(...
            'physmod:simscape:compiler:sli:block:NonDirectlyConvertibleUnitsBlock');
            exe=MException(msgObject);
            for j=1:numel(err)
                exe=exe.addCause(err{j});
            end
            badUnitBlocks{end+1}=block;%#ok
            badUnitExceptions{end+1}=exe;%#ok
        end

    end

end