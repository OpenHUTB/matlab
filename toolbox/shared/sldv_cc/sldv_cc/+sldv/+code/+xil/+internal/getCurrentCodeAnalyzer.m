



function codeAnalyzer=getCurrentCodeAnalyzer(testComp)

    if nargin<1
        testComp=Sldv.Token.get.getTestComponent();
    end

    codeAnalyzer=[];

    if~isempty(testComp)&&...
        isa(testComp,'SlAvt.TestComponent')&&...
        isa(testComp.codeAnalyzer,'sldv.code.xil.CodeAnalyzer')&&...
        ~builtin('isempty',testComp.codeAnalyzer)
        codeAnalyzer=testComp.codeAnalyzer;
    end
