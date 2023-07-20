function mcodeConstructor(this,code)







    code.generateDefaultPropValueSyntax;




    if~isempty(this.up)

        hFunc=codegen.codefunction('Name','addModel','CodeRef',code);
        addPostConstructorFunction(code,hFunc);


        hArg=codegen.codeargument('Value',this.up,'IsParameter',true);
        addArgin(hFunc,hArg);


        hArg=codegen.codeargument('Value',this,'IsParameter',true);
        addArgin(hFunc,hArg);

    end
