classdef CompileModes<uint32



    enumeration
        None(0)
        CommandLineSimulation(1)
        Coverage(2)
        RTW(3)
        CGIR(4)
        DIY(5)
        SLDV(6)
    end

    methods
        function out=char(modes)
            out=cell(size(modes));

            for n=1:length(modes)
                switch modes(n)
                case Advisor.CompileModes.None
                    str='None';
                case Advisor.CompileModes.CommandLineSimulation
                    str='PostCompile';
                case Advisor.CompileModes.RTW
                    if slfeature('UpdateDiagramForCodegen')>0
                        str='PostCompileForCodegen';
                    else
                        str='RTW';
                    end
                case Advisor.CompileModes.CGIR
                    str='CGIR';
                case Advisor.CompileModes.Coverage
                    str='Coverage';
                case Advisor.CompileModes.DIY
                    str='DIY';
                case Advisor.CompileModes.SLDV
                    str='SLDV';
                otherwise
                    str='';
                end

                out{n}=str;
            end

            if length(out)==1
                out=out{1};
            end
        end

    end

    methods(Hidden)

        function compileMode=getMostFrequent(compileModeArray)
            if~isempty(compileModeArray)
                nums=zeros(size(compileModeArray));

                for n=1:length(compileModeArray)
                    switch compileModeArray(n)
                    case Advisor.CompileModes.None
                        num=0;
                    case Advisor.CompileModes.CommandLineSimulation
                        num=1;
                    case Advisor.CompileModes.Coverage
                        num=2;
                    case Advisor.CompileModes.RTW
                        num=3;
                    case Advisor.CompileModes.CGIR
                        num=4;
                    case Advisor.CompileModes.DIY
                        num=5;
                    case Advisor.CompileModes.SLDV
                        num=6;
                    otherwise
                        num=0;
                    end

                    nums(n)=num;
                end

                mostFrequentNum=mode(nums);

                switch mostFrequentNum
                case 0
                    compileMode=Advisor.CompileModes.None;
                case 1
                    compileMode=Advisor.CompileModes.CommandLineSimulation;
                case 2
                    compileMode=Advisor.CompileModes.Coverage;
                case 3
                    compileMode=Advisor.CompileModes.RTW;
                case 4
                    compileMode=Advisor.CompileModes.CGIR;
                case 5
                    compileMode=Advisor.CompileModes.DIY;
                case 6
                    compileMode=Advisor.CompileModes.SLDV;
                otherwise
                    compileMode=Advisor.CompileModes.None;
                end
            else
                compileMode=[];
            end
        end
    end

    methods(Static)
        function validateCompileMode(mode)
            if~isa(mode,'Advisor.CompileModes')
                DAStudio.error('Advisor:base:CompileService_UnsupportedCompileMode');
            end
        end

        function mode=char2mode(str)
            switch str
            case 'None'
                mode=Advisor.CompileModes.None;
            case 'PostCompile'
                mode=Advisor.CompileModes.CommandLineSimulation;
            case 'RTW'
                mode=Advisor.CompileModes.RTW;
            case 'PostCompileForCodegen'
                if slfeature('UpdateDiagramForCodegen')>0
                    mode=Advisor.CompileModes.RTW;
                else
                    mode=Advisor.CompileModes.None;
                end
            case 'CGIR'
                mode=Advisor.CompileModes.CGIR;
            case 'Coverage'
                mode=Advisor.CompileModes.Coverage;
            case 'DIY'
                mode=Advisor.CompileModes.DIY;
            case 'SLDV'
                mode=Advisor.CompileModes.SLDV;
            otherwise
                mode=Advisor.CompileModes.None;
            end
        end
    end

end


