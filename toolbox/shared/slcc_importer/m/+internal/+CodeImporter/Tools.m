classdef Tools<handle

    properties

    end

    methods(Static)
        function res=convertToRelativePath(srcs,root)
            relPath=@(x)internal.CodeImporter.computeRelativePath(x,root);
            res=cellfun(relPath,srcs,'UniformOutput',false);
        end

        function res=convertToFullPath(srcs,root)
            fulPath=@(x)internal.CodeImporter.computeFullPath(x,root);
            res=cellfun(fulPath,srcs,'UniformOutput',false);
            res=string(res);
        end

        function isWritable=isFolderWritable(fpath)
            isWritable=CGXE.Utils.isFolderWritable(fpath);
        end

        function isWritable=isFileWritable(fpath)
            [~,Attrib]=fileattrib(fpath);
            isWritable=Attrib.UserWrite;
        end

        function inputStr=processDollarsAnsSep(inputStr)
            dollarLocation=strfind(inputStr,"$");

            if length(dollarLocation)/2~=floor(length(dollarLocation)/2)
                errorMsg=MException(message(...
                'Simulink:CustomCode:MismatchedDollars',inputStr));
                throw(errorMsg);
            end

            if~isempty(dollarLocation)


                for idx=length(dollarLocation):-2:2
                    startLoc=dollarLocation(idx-1);
                    endLoc=dollarLocation(idx);
                    cmdStr=extractBetween(inputStr,startLoc,endLoc,...
                    'Boundaries','exclusive');
                    try
                        outputStr=evalin('base',cmdStr);
                    catch ME

                        errorMsg=MException(message(...
                        'Simulink:CustomCode:ErrorInDollarString',...
                        cmdStr,...
                        inputStr));
                        throw(errorMsg);
                    end

                    if~((ischar(outputStr)&&size(outputStr,1)==1)||...
                        isStringScalar(outputStr))
                        errorMsg=MException(message(...
                        'Simulink:CustomCode:InvalidDollarString',...
                        cmdStr,...
                        inputStr));
                        throw(errorMsg);
                    end

                    inputStr=replaceBetween(inputStr,startLoc,endLoc,...
                    outputStr);
                end
            end


            inputStr=fullfile(inputStr);
        end


    end

end