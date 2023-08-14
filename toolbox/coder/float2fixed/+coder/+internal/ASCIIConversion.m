classdef ASCIIConversion



    properties(Constant)
        NonASCIIPrefix='@NON_ASCII_';
        NonASCIISuffix='@';
    end

    methods(Static)

        function sanitizedPath=sanitize(inputPath)
            sanitizedChars=cell(size(inputPath));

            for i=1:numel(inputPath)



                c=inputPath(i);
                if c>=0&&c<=127
                    sanitizedChars{i}=c;
                else
                    sanitizedChars{i}=[...
                    coder.internal.ASCIIConversion.NonASCIIPrefix,...
                    num2str(double(c)),...
                    coder.internal.ASCIIConversion.NonASCIISuffix];
                end
            end

            sanitizedPath=strjoin(sanitizedChars,'');
        end

        function outputPath=unsanitize(sanitizedPath)
            pat=[coder.internal.ASCIIConversion.NonASCIIPrefix,...
            '(\d+)',coder.internal.ASCIIConversion.NonASCIISuffix];
            matches=regexp(sanitizedPath,pat,'tokens');

            outputPath=sanitizedPath;

            for i=1:numel(matches)
                num=matches{i}{1};
                placeholderText=[coder.internal.ASCIIConversion.NonASCIIPrefix,...
                num,coder.internal.ASCIIConversion.NonASCIISuffix];
                nonAsciiChar=char(str2double(num));

                outputPath=strrep(outputPath,placeholderText,nonAsciiChar);
            end
        end

    end

end
