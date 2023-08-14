function tf=isFixedPoint(blocks)






    [blockObjs,nBlockObjs]=rptgen_sl.getSimulinkObjects(blocks);
    propSrc=rptgen_sl.propsrc_sl_blk;

    blockList=cell(1,nBlockObjs);
    for i=1:nBlockObjs
        blockList{i}=blockObjs(i).getFullName();
    end


    models=unique(bdroot(blockList));
    for i=1:length(models)
        if strcmpi(get_param(models{i},'SimulationStatus'),'stopped')
            rptgen.displayMessage(...
            sprintf(getString(message('rptgen:fp_rptgen_fp:mustBeCompiledMsg')),models{i}),...
            2);
        end
    end

    compiledPortDataTypes=propSrc.getPropValue(blockList,'CompiledPortDataTypes');


    tf=false(1,nBlockObjs);

    if~isempty(compiledPortDataTypes)
        for i=1:nBlockObjs
            blockObj=blockObjs(i);

            if(blockObj.isSLBlockFixedPoint&&~isempty(compiledPortDataTypes{i}))
                inport=compiledPortDataTypes{i}.Inport;
                outport=compiledPortDataTypes{i}.Outport;


                if(locContainsFixPoint(inport)||locContainsFixPoint(outport))
                    tf(i)=true;
                end
            end
        end
    end


    function tf=locContainsFixPoint(datatypes)

        tf=false;

        for i=1:length(datatypes)
            dataType=datatypes{i};
            if~isempty(dataType)
                try
                    numericType=fixdt(dataType);
                    if strncmpi(numericType.DataTypeMode,'fixed-point',11)
                        tf=true;
                        return
                    end
                catch ME %#ok
                end
            end
        end



