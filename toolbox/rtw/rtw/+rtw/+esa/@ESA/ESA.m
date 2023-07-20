classdef ESA<handle











    properties(Access='private')
        BinaryAnalysisObj;
    end




    methods(Hidden=true)





        function obj=ESA(fileName)
            if(nargin==1)
                obj=validateAndAnalyzeFile(obj,fileName);
            else
                DAStudio.error('RTW:asap2:invalidInputParam',mfilename);
            end
        end




        function symbols=getSymbolTable(obj)
            symbols=obj.BinaryAnalysisObj.getSymbolTable();
        end

    end




    methods(Access='private')





        function analyzeFile(obj,fileName)



            fileFormat=rtw.esa.getFileFormat(fileName);
            if(strcmp(fileFormat,'ELF'))



                obj.BinaryAnalysisObj=rtw.esa.ELF(fileName);
                return;
            end
            DAStudio.error('RTW:asap2:FileNotELF',fileName);
        end




        function obj=validateAndAnalyzeFile(obj,fileName)
            if(~ischar(fileName)||~isrow(fileName)||isempty(fileName))
                DAStudio.error('RTW:asap2:invalidInputParam',mfilename);
            end




            [fid,msg]=fopen(fileName,'rb');
            if(fid<0)
                DAStudio.error('RTW:ESA:cannotOpenFile',fileName,msg);
            end
            fclose(fid);




            m=memmapfile(fileName,'repeat',1);
            fileName=m.FileName;
            clear m;




            analyzeFile(obj,fileName);

        end

    end




    methods(Static=true,Hidden=true)
        function symValue=getSymbolValForName(symtab,symName)













            if symtab.isKey(symName)
                symValue=symtab(symName);
            elseif symtab.isKey(['_',symName])

                symValue=symtab(['_',symName]);
            else
                DAStudio.error('RTW:ESA:noSymbolInTable',symName);
            end
        end

    end

end
