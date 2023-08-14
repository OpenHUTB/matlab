function eti=readDataFile(~,constellation,xmlFile)




    model=mf.zero.Model(constellation);
    parser=mf.zero.io.XmlParser;
    parser.RemapUuids=false;
    parser.Model=model;
    bd=model.topLevelElements;
    parser.parseFile(xmlFile);

    bd.destroy;
    eti=findEti(model.topLevelElements);

end

function eti=findEti(model)


    for idx=1:numel(model)
        info=model(idx);
        if isa(info,'evolutions.model.EvolutionTreeInfo')
            eti=info;
            break;
        end
    end
end


