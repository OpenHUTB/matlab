classdef StringToFileConverter<handle




    methods(Static)
        function[success,diagnostic]=convertToFile(string,filename)


            [~,fName,fExt]=fileparts(filename);
            if isempty(fExt)&&~isempty(fName)
                filename=[fName,'.m'];
            end

            fid=fopen(filename,'w');
            success=true;
            diagnostic=MException.empty();

            if fid==-1
                success=false;
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:cannotConvertToFile'));
            else
                fprintf(fid,'%s',string);
                fclose(fid);
            end
        end
    end
end
