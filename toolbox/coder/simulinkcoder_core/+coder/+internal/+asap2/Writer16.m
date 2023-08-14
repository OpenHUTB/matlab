classdef Writer16<coder.internal.asap2.Writer15




    methods(Access=public)





        function writeLayoutForMultiDimArray(this,width,arrayLayout)
            if(width>1)
                this.FormatContentsObj.wLine(['    LAYOUT                            ',arrayLayout]);
            end
        end



        function writeByteOrderMark(this)

            this.FormatContentsObj.writeBinary([239,187,191]);
        end



        function writeCoeffsInCompuMethods(this,ASAP2NumberFormat,compuMethod)
            if strcmp(compuMethod.ConversionType,'IDENTICAL')
                return;
            elseif strcmp(compuMethod.ConversionType,'LINEAR')

                str=sprintf([insertAfter(ASAP2NumberFormat,'%','#'),'g ',ASAP2NumberFormat,'f'],compuMethod.Coefficients(1),compuMethod.Coefficients(2));
                this.FormatContentsObj.write('    /* Coefficients           */  ',['    ','COEFFS_LINEAR ',str]);
            else
                str=sprintf(['0 ',ASAP2NumberFormat,'f ',ASAP2NumberFormat,'f 0 ',ASAP2NumberFormat,'f ',ASAP2NumberFormat,'f'],compuMethod.Coefficients(2),compuMethod.Coefficients(3),compuMethod.Coefficients(5),compuMethod.Coefficients(6));
                this.FormatContentsObj.write('    /* Coefficients           */  ',['    COEFFS ',str]);
            end
        end
        function alignment=getAlignment(~)
            alignment=sprintf(['      ALIGNMENT_BYTE 1',...
            newline,...
            '      ALIGNMENT_WORD 2',...
            newline,...
            '      ALIGNMENT_LONG 4',...
            newline,...
            '      ALIGNMENT_FLOAT32_IEEE 4',...
            newline,...
            '      ALIGNMENT_FLOAT64_IEEE 4',...
            newline,...
            '      ALIGNMENT_INT64 8',...
            ]);

        end
        function sourceFile=getSourceFile(~,arrayLayout)

            if strcmp(arrayLayout,'ROW_DIR')
                sourceFile=fullfile(matlabroot,'toolbox','coder','xcp','+coder','+asap2','RecordLayoutsRowDir16.a2l');
            else
                sourceFile=fullfile(matlabroot,'toolbox','coder','xcp','+coder','+asap2','RecordLayoutsColumnDir16.a2l');
            end
        end
    end
end


