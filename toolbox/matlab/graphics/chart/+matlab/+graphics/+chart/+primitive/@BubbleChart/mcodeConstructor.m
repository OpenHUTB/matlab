function mcodeConstructor(obj,code)




    import matlab.graphics.chart.primitive.internal.mcodeConstructorHelper

    channels=["X","Y","Z","Size","Color","Alpha"];


    matrixSyntaxes=logical([
    1,1,1,1,1,0;
    1,1,1,1,0,0;
    1,1,0,1,1,0;
    1,1,0,1,0,0;
    ]);


    tableSyntaxes=logical([
    1,1,1,1,1,0;
    1,1,1,1,0,0;
    1,1,0,1,1,0;
    1,1,0,1,0,0;
    ]);


    [positionalChannels,propertyNames]=mcodeConstructorHelper.getPositionalArguments(obj,channels,matrixSyntaxes,tableSyntaxes);


    if any(positionalChannels=="Z")
        setConstructorName(code,'bubblechart3');
    else
        setConstructorName(code,'bubblechart');
    end


    mcodeConstructorHelper.generateCode(obj,code,channels,positionalChannels,propertyNames);

end
