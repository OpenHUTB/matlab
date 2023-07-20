classdef Writer13<coder.internal.asap2.WriterBase




    methods(Access=public)



        function byteOrder=getByteOrder(this)
            byteOrder=sprintf('BYTE_ORDER     MSB_FIRST');
        end




        function writeDimension(this,Variable,isParam,~)
            this.FormatContentsObj.write('    /* Array Size             */      ','');
            if(isParam)
                this.FormatContentsObj.wLine(['    NUMBER                            ',num2str(Variable.Width)]);
            else
                this.FormatContentsObj.wLine(['    ARRAY_SIZE                        ',num2str(Variable.Width)]);
            end
        end

        function writeLayoutForMultiDimArray(~,~,~)
        end


        function writeByteOrderMark(~)
        end




        function writeCoeffsInCompuMethods(this,ASAP2NumberFormat,compuMethod)
            if isequal(compuMethod.Coefficients,[0,1,0,0,0,1])
                str='0 1 0 0 0 1';
            elseif(compuMethod.Coefficients(3)==0)
                str=sprintf(['0 ',ASAP2NumberFormat,'f 0 0 0 ',ASAP2NumberFormat,'f'],compuMethod.Coefficients(2),compuMethod.Coefficients(6));
            elseif(compuMethod.Coefficients(5)==0)
                str=sprintf(['0 ',ASAP2NumberFormat,'f ',ASAP2NumberFormat,'f 0 0 ',ASAP2NumberFormat,'f'],compuMethod.Coefficients(2),compuMethod.Coefficients(3),compuMethod.Coefficients(6));
            else
                str=sprintf(['0 ',ASAP2NumberFormat,'f ',ASAP2NumberFormat,'f 0 ',ASAP2NumberFormat,'f ',ASAP2NumberFormat,'f'],compuMethod.Coefficients(2),compuMethod.Coefficients(3),compuMethod.Coefficients(5),compuMethod.Coefficients(6));
            end
            this.FormatContentsObj.write('    /* Coefficients           */  ',['    COEFFS ',str]);
        end

        function writeCalibrationAccess(this,value)
            if strcmp(value,'NO_CALIBRATION')
                this.FormatContentsObj.wLine('    READ_ONLY');
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
'      ALIGNMENT_FLOAT64_IEEE 4'
            ]);

        end
        function sourceFile=getSourceFile(~,arrayLayout)

            if strcmp(arrayLayout,'ROW_DIR')
                sourceFile=fullfile(matlabroot,'toolbox','coder','xcp','+coder','+asap2','RecordLayoutsRowDir13.a2l');
            else
                sourceFile=fullfile(matlabroot,'toolbox','coder','xcp','+coder','+asap2','RecordLayoutsColumnDir13.a2l');
            end
        end
    end
end


