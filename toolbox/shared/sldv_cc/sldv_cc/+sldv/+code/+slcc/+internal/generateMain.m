



function generateMain(filePath,wrapperFunctions,randomFunctions)

    writer=sldv.code.internal.CWriter(filePath,'wt');
    externC='__MW_PS_EXTERN_C';
    writer.defineExternC(externC);
    writer.print('\n');
    for ii=1:numel(wrapperFunctions)
        writer.print('%s void %s(void);\n',externC,wrapperFunctions{ii});
    end
    for ii=1:numel(randomFunctions)
        writer.print('%s void %s(void);\n',externC,randomFunctions{ii});
    end

    writer.beginBlock('\n\nvoid main() {');
    writer.print('\nvolatile short randomVar = 1;');
    writer.beginBlock('\nwhile(randomVar > 0) {');

    for ii=1:numel(randomFunctions)
        writer.print('\n%s();',randomFunctions{ii});
    end


    for ii=1:numel(wrapperFunctions)
        writer.beginBlock('\nif(randomVar > 0) {');
        writer.print('\n%s();',wrapperFunctions{ii});
        writer.endBlock('\n}\n');
    end

    writer.endBlock('\n}\n');
    writer.endBlock('\n}\n');
