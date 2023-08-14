classdef SharedUtilsException<MSLException








    methods


        function this=SharedUtilsException(messageId,nameA,nameB,structA,structB,differences,messages,varargin)


            if usejava('jvm')
                structStringA=coder.internal.SharedUtilsException.serialiseStructToMATLABCommand(structA);
                structStringB=coder.internal.SharedUtilsException.serialiseStructToMATLABCommand(structB);
                cmdStr=sprintf('coder.internal.showSharedUtilDiff(''%s'', ''%s'', ''%s'', ''%s'')',nameA,nameB,structStringA,structStringB);
                linkText='link';
                link=targets_hyperlink_manager('new',linkText,cmdStr);
                differenceString=getString(message('RTW:buildProcess:sharedUtilsInconsistentComparison',nameA,nameB,link));
            else
                diffString='';
                for i=1:length(differences)
                    param=differences{i};
                    diffString=sprintf('%s%s: %s ==> %s\n',diffString,param,structA.(param),structB.(param));
                end
                differenceString=message('RTW:buildProcess:sharedUtilsInconsistentNoComparisonTool',diffString).getString;
                differenceString=sprintf('%s\n',differenceString);
            end

            solutionString=strjoin(arrayfun(@getString,messages,'UniformOutput',false),'\n\n');

            mes=message(messageId,varargin{:},differenceString,solutionString);
            this@MSLException([],mes);
        end
    end

    methods(Static,Access=private)




        function str=serialiseStructToMATLABCommand(s)
            f=fields(s);
            str='struct(';

            for i=1:length(f)
                str=sprintf('%s''''%s'''', %s,',str,f{i},coder.internal.SharedUtilsException.createVarStr(s.(f{i})));
            end

            str=[str(1:end-1),')'];


            str=strrep(str,newline,'');
        end

        function str=createVarStr(val)

            if ischar(val)
                str=['''''',val,''''''];
            else
                str=['[',num2str(val),']'];
            end
        end
    end



    methods(Static)
        function output=removeDirectory(directory)
            rmdir(directory,'s');
            output=sprintf('Removed ''%s'' and its contents.',directory);
        end

        function output=showConfigDialogForModel(model)
            view(getActiveConfigSet(model));
            output=sprintf('Opened configuration parameters for ''%s.''',model);
        end
    end
end

