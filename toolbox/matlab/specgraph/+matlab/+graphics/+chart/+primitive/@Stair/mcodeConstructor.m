function mcodeConstructor(obj,code)




    import matlab.graphics.chart.primitive.internal.mcodeConstructorHelper

    channels=["X","Y"];
    setConstructorName(code,'stairs');


    matrixSyntaxes=logical([
    1,1;
    0,1;
    ]);


    tableSyntaxes=logical([
    1,1;
    0,1;
    ]);


    [positionalChannels,propertyNames]=mcodeConstructorHelper.getPositionalArguments(obj,channels,matrixSyntaxes,tableSyntaxes);


    [objs,momentoList]=mcodeConstructorHelper.findCompatibleObjects(obj,code,channels);




    for n=1:numel(objs)
        if objs(n).ColorMode=="manual"
            prop=findobj(momentoList(n).PropertyObjects,'Name','Color');
            if isempty(prop)
                prop=codegen.momentoproperty;
                prop.Name='Color';
                prop.Value=objs(n).Color;
                momentoList(n).PropertyObjects=[momentoList(n).PropertyObjects,prop];
            end
        end
    end


    mcodeConstructorHelper.generateCode(objs,code,channels,positionalChannels,propertyNames,momentoList,"X");

end
