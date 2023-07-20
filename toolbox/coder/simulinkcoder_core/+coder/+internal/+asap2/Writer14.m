classdef Writer14<coder.internal.asap2.Writer13




    methods(Access=public)




        function byteOrder=getByteOrder(this)
            byteOrder=sprintf('BYTE_ORDER     MSB_LAST');
        end



        function writeDimension(this,Variable,~,swap)
            dim=ones(1,3);
            for ii=1:length(Variable.Dimensions)
                dim(ii)=Variable.Dimensions(ii);
            end
            if swap
                this.FormatContentsObj.wLine(['    MATRIX_DIM                        ',num2str(dim(2)),' ',num2str(dim(1)),' ',num2str(dim(3))]);
            else
                this.FormatContentsObj.wLine(['    MATRIX_DIM                        ',num2str(dim(1)),' ',num2str(dim(2)),' ',num2str(dim(3))]);
            end
        end

        function writeCalibrationAccess(this,value)
            this.FormatContentsObj.wLine(['    CALIBRATION_ACCESS ',value]);
        end
    end

end


